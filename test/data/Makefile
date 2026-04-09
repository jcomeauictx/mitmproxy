SUBJ ?= /C=AU/ST=Some-State/O=Internet Widgits Pty Ltd
all: serverkey.see testkey.pem
%.pem %.key: Makefile
	openssl req \
	 -x509 \
	 -newkey rsa:1024 \
	 -keyout $(@:.crt=.key) \
	 -out $@ \
	 -sha256 \
	 -days 3650 \
	 -nodes \
	 -subj "$(SUBJ)"
%.see: %.pem
	openssl x509 \
	 -in $< \
	 -noout \
	 -text
.PRECIOUS: %.pem %.key
