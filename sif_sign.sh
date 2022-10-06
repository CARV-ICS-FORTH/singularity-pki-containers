#!/bin/bash

# Sanity checks
if [[  -z  ${1} ]]; then
	echo "No image provided"
	exit -1
fi

file ${1} | grep singularity &> /dev/null
#if [[ $? != 0 ]]; then
#	echo "Unrecognized file format"
#	exit -2
#fi

if [[ -z ${2} ]]; then
	echo "No private  key provided"
	exit -3
fi

cat ${2} | grep "BEGIN PRIVATE KEY" &> /dev/null
if [[ $? !=  0 ]]; then
	echo "Unrecognized key format (expected  PEM)"
	exit -4
fi

SIF_IDS=$(singularity sif list ${1} | grep "|" |  grep -v "TYPE" | awk '{print $1}')

TMP_FILE=$(mktemp /tmp/sif-sign.XXXXXX)
function cleanup {
	rm ${TMP_FILE} &> /dev/null
	rm ${TMP_FILE}.* &> /dev/null
}
trap cleanup EXIT

# Put all object hashes to TMP_FILE, if a signature object already exists exit
for i in $SIF_IDS; do
	OBJ_HASH=$(singularity sif dump $i ${1} | sha256sum | awk '{print $1}')
        singularity sif info $i ${1} | grep "BAFECAFEBEBEBEBEBAFECAFEBEBEBEBEBAFECAFE" &> /dev/null
        if [[ $? == 0 ]]; then
		echo "Image already signed"
		exit -5
	fi
	echo  $OBJ_HASH $i >> ${TMP_FILE}
done

# Sign TMP_FILE
openssl dgst -sha256 -sign ${2} -out ${TMP_FILE}.signature ${TMP_FILE}

# Append TMP_FILE's signature to SIF as a Generic/Raw object
singularity sif add ${1} ${TMP_FILE}.signature --datatype 5 --filename "vavouris" --signentity "BAFECAFEBEBEBEBEBAFECAFEBEBEBEBEBAFECAFE" --signhash 1
