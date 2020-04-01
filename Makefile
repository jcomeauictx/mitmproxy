PWD ?= $(CURDIR)
PATH := $(PWD)/venv/bin:$(PATH)
export
shell: venv/bin/activate
	bash --rcfile $< -i
start: env
	mitmdump \
	 --listen-port=5888 \
	 --flow-detail 3 \
	 --set block_global=false
env:
	env
venv/bin/activate: dev.sh
	./$< || echo 'Must install python3-virtualenv (RedHat)' \
	 ' or python3-venv (Debian)' >&2; false
install: mitmproxy.service /etc/systemd/system
	envsubst '$$PWD$$USER' < $< | sudo tee /etc/systemd/system/$<
	sudo systemctl daemon-reload
	sudo systemctl enable mitmproxy
	sudo systemctl start mitmproxy
restart:
	sudo systemctl restart mitmproxy
