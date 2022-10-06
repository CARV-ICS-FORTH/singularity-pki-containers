# singularity-pki-containers

Proof of concept that singularity containers can be signed with PKI certificates

## Acknowledgements

This work was derived from [PMIx Docker Swarm Toy Box by Josh Hursey](https://github.com/jjhursey/pmix-swarm-toy-box).

We thankfully acknowledge the support of the European Commission and the Greek General Secretariat for Research and Innovation under the EuroHPC Programme through project DEEP-SEA (GA-955606). National contributions from the involved state members (including the Greek General Secretariat for Research and Innovation) match the EuroHPC funding.

# Purpose

This software is a collection of scripts that create a PKI based Certificate Authority. Then using this CA we can create certificates and revoke,validate and verify them. Then we use these certificates to sign singularity container images and verify them after, similar to how singularity containers are signed and verified with PGP certificates.
