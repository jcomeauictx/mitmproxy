SHELL := /bin/ash
WHICH := type -p
SCRIPTS := $(shell find . -type f -name '*.py')
LINT := $(SCRIPTS:.py=.pylint)
build: setup.py .installed/python3 $(HOME)/.abuild
	python3 $<
$(HOME)/.abuild: | /etc/alpine-release
	abuild-keygen -an
.installed/python3: .installed
	if [ "! $(WHICH) $(@F)"	]; then \
	 sudo apk add $(@F); \
	fi
	touch $@
.installed/py3-%: .installed
	sudo apk add $(@F)
	touch $@
.installed:
	mkdir $@
%.pylint: %.py .installed/py3-pylint
	pylint $<
pylint: $(LINT)
pip_install: .installed/py3-pip
	pip --verbose install --force-reinstall \
	 git+https://github.com/jcomeauictx/mitmproxy@alpine-ish	
