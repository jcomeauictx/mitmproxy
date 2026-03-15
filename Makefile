SHELL := /bin/ash
WHICH := type -p
build: setup.py .installed/python3 $(HOME)/.abuild
	python3 $<
$(HOME)/.abuild: | /etc/alpine-release
	abuild-keygen -an
.installed/python3:
	if [ "! $(WHICH) $(@F)"	]; then \
	 sudo apk add $(@F); \
	fi
	touch $@
