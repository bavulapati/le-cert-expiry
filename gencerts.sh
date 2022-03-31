#!/bin/sh
openssl genrsa -out root1.key.pem 4096
openssl req -config root1.cnf \
      -key root1.key.pem \
      -new -x509 \
      -days 1 \
      -sha256 \
      -extensions v3_ca \
      -out root1.cert.pem

openssl req -config root2.cnf \
      -key root2.key.pem \
      -new -x509 \
      -days 7300 \
      -sha256 \
      -extensions v3_ca \
      -out root2selfsigned.cert.pem

openssl genrsa -out root2.key.pem 4096
openssl req -config root2.cnf \
      -new -sha256 \
      -key root2.key.pem \
      -out root2.csr.pem
openssl x509 -req \
      -CA root1.cert.pem \
      -CAkey root1.key.pem \
      -CAcreateserial \
      -extfile root2.cnf \
      -extensions v3_ca \
      -days 7300 \
      -sha256 \
      -in root2.csr.pem \
      -out root2.cert.pem

openssl genrsa -out intermediate.key.pem 4096
openssl req -config intermediate.cnf \
      -new -sha256 \
      -key intermediate.key.pem \
      -out intermediate.csr.pem
openssl x509 -req \
      -CA root2.cert.pem \
      -CAkey root2.key.pem \
      -CAcreateserial \
      -extfile intermediate.cnf \
      -extensions v3_intermediate_ca \
      -days 3650 \
      -sha256 \
      -in intermediate.csr.pem \
      -out intermediate.cert.pem

openssl genrsa -out server.key.pem 4096
openssl req -config server.cnf \
      -new -sha256 \
      -key server.key.pem \
      -out server.csr.pem
openssl x509 -req \
      -CA intermediate.cert.pem \
      -CAkey intermediate.key.pem \
      -CAcreateserial \
      -extfile server.cnf \
      -extensions server_cert \
      -days 375 \
      -sha256 \
      -in server.csr.pem \
      -out server.cert.pem
