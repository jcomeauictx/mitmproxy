# prefer ash on alpine/iSH
SHELL := $(word 1, $(wildcard /bin/ash /bin/bash))
WHICH := command -v
PYTHON ?= $(word 1, $(shell $(WHICH) python3 python python2))
INSTALL_DIR := $(shell $(PYTHON) -c "from site \
 import getusersitepackages as installdir; \
 print(installdir())")
BRANCH := $(shell git branch --show-current)
PACKAGE := $(notdir $(CURDIR))
INSTALLED := $(HOME)/.$(PACKAGE)/.installed
INSTALLED_PACKAGE = $(shell awk -F'"' '$$1 ~ /^packages,/ {print $$2}' setup.py)
$(warning PACKAGE is $(PACKAGE),$(INSTALLED) as $(INSTALLED_PACKAGE))
SCRIPTS := $(shell find . -type f -name '*.py')
LINT := $(SCRIPTS:.py=.pylint)
SIBLINGS := netlib mitmproxy pathod
# use python3 nosetests by default, override on command line
# by using `make NOSETESTS=nosetests-2.7 tests`
NOSETESTS := $(PYTHON) -m nose
PIP := $(PYTHON) -m pip
# limit lines of output for `make log`
LOGLIMIT ?= 10000
# pyOpenSSL 16.2.0 is the oldest that might work;
# every older one failed with
# AttributeError: 'module' object has no attribute 'SSL_ST_INIT'
# NOTE: the following order may be suboptimal
PIP2_REQUIRED := cffi==1.15.1 cryptography==3.3.2 enum34==1.1.10 \
 ipaddress==1.0.23 pyopenssl==16.2.0 pyasn1==0.1.3 werkzeug==0.6.1 \
 flask==0.5.2 urwid==1.1 pillow==2.5.3 lxml==3.8.0 mock==3.0.5 \
 six==1.7.3 requests==2.25.1
FILES := $(shell git ls-files)
# WARNING: deferred evaluations follow
# NOTE: end of deferred evaluations
ifneq ($(SHOWENV),)
export
endif
default: install
	mitmdump --version
install: $(INSTALL_DIR)/$(INSTALLED_PACKAGE)
$(INSTALL_DIR)/$(INSTALLED_PACKAGE): $(FILES) $(INSTALLED)/certs \
 $(INSTALLED)/libxslt-dev $(INSTALLED)/libxml2-dev $(INSTALLED)/gcc \
 $(INSTALLED)/python3-dev $(INSTALLED)/py3-libxml2 $(INSTALLED)/musl-dev \
 $(INSTALLED)/py3-pillow $(INSTALLED)/openssl-dev $(INSTALLED)/libffi-dev \
 $(INSTALLED)/build-base $(INSTALLED)/py3-flask $(INSTALLED)/py3-urwid \
 $(INSTALLED)/py3-asn1 $(INSTALLED)/py3-openssl $(INSTALLED)/py3-lxml \
 $(INSTALLED)/py3-requests $(INSTALLED)/python2-dev \
 $(addprefix $(INSTALLED)/pip2-,$(PIP2_REQUIRED))
	echo installing $(PACKAGE) from $(CURDIR) called from $(PWD) >&2
	echo reinstalling due to newer $? >&2
	$(PYTHON) setup.py install --user --force
build: setup.py clean .FORCE | $(INSTALLED)/python3
	# should probably build companion projects before mitmproxy
	$(PYTHON) $< $@
# this really isn't necessary until/unless we want to build an apk package
$(HOME)/.abuild: | /etc/alpine-release
	abuild-keygen -an
$(INSTALLED)/python3 $(INSTALLED)/gcc: | $(INSTALLED) 
	if [ -z "$(WHICH) $(@F)" ]; then \
	 echo cannot find $(@F), installing... >&2; \
	 sudo apk add $(@F); \
	fi
	touch $@
$(INSTALLED)/py3-%: | $(INSTALLED)
	sudo apk add $(@F)
	touch $@
$(INSTALLED)/pip2-%: | $(INSTALLED)
	if [ "$(notdir $(PYTHON))" = python2 ]; then \
	 $(PIP) install $* && touch $@; \
	else \
	 true; \
	fi
$(INSTALLED):
	mkdir --parents $@
%.pylint: %.py $(INSTALLED)/py3-pylint
	pylint $<
pylint: $(LINT)
pip3-install: $(INSTALLED)/py3-pip
	pip3 --verbose install --force-reinstall \
	 git+https://github.com/jcomeauictx/$(PACKAGE)@alpine-ish
$(INSTALLED)/%-dev $(INSTALLED)/%-base: | $(INSTALLED)
	sudo apk add $(@F)
	touch $@
$(INSTALLED)/%.pip3: | $(INSTALLED)
	pip3 install $*
	touch $@
$(INSTALLED)/pathod: | $(INSTALLED)
	cd ../$(@F) && $(MAKE) install
clean:
	rm -rf build dist *.egg_info
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -name '*.py[co]' -delete
tests: | $(INSTALLED)/py3-nose $(INSTALLED)/py3-mock $(INSTALLED)/pathod
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
$(INSTALLED)/certs: $(wildcard test/data/Makefile \
 test/data/clientcert/Makefile) | $(INSTALLED)
	if [ "$<" ]; then $(MAKE) -C $(dir $<); fi
	if [ "$(word 2, $+)" ]; then $(MAKE) -C $(dir $(word 2, $+)); fi
	touch $@
env:
ifeq ($(SHOWENV),1)
	$@
else
	$(MAKE) SHOWENV=1 $@
endif
.FORCE:
.PHONY: tests push pull status commit
