# Simple Certificate authority and certificate validation scritps

The scripts in this folder create all the necessary certificates for a PKI based CA and provide basic CA functions.

## Setting Up

First one has to edit config.sh in order to input the necessary information about the CA. More about the necessary information and what it means.
* https://ldapwiki.com/wiki/Best%20Practices%20For%20LDAP%20Naming%20Attributes
* https://frasertweedale.github.io/blog-redhat/posts/2018-03-15-x509-dn-attribute-encoding.html


The example below is partially filled with information for creating a CA for the FORTH-ICS CARV LAboratory.

The first section is about the Root Distinguished Name Information, the Root Certificate.
```
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
CA_HOST="<ip_of_CA_host_node>" 
```
Next, we input where we want the CA to store its ceritficates and files. In this example we have a user on the node called "carvca" and we've setup the ca to use this user's home directory, since the CA processs is going to be run by this user.
```
####################
# CA CONFIGURATION #
###################

#
# Directories
#

CERT_DIR=/home/carvca/ca/certs #this is where new public certificates are stored
PRIV_KEY_DIR=/home/carvca/ca/keys # this is where new private certificates are stored
CRL_DIR=/home/carvca/ca/crl # CA Database with index and latest revocation list
CSR_DIR=/home/carvca/ca/csr 
BUNDLE_DIR=/home/carvca/ca/bundles
```
The next session is cryptography settings for key generation and validity period which really is not to be tampered with
```
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
```
After configuration we use two scripts create the necessary file structure and the initial Root certificates and OCSP certificates.
We run the script
```
./ca_init.sh
```
which creates the Root Certificate and the necessary file structure and then the script
```
./gen_ocsp_resp_cert.sh
```
Which creates the certificate for the OCSP responder which we'll query for the validity of the certificates.


We can create either host certificates for nodes or user certificates for users using the script
```
./gen_host_cert.sh <HOSTNAME>
```
or
```
./gen_user_cert.sh <USERNAME>
```
In order to view the current database of certificates created we read the <CRL_DIR>/index eg
```
cat /home/carvca/ca/crl/index
```
We start the OCSP response server with the script
```
./run_ocsp_resp.sh
```
Then we can verify certificates using the script
```
./verify_cert.sh <PUBLIC_CERTIFICATE>
```
When we want to revoke a certificate we use two scripts, one for host certificates and on for user certificates:
```
./revoke_host_cert.sh <HOSTNAME>
./revoke_user_cert.sh <USERNAME>
```
