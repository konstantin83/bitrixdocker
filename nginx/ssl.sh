# export SITE_NAME="pas.loc"

export $(grep -v '^#' ../.env | xargs)

# openssl req -x509 -out $SITE_NAME.crt -keyout $SITE_NAME.key \
mkdir ssl
openssl req -x509 -out ssl/public.crt -keyout ssl/private.key \
  -newkey rsa:2048 -nodes -sha256 \
  -subj '/CN=$SITE_NAME' -extensions EXT -config <( \
   printf "[dn]\nCN=$SITE_NAME\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:$SITE_NAME\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
