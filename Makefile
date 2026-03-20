# prefer ash on alpine/iSH
SHELL := $(word 1, $(wildcard /bin/ash /bin/bash))
WHICH := command -v
PACKAGE := $(notdir $(CURDIR))
$(warning PACKAGE is $(PACKAGE))
SCRIPTS := $(shell find . -type f -name '*.py')
LINT := $(SCRIPTS:.py=.pylint)
SIBLINGS := netlib mitmproxy
# use python3 nosetests by default, override on command line
# by using `make NOSETESTS=nosetests-2.7 tests`
NOSETESTS := $(word 1, $(shell $(WHICH) nosetests-3.9 nosetests3 nosetests))
# WARNING: deferred evaluations follow
# NOTE: end of deferred evaluations
ifneq ($(SHOWENV),)
export
endif
default: install
	mitmdump --version
install: setup.py build \
 .installed/libxslt-dev .installed/libxml2-dev .installed/gcc \
 .installed/python3-dev .installed/py3-libxml2 .installed/musl-dev \
 .installed/py3-pillow .installed/openssl-dev .installed/libffi-dev \
 .installed/build-base .installed/py3-flask .installed/py3-urwid
	echo installing $(PACKAGE) from $(CURDIR) called from $(PWD) >&2
	sudo python3 $< $@ --force
build: setup.py clean .FORCE | .installed/python3
	# build companion projects before mitmproxy
	if [ "$(PACKAGE)" = "mitmproxy" ]; then \
	 for sibling in $(filter-out $(PACKAGE),$(SIBLINGS)); do \
	  $(MAKE) -C ../$$sibling $@; \
	 done; \
	fi
	python3 $< $@
# this really isn't necessary until/unless we want to build an apk package
$(HOME)/.abuild: | /etc/alpine-release
	abuild-keygen -an
.installed/python3 .installed/gcc: .FORCE | .installed 
	if [ -z "$(WHICH) $(@F)" ]; then \
	 echo cannot find $(@F), installing... >&2; \
	 sudo apk add $(@F); \
	fi
	touch $@
.installed/py3-%: | .installed
	sudo apk add $(@F)
	touch $@
.installed:
	mkdir $@
%.pylint: %.py .installed/py3-pylint
	pylint $<
pylint: $(LINT)
pip3-install: .installed/py3-pip
	pip3 --verbose install --force-reinstall \
	 git+https://github.com/jcomeauictx/$(PACKAGE)@alpine-ish
.installed/%-dev .installed/%-base: | .installed
	sudo apk add $(@F)
	touch $@
.installed/%.pip3: | .installed
	pip3 install $*
	touch $@
clean:
	sudo rm -rf build dist *.egg_info
	find . -type d -name __pycache__ -exec sudo rm -rf {} +
	find . -name '*.py[co]' -delete
tests: | .installed/py3-nose .installed/py3-mock #.installed/pathod.pip3
	@echo "running $(NOSETESTS) in $(CURDIR)" >&2
	$(NOSETESTS) .
push pull status diff:
	git $@
commit:
	git $@ -a
env:
ifeq ($(SHOWENV),1)
	$@
else
	$(MAKE) SHOWENV=1 $@
endif
.FORCE:
.PHONY: tests push pull status commit
