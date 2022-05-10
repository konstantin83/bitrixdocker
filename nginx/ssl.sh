export SITE_NAME=ms.local

openssl req -x509 -out $SITE_NAME.crt -keyout $SITE_NAME.key \
  -newkey rsa:2048 -nodes -sha256 \
  -subj '/CN=$SITE_NAME' -extensions EXT -config <( \
   printf "[dn]\nCN=$SITE_NAME\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:$SITE_NAME\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")