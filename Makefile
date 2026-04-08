# prefer ash on alpine/iSH
SHELL := $(word 1, $(wildcard /bin/ash /bin/bash))
WHICH := command -v
PYTHON ?= $(word 1, $(shell $(WHICH) python3 python python2))
BRANCH := $(shell git branch --show-current)
PACKAGE := $(notdir $(CURDIR))
$(warning PACKAGE is $(PACKAGE))
SCRIPTS := $(shell find . -type f -name '*.py')
LINT := $(SCRIPTS:.py=.pylint)
SIBLINGS := netlib mitmproxy pathod
# use python3 nosetests by default, override on command line
# by using `make NOSETESTS=nosetests-2.7 tests`
NOSETESTS := $(PYTHON) -m nose
# limit lines of output for `make log`
LOGLIMIT ?= 10000
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
 .installed/build-base .installed/py3-flask .installed/py3-urwid \
 .installed/py3-asn1 .installed/py3-openssl .installed/py3-lxml \
 .installed/py3-requests .installed/python2-dev
	echo installing $(PACKAGE) from $(CURDIR) called from $(PWD) >&2
	$(PYTHON) $< $@ --user --force
build: setup.py clean .FORCE | .installed/python3
	# should probably build companion projects before mitmproxy
	$(PYTHON) $< $@
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
.installed/pathod: | .installed
	cd ../$(@F) && $(MAKE) install
clean:
	rm -rf build dist *.egg_info
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -name '*.py[co]' -delete
tests: | .installed/py3-nose .installed/py3-mock .installed/pathod
	@echo "running $(NOSETESTS) in $(CURDIR)" >&2
	$(NOSETESTS) --verbose --detailed-errors --nocapture --nologcapture .
diff:
	git $@ || true
%.diff:
	git diff -w $* || true
push pull status:
	git $@
log:
	git $@ | head -n $(LOGLIMIT)
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
