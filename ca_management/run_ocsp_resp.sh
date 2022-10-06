#!/bin/bash

SCRIPT=$(readlink -f $0)
SCRIPT_PATH=`dirname $SCRIPT`
source ${SCRIPT_PATH}/ca_functions.sh
source ${SCRIPT_PATH}/config.sh
PID=""

function quit () {
	kill ${PID}
	exit
}

trap quit EXIT SIGINT SIGTERM

while true; do
	openssl ocsp -index ${CRL_DIR}/index -port ${OCSP_RESP_PORT} -rsigner ${CERT_DIR}/ocsp_host.pem -rkey ${PRIV_KEY_DIR}/ocsp_host.key -CA ${CERT_DIR}/ca.pem -text -out /tmp/ocsp-log.txt &
	PID=$!
	echo New responder PID: ${PID}
	sleep 1
	inotifywait --event CLOSE ${CRL_DIR}/index
	kill ${PID}
done
