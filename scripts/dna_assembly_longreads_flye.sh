#!/bin/bash -l
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 15
#SBATCH -t 3:00:00
#SBATCH -J dna_assembly_flye
#SBATCH --mail-type=ALL
#SBATCH --mail-user villew7@gmail.com
#SBATCH --output=%x.%j.out

OUTPUT='/home/haddock/private/Genome_analysis/GenomeAnalysis/analyses/01_preprocessing/09-04-Flye_dna_assembly'
INPUT_PATH='/home/haddock/private/Genome_analysis/GenomeAnalysis/analyses/01_preprocessing/01-04-porechop_long_dna'

# Load modules
module load bioinfo-tools
module load Flye

# Copy to temp dir
cp "${INPUT_PATH}/01-04-DNA_longread_66trimmed.fastq.gz" $SNIC_TMP
cp "${INPUT_PATH}/01-04-DNA_longread_72trimmed.fastq.gz" $SNIC_TMP
cp "${INPUT_PATH}/01-04-DNA_longread_81trimmed.fastq.gz" $SNIC_TMP

cd $SNIC_TMP

# Assembly

flye --nano-raw "01-04-DNA_longread_66trimmed.fastq.gz" --out-dir "${OUTPUT}/66" --threads 5 &

flye --nano-raw "01-04-DNA_longread_72trimmed.fastq.gz" --out-dir "${OUTPUT}/72" --threads 5 &

flye --nano-raw "01-04-DNA_longread_81trimmed.fastq.gz" --out-dir "${OUTPUT}/81" --threads 5 &

wait
