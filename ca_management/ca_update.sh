#!/bin/bash

SCRIPT=$(readlink -f $0)
SCRIPT_PATH=`dirname $SCRIPT`
source ${SCRIPT_PATH}/ca_functions.sh
source ${SCRIPT_PATH}/config.sh

# Handle expired certificates and clean up database
ca_handle_expired_certs () {
        local IFS=$'\n'

        local EXPIRED_USER_CERTS=`cat ${CRL_DIR}/index | grep "\<E\>" | \
                                  awk -F"OU=Users/CN=" '{print $2}'`

        local EXPIRED_HOST_CERTS=`cat ${CRL_DIR}/index | grep "\<E\>" | \
                                  awk -F"OU=Hosts/CN=" '{print $2}'`
	local CERTFILE=""
	local CERTLINK=""
	local PUBFILE=""

	# Delete expired user certificates, we'll re-create them
	# as part of the syncing process
        for i in ${EXPIRED_USER_CERTS}; do
		echo Deleting expired certificate for user ${i}
		ca_purge_certificate_data ${i}
        done

        for i in ${EXPIRED_HOST_CERTS}; do
		echo Deleting expired host certificate for ${i}
		ca_purge_certificate_data ${i}_host
        done

	# Purge expired certificates from Database
        mv ${CRL_DIR}/index ${CRL_DIR}/index.old
	cat ${CRL_DIR}/index.old | grep -v "\<E\>" > /tmp/takis > ${CRL_DIR}/index

	# For host certificates we need to manualy re-generate them
#	for i in ${EXPIRED_HOST_CERTS}; do
#		echo Re-generating host certificates for ${i}
#		ca_gen_host_cert ${i}
#	done
}

# Generate updated CRLs based on the updated database
# and uploade them to the server
update_crls () {
        echo "Re-generating CRLs"
        ca_gen_crl
        # TODO
#        echo "Upladed renewed CRLs to web"
}

# Update CRLs to account for expired / revoked certificates

# Update database to account for expired certificates
ca_update_crl

ca_handle_expired_certs

update_crls
