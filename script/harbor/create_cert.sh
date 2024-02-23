set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source ../../conf/config.sh

exec > >(tee -a "$logfile") 2>&1
echo "$date_format"

#!/bin/bash


domainname="${harbor_hostname}"
gencertdir="/etc/harbor/cert"


# 生成证书的路径
mkdir -p $gencertdir

openssl genrsa -out ca.key 4096

openssl req -x509 -new -nodes -sha512 -days 36500 \
 -subj "/C=CN/ST=GuangDong/L=GuangZhou/O=example/OU=Personal/CN=$domainname" \
 -key ca.key \
 -out ca.crt


openssl genrsa -out $domainname.key 4096

openssl req -sha512 -new \
    -subj "/C=CN/ST=GuangDong/L=GuangZhou/O=example/OU=Personal/CN=$domainname" \
    -key $domainname.key \
    -out $domainname.csr


cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=$domainname
DNS.2=www.$domainname
EOF



openssl x509 -req -sha512 -days 36500 \
    -extfile v3.ext \
    -CA ca.crt -CAkey ca.key -CAcreateserial \
    -in $domainname.csr \
    -out $domainname.crt

openssl x509 -inform PEM -in $domainname.crt -out $domainname.cert




mkdir -p /etc/docker/certs.d/$domainname/
  
/bin/cp $domainname.cert /etc/docker/certs.d/$domainname/
/bin/cp $domainname.key /etc/docker/certs.d/$domainname/
/bin/cp ca.crt /etc/docker/certs.d/$domainname/
/bin/cp ca.crt /etc/pki/ca-trust/source/anchors

update-ca-trust extract

systemctl restart docker


# openssl req -x509 -sha256 -newkey rsa:4096 -keyout ca.key -out ca.crt -days 35600 -nodes -subj '/CN=Fern Cert Authority'
# openssl req -new -newkey rsa:4096 -keyout server.key -out server.csr -nodes -subj "/CN=${harbor_hostname}"
# openssl x509 -req -sha256 -days 365 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt

/bin/cp *.crt *.key $domainname.crt $domainname.key $domainname.cert /etc/harbor/cert

