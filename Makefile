SHELL := /bin/bash
PWD ?= $(CURDIR)
PATH := $(PWD)/venv/bin:$(PATH)
PORT ?= 8080
LOGDIR ?= /var/log/mitmproxy
CONFDIR ?= $(HOME)/.mitmproxy
TESTSERV ?= ifconfig.co
SCHEME ?= https
ALLOWED := $(shell cat $(CONFDIR)/serverfilter.txt 2>/dev/null)
EMPTY :=
ifeq ($(ALLOWED),)
	ALLOWED := [^.]+[.][^.]+
endif
SPACE := $(EMPTY) $(EMPTY)
FILTER := ^([^.]+[.])*($(subst $(SPACE),|,$(ALLOWED))):[0-9]+$
export
nonroot:
	if [ "$(USER)" = "root" ]; then \
	 echo Cannot make $(TARGET) as root >&2; false; \
	fi
shell: venv/bin/activate
	$(MAKE) TARGET=$@ nonroot
	bash --rcfile $< -i
launch: venv/bin/activate env
	$(MAKE) TARGET=$@ nonroot
	mitmdump \
	 --listen-port=$(PORT) \
	 --flow-detail 3 \
	 --set block_global=false \
	 --allow-hosts '$(FILTER)' \
	 --block-not-ignore \
	 --filter-http \
	 --script filter.py \
	 >>$(LOGDIR)/dumplog \
	 2>>$(LOGDIR)/errorlog
env:
	env
venv/bin/activate: dev.sh
	$(MAKE) TARGET=$@ nonroot
	./$< || (echo 'Must install python3-virtualenv (RedHat)' \
	 ' or python3-venv (Debian)' >&2; false)
install: mitmproxy.service /etc/systemd/system venv/bin/activate
	$(MAKE) TARGET=$@ nonroot
	envsubst '$$LOGDIR$$PWD$$USER' < $< \
	 | sudo tee /etc/systemd/system/$<
	sudo systemctl daemon-reload
	$(MAKE) enable
	$(MAKE) start
start restart status enable disable stop:
	sudo systemctl $@ mitmproxy.service
/tmp/localcert.txt:
	echo quit | openssl s_client \
	 -showcerts \
	 -servername mitm.it \
	 -connect localhost:$(PORT) >$@
curltest: /tmp/localcert.txt
	curl --proxy http://localhost:$(PORT) \
	 --cacert $< $(SCHEME)://$(TESTSERV)
