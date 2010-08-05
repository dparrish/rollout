CACONF = -config openssl.cnf
CAKEY = private/ca.key
CACERT = private/cacert.pem

all:
	@echo "This isn't right"

ca: cadir ${CAKEY} ${CACERT}

cadir:
	@mkdir -p certs crl newcerts private
	@[ -f index.txt ] || touch index.txt
	@[ -f crlnumber ] || echo 01 > crlnumber

${CAKEY}:
	openssl genrsa -out $@ 1024

${CACERT}:
	openssl req ${CACONF} -new -batch -key ${CAKEY} -out careq.pem -extensions ca_cert
	openssl ca ${CACONF} -batch -create_serial -out $@ -days 1095 -batch -keyfile ${CAKEY} \
		-subj "/commonName=Rollout CA/countryName=AU" \
		-selfsign -extensions ca_cert -infiles careq.pem
	@rm careq.pem
	openssl x509 -in $@ -out cacert.crt

clean:
	rm -f serial* crlnumber newcerts/* private/* \
		index.txt* certs/*

server: ca
	openssl req ${CACONF} -new -newkey rsa:1024 -nodes -days 365 -out certreq.csr \
		-keyout certs/rolloutd.key -subj "/commonName=rolloutd/countryName=AU" \
		-extensions server_cert
	openssl ca ${CACONF} -in certreq.csr -out certs/rolloutd.pem -cert ${CACERT} \
		-keyfile ${CAKEY} -batch
	@rm -f certreq.csr

client: ca
	@if [ "x${HOSTNAME}" = "x" ]; then echo "Usage: make client HOSTNAME=<hostname>"; exit 1; fi
	@make certs/${HOSTNAME}.pem

certs/%.pem: HOSTNAME = ${notdir ${basename $@}}
certs/%.pem: ca
	openssl req ${CACONF} -new -newkey rsa:1024 -nodes -days 365 -out certreq.csr \
		-keyout certs/${HOSTNAME}.key -subj "/commonName=${HOSTNAME}/countryName=AU" \
		-extensions client_cert
	openssl ca ${CACONF} -in certreq.csr -out $@ -cert ${CACERT} -keyfile ${CAKEY} -batch
	@rm -f certreq.csr

verify: ca
	@if [ "x${CERT}" = "x" ]; then echo "Specify CERT=<filename>"; exit 1; fi
	@openssl verify -CAfile private/cacert.pem ${CERT}
