SHELL := /bin/bash
default: display
client.key: Makefile
	openssl genrsa -out $@ 2048
client.req: client.key
	openssl req -key $< -new -out $@
client.crt: client.req | $(HOME)/.mitmproxy/mitmproxy.ca.pem
	openssl x509 -req -days 1000 -in $< \
	 -CA $| \
	 -CAKey $| \
	 -set-serial 00001 \
	 -out $@ \
	 -extensions ssl_client
client.crt: client.req
	openssl x509 -req -days 365 -in $< \
	 -signkey $(<:.req=.key) \
	 -out $@ \
	 -extfile $(@:.crt=.cnf) \
	 -extensions ssl_client
127.0.0.1.pem: client.key client.crt
	cat $+ > $@
display: 127.0.0.1.pem
	openssl x509 -text -noout -in $<
