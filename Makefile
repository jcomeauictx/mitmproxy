PWD ?= $(CURDIR)
PATH := $(PWD)/venv/bin:$(PATH)
PORT ?= 8080
LOGDIR ?= /var/log/mitmproxy
CONFDIR ?= $(HOME)/.mitmproxy
export
shell: venv/bin/activate
	bash --rcfile $< -i
start: venv/bin/activate env
	mitmdump \
	 --listen-port=$(PORT) \
	 --flow-detail 3 \
	 --set block_global=false \
	 --script filter.py \
	 >>$(LOGDIR)/dumplog \
	 2>>$(LOGDIR)/errorlog
env:
	env
venv/bin/activate: dev.sh
	./$< || (echo 'Must install python3-virtualenv (RedHat)' \
	 ' or python3-venv (Debian)' >&2; false)
install: mitmproxy.service /etc/systemd/system venv/bin/activate
	envsubst '$$LOGDIR$$PWD$$USER' < $< \
	 | sudo tee /etc/systemd/system/$<
	sudo systemctl daemon-reload
	sudo systemctl enable mitmproxy
	sudo systemctl start mitmproxy
restart:
	sudo systemctl restart mitmproxy
/tmp/localcert.txt:
	echo quit | openssl s_client \
	 -showcerts \
	 -servername mitm.it \
	 -connect localhost:$(PORT) >$@
curltest: /tmp/localcert.txt
	curl --proxy http://localhost:$(PORT) \
	 --cacert $< https://ifconfig.co
status:
	systemctl status mitmproxy
