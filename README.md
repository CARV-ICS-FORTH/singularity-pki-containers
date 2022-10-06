# singularity-pki-containers

Proof of concept that singularity containers can be signed with PKI certificates

## Acknowledgements

This work was derived from [PMIx Docker Swarm Toy Box by Josh Hursey](https://github.com/jjhursey/pmix-swarm-toy-box).

We thankfully acknowledge the support of the European Commission and the Greek General Secretariat for Research and Innovation under the EuroHPC Programme through project DEEP-SEA (GA-955606). National contributions from the involved state members (including the Greek General Secretariat for Research and Innovation) match the EuroHPC funding.

# Purpose

This software is a collection of scripts and docker images used to deploy containers over one or multiple physical hosts for developing distributed software. It uses docker to build containers and and docker swarm to create an overlay network to connect these containers together in order to simulate a cluster. The initial use was for developing and testing OpenMPI and PMIx.
