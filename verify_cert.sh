#!/bin/bash
SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPT=$(readlink -f ${BASH_SOURCE[0]})
SCRIPT_NAME=$(basename ${SCRIPT})
TMP_DIR=/tmp/${SCRIPT_NAME}_$$

if [[  -z  ${1} ]]; then
	echo "No certificate provided"
	exit -1
fi

mkdir ${TMP_DIR}

function cleanup () {
	rm -rf ${TMP_DIR}
}

trap cleanup EXIT SIGINT

#echo "Downloading CA certificate"

function download_ca () {
	# Download CA certificate
	CA_CERT=$(openssl x509 -in ${1} -text | grep "CA Issuers" | awk -F"URI:" '{print $2}')
	wget ${CA_CERT} -O ${TMP_DIR}/ca.pem &> /dev/null
	if [[ $? != 0 ]]; then
		echo "Couldn't download CA certificate"
		exit -2
	fi
}

function cert_chain_check () {
	echo "Verifying certificate chain and validity period"

	# Verify certificate chain and validity period
	openssl verify -verbose -CAfile ${TMP_DIR}/ca.pem ${1} &> ${TMP_DIR}/check1
	if [[ $? != 0 ]]; then
		CERT_STATUS=$(cat ${TMP_DIR}/check1 | grep "lookup" | awk -F"certificate " '{print $2}')
		if [[ ${CERT_STATUS} == "revoked" ]]; then
			echo "Certificate is revoked"
		elif [[ ${CERT_STATUS} == "has expired" ]]; then
			echo "Certificate has expired"
		else
			echo "Verification failed"
		fi
		exit -1
	fi
}

function cert_chain_check_with_crl () {
	echo "Falling back to revoction status check trough CRL"

	# Download CRL
	echo "Downloading CRL"
	CRL_URL=$(openssl x509 -in ${1} -text | grep -A3 "CRL Distribution Points" | grep URI | awk -F"URI:" '{print$2}')
	wget ${CRL_URL} -O ${TMP_DIR}/crl.pem &> /dev/null
	if [[ $? != 0 ]]; then
		echo "Couldn't download CRL"
		exit -3
	fi

	# Verify certificate chain, also using the downloaded CRL
	openssl verify -verbose -CAfile ${TMP_DIR}/ca.pem -CRLfile ${TMP_DIR}/crl.pem -crl_check ${1} &> ${TMP_DIR}/check2
	if [[ $? != 0 ]]; then
		CERT_STATUS=$(cat ${TMP_DIR}/check2 | grep "lookup" | awk -F"certificate " '{print $2}')
		if [[ ${CERT_STATUS} == "revoked" ]]; then
			echo "Certificate is revoked (CRL)"
		elif [[ ${CERT_STATUS} == "has expired" ]]; then
			echo "Certificate has expired (CRL)"
		elif [[ ${CERT_STATUS} == "CRL has expired" ]]; then
			echo "Expired CRL signature (or certificate)"
		else
			echo "Verification failed"
		fi
		exit -1
	else
		echo "Certificate is valid (CRL)"
		exit 0
	fi
}

function cert_revocation_check () {
	echo "Verifying certificate revocation status through OCSP"

	# Verify certificate's revocation status using OCSP
	OCSP_URI=$(openssl x509 -in ${1} -text | grep -A3 "Authority Information Access" | grep  OCSP | awk -F"URI:" '{print $2}')
	openssl ocsp -CAfile ${TMP_DIR}/ca.pem -issuer ${TMP_DIR}/ca.pem -cert ${1} -url ${OCSP_URI} -text 2> ${TMP_DIR}/ocsp_resp_err 1> ${TMP_DIR}/ocsp_resp
	if [[ $? == 0 ]]; then
		# We got a responce, check the certificate's status
		CERT_STATUS=$(cat ${TMP_DIR}/ocsp_resp | grep "Cert Status" | awk -F": " '{print $2}')
		if [[ ${CERT_STATUS} == "good" ]]; then
			echo "Certificate is valid (OCSP)"
			exit 0
		elif [[ ${CERT_STATUS} == "revoked" ]]; then
			echo "Certificate is revoked (OCSP)"
			exit -1
		fi
	# We either couldn't connect or the responce didn't contain any revocation data
	# try to figure out what happened
	else
		cat ${TMP_DIR}/ocsp_resp_err | grep "Error querying OCSP responder"
		if [[ $? == 0 ]]; then
			# We couldn't connect, fallback to the full certificate chain check
			# also using a downloaded CRL this time
			cert_chain_check_with_crl ${1}
		else
			cat ${TMP_DIR}/ocsp_resp_err | grep "Response Verify Failure"
			if [[ $? == 0 ]]; then
				echo "Certificate doesn't exist on CA's database or has expired (OCSP)"
				exit -1
			else
				# No idea what happened, fallback to the chain + CRL check
				cert_chain_check_with_crl ${1}
			fi
		fi
	fi
}

download_ca ${1}
cert_chain_check ${1}
cert_revocation_check ${1}
