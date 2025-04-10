#!/bin/bash -l
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 6
#SBATCH -t 15:00 --qos=short
#SBATCH -J quality_long_reads_DNA_trimmed
#SBATCH --mail-type=ALL
#SBATCH --mail-user villew7@gmail.com
#SBATCH --output=%x.%j.out

OUTPUT='/home/haddock/private/Genome_analysis/GenomeAnalysis/analyses/01_preprocessing/10-04-fastqc_dna_longread_trimmed'
INPUT_PATH='/home/haddock/private/Genome_analysis/GenomeAnalysis/analyses/01_preprocessing/01-04-porechop_long_dna/'

# Load modules
module load bioinfo-tools
module load FastQC

# Execution

# DNA
for i in {66,72,81};
do 
   ( fastqc -o $OUTPUT --threads 2 "${INPUT_PATH}01-04-DNA_longread_${i}trimmed.fastq.gz" ) &
done

wait