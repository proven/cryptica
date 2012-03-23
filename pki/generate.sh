#/bin/sh

echo "Deleting old test PKI..."

rm -rf ./data

echo "Creating new test PKI..."

mkdir ./data
mkdir ./data/certs
mkdir ./data/private

touch ./data/database
echo '100001' > data/serial

echo "Creating new CA..."

openssl req -config ./openssl.conf -passout pass:test -new -x509 -extensions v3_ca -out ./data/certs/cacert.pem -keyout ./data/private/cakey.pem

echo "Creating new server key..."

openssl req -config ./openssl.conf -new -nodes -out ./data/certs/serverreq.pem -keyout ./data/private/serverkey.pem

echo "Signing new server key..."

openssl ca -config ./openssl.conf -subj "/CN=test_server" -batch -key test -out ./data/certs/servercert.pem -infiles ./data/certs/serverreq.pem
rm ./data/certs/serverreq.pem

echo "Creating new client key..."

openssl req -config ./openssl.conf -new -nodes -out ./data/certs/clientreq.pem -keyout ./data/private/clientkey.pem

echo "Signing new client key..."

openssl ca -config ./openssl.conf -subj "/CN=test_client" -batch -key test -out ./data/certs/clientcert.pem -infiles ./data/certs/clientreq.pem
rm ./data/certs/clientreq.pem
