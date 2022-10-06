#!/bin/bash
SCRIPT=$(readlink -f $0)
SCRIPT_PATH=`dirname $SCRIPT`
source ${SCRIPT_PATH}/ca_functions.sh
source ${SCRIPT_PATH}/config.sh

SAVED_PWD=${PWD}
cd ${CRL_DIR}
mv index.old index
mv index.attr.old index.attr
mv serial.old serial
mv crlnumber.old crlnumber
cd ${SAVED_PWD}
