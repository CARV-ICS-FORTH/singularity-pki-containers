#!/bin/bash

# Sanity checks  -o theos na ta kanei alla telos pantwn-
if [[  -z  ${1} ]]; then
	echo "No image provided"
	exit -1
fi

if [[ -z ${2} ]]; then
	echo "No user certificate provided"
	exit -5
fi

cat ${2} | grep "BEGIN CERTIFICATE" &> /dev/null
if [[ $? !=  0 ]]; then
	echo "Unrecognized certificate format (expected  PEM)"
	exit -6
fi

# Verify certificate chain
#TODO: Use intermediate certificate with the -untrusted option
#TODO: Verify using CRL
./verify_cert.sh ${2} &> /dev/null
if [[ $? != 0 ]]; then
	echo "CA signature verification on user certificate failed"
	exit -7
fi


SIF_IDS=$(singularity sif list ${1} | grep "|" |  grep -v "TYPE" | awk '{print $1}')

TMP_FILE=$(mktemp /tmp/sif-sign.XXXXXX)
function cleanup {
	rm ${TMP_FILE} &> /dev/null
	rm ${TMP_FILE}.* &> /dev/null
}
trap cleanup EXIT

# Dump signature object and put all other object hashes to TMP_FILE
# we should get the same contents on TMP_FILE as we did on sif_sign
for i in $SIF_IDS; do
	OBJ_HASH=$(singularity sif dump $i ${1} | sha256sum | awk '{print $1}')
	singularity sif info $i ${1} | grep "BAFECAFEBEBEBEBEBAFECAFEBEBEBEBEBAFECAFE" &> /dev/null
	if [[ $? == 0 ]]; then
		singularity sif dump $i ${1} > ${TMP_FILE}.signature
	else
		echo  $OBJ_HASH $i >> ${TMP_FILE}
	fi
done

if [[ -z ${TMP_FILE}.signature ]]; then
	echo "Could not retrieve hashes signature from sif"
	exit -9
fi

openssl x509 -pubkey -noout -in ${2}  > ${TMP_FILE}.pub
if [[ $? != 0 ]]; then
	echo "Could not extract public key from user certificate"
	exit -10
fi

openssl dgst -sha256 -verify ${TMP_FILE}.pub -signature ${TMP_FILE}.signature  ${TMP_FILE} &> /dev/null
if [[ $? != 0 ]]; then
	echo "Image verification failed"
	exit -11
else
	echo  "Image verification success"
fi

exit 0
