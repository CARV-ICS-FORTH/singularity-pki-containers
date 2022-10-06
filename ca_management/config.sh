################
# ROOT DN INFO #
################

# Note that all of the DN fields below should be filled
ROOT_C="GR"
ROOT_ST="Crete"
ROOT_L="Heraklion"
ROOT_O="Foundation for Research and Technology"
ROOT_OU="ICS\/CARV"
ROOT_DESC="Computer Architecture and VLSI lab"
ROOT_PHONE="<changeme>"
ROOT_REG_ADDR="<changeme>"
ROOT_POSTAL_CODE="<changeme>"
ROOT_CA_CN="CA"
ROOT_MAIL="ca@carv_ca.ics.forth.gr"

# Used by LDAP scripts, don't modify
BASE_DN="OU=${ROOT_OU},O=${ROOT_O},L=${ROOT_L},ST=${ROOT_ST},C=${ROOT_C}"

ROOT_DOMAIN="ics.forth.gr"

# Used to distribute ca certificate,
# user bundles, the CRL and run the OCSP responder
CA_HOST="139.91.92.59"

####################
# CA CONFIGURATION #
###################

#
# Directories
#

CERT_DIR=/home/mick/Workspace/ca/certs
PRIV_KEY_DIR=/home/mick/Workspace/ca/keys
CRL_DIR=/home/mick/Workspace/ca/crl
CSR_DIR=/home/mick/Workspace/ca/csr
BUNDLE_DIR=/home/mick/Workspace/ca/bundles

#
# Crypto parameters
#

# Available types: rsa / ec
GENKEY_TYPE=ec

# For rsa only
GENKEY_LEN=2048

# For ecc
# Note: not all openssl curves are recognizable
# by ssh, an unknown curve will result ssh-unknown
# on ssh-keygen.
ECC_CURVE=secp256r1
ECPARAMS_FILE=${PRIV_KEY_DIR}/ecparams

# Check openssl's supported list
SIGN_MD=sha256

CA_DAYS="3650"
CERT_DAYS="365"

# For SSH CA key
SSH_CA_KEY_TYPE=ed25519

# OpenSSL temporary config file
OSSL_CNF=/tmp/ossl.cnf

# CRL distribution point
CRL_DIST_POINT="http://${CA_HOST}/ca/crl.pem"

# OCSP responder URL
OCSP_RESP_PORT=8888
OCSP_RESP_URL=http://${CA_HOST}:${OCSP_RESP_PORT}/

# CA Issuers URL
CA_ISSUERS_URL="http://${CA_HOST}/ca/ca.pem"

SCDIR=${SCRIPT_PATH}
