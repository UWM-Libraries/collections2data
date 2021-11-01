#!/bin/bash
#SBATCH --mem-per-cpu=3999
#SBATCH --array=196-200
#SBATCH --overcommit
#SBATCH --ntasks-per-core=4
#SBATCH --output=scheduler_output/slurm-%A_%a.out
source ~/Data/conda_install/bin/activate azure
export SSL_CERT_DIR=/usr/pkg/etc/openssl/certs
export SSL_CERT_FILE=/usr/pkg/etc/openssl/certs/ca-certificates.crt


readarray audiofiles < audio-files.txt
readarray transcript_names < transcript_names.txt 
python azure_transcript.py ${audiofiles[${SLURM_ARRAY_TASK_ID}]}

grep RECOGNIZED scheduler_output/slurm-${SLURM_JOB_ID}_${SLURM_ARRAY_TASK_ID}.out | cut -d \" -f 2 > ../rshiny_demo/transcripts/${transcript_names[${SLURM_ARRAY_TASK_ID}]}

