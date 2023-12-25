LOGDIR := $(HOME)/mitmproxy/log
CONFDIR := $(HOME)/mitmproxy/conf
PORT := 5888
export
%:
	$(MAKE) -f Makefile $@
