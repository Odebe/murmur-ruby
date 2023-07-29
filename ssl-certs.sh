#!/bin/bash

# =============================================================================
# ssl-certs.sh - Self signing SSL certificates
#
# Author: Steve Shreeve <steve.shreeve@gmail.com>
#   Date: Dec 17, 2022
# =============================================================================

# Use https://gist.github.com/shreeve/3358901a26a21d4ddee0e1342be7749d
# See https://gist.github.com/fntlnz/cf14feb5a46b2eda428e000157447309

# variables
name="Ruby Murmur."
base="github.com"
root="root"
myip="$(ifconfig | awk '/inet / { print $2 }' | grep -v -E "^127\." | head -1)"

# create root key and certificate
openssl genrsa -out "${root}.key" 3072
openssl req -x509 -nodes -sha256 -new -key "${root}.key" -out "${root}.crt" -days 731 \
  -subj "/CN=Custom Root" \
  -addext "keyUsage = critical, keyCertSign" \
  -addext "basicConstraints = critical, CA:TRUE, pathlen:0" \
  -addext "subjectKeyIdentifier = hash"

# create our key and certificate signing request
openssl genrsa -out "${base}.key" 2048
openssl req -sha256 -new -key "${base}.key" -out "${base}.csr" \
  -subj "/CN=*.${base}/O=${name}/OU=$(whoami)@$(hostname) ($(/usr/bin/id -F))" \
  -reqexts SAN -config <(echo "[SAN]\nsubjectAltName=DNS:${base},DNS:*.${base},IP:127.0.0.1,IP:${myip}\n")

# create our final certificate and sign it
openssl x509 -req -sha256 -in "${base}.csr" -out "${base}.crt" -days 731 \
  -CAkey "${root}.key" -CA "${root}.crt" -CAcreateserial -extfile <(cat <<END
    subjectAltName = DNS:${base},DNS:*.${base},IP:127.0.0.1,IP:${myip}
    keyUsage = critical, digitalSignature, keyEncipherment
    extendedKeyUsage = serverAuth
    basicConstraints = CA:FALSE
    authorityKeyIdentifier = keyid:always
    subjectKeyIdentifier = none
END
)

## update the macOS trust store (TODO: add other operating systems)
#sudo /usr/bin/security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "${root}.crt"

# review files
echo "--"; openssl x509 -in "${root}.crt" -noout -text
echo "--"; openssl req  -in "${base}.csr" -noout -text
echo "--"; openssl x509 -in "${base}.crt" -noout -text
echo "--";

mv "${root}.crt" 'run/server.ca'
mv "${base}.key" 'run/server.key'
mv "${base}.crt" 'run/server.cert'

mv "${root}.key" 'run/root_ca.key'
