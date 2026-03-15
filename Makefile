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
.installed/py3-openssl: .installed
	sudo apk add $(@F)
	touch $@
.installed/pylint: .installed
	sudo apk add py3-pylint
	touch $@
.installed:
	mkdir $@
%.pylint: %.py .installed/pylint
	pylint $<
pylint: $(LINT)
