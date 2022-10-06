#!/bin/bash
#SBATCH --job-name=singularity_verify_and_run_pki   	 # Job name
#SBATCH --mail-type=NONE				 # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=vavouris@ics.forth.gr    		 # Where to send mail	
#SBATCH --ntasks=1                   			 # Run on a single CPU
#SBATCH --mem=1gb                    			 # Job memory request
#SBATCH --time=00:00:30              			 # Time limit hrs:min:sec
#SBATCH --output=singularity_verify_and_run_pki%j.log  	 # Standard output and error log
pwd; hostname; date
cd /home1/private/vavouris/singularity-pki
pwd
echo "Testing singularity with a PKI signed and a non PKI signed container"
echo "First attempt should fail since the container is not signed with a PKI key"
./sif_verify.sh ./lolcow.sif ./vavouris.pem && ./lolcow.sif
echo "First attempt should succeed since the container is signed with a PKI key"
./sif_verify.sh ./lolcow_signed_pki.sif ./vavouris.pem && ./lolcow_signed_pki.sif
date
