# singularity-pki-containers

Proof of concept that singularity containers can be signed with PKI certificates

## Acknowledgements

This work was derived from [PMIx Docker Swarm Toy Box by Josh Hursey](https://github.com/jjhursey/pmix-swarm-toy-box).

We thankfully acknowledge the support of the European Commission and the Greek General Secretariat for Research and Innovation under the EuroHPC Programme through project DEEP-SEA (GA-955606). National contributions from the involved state members (including the Greek General Secretariat for Research and Innovation) match the EuroHPC funding.

# Purpose

This software is a collection of scripts that create a PKI based Certificate Authority. Then using this CA we can create certificates and revoke,validate and verify them. Then we use these certificates to sign singularity container images and verify them after, similar to how singularity containers are signed and verified with PGP certificates.

## Prerequisites

* SSH with SSH keys properly set up for seamless SSH connections between the hosts without the use of passwords.
* Docker Engine must be installed on all hosts. (https://docs.docker.com/engine/install/)
* Docker group must be created on all hosts and the user who runs CaDiSa must be a member on docker group in each host.
* If you want to run on multiple hosts, the location from where you run CaDiSa must be a shared location between all hosts eg NFS and make sure the local root users can have access to this shared folder, because docker runs with superuser privileges.

## General structure

Folder "ca_management" contains scripts that create a Certificate Authority and run an OSCP server so that client certificates can be verified. It also contains scripts for certificate verification.

sif_sign.sh signs a singularity image using a client's private key.
```
./sif_sign.sh <SINGULARITY_IMAGE> <_CLIENT_PRIVATE_KEY>
```
sif_verify.sh extracts the signature from a signed singularity image and checks for the validity of the client certificate using the OSCP server.
```
./sif_verify.sh <SINGULARITY_IMAGE> <_CLIENT_PUBLIC_CERTIFICATE>
```
In order for the scripts to work correctly, verify_cert.sh from folder ca_management has to be on the same directory as sif_verify.sh

slurm_singularity_verify_and_run_pki.sh is a  example slurm script, with a batch job to verify two singularity images and then run them. One image is not signed, the other is. It is only meant as an exaple for helping users writing their own scripts. The files used in this example are:

* lolcow.sif: an unsigned singularity image file
* lolcow_signed_pki.sif: the file as above, but after it was signed using vavouris.key
* sif_sign.sh: the signing script
* sif_verify.sh: the verification script
* vavouris.key: private key, created from the CA
* vavouris.pem: public key, created from the CA
* verify_cert.sh: verification script

For installation and use of the Certificate Authority scripts, please read the README inside "ca_management" folder.


