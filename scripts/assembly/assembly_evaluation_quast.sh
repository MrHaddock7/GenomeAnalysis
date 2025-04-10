#!/bin/bash -l
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 6
#SBATCH -t 15:00 --qos=short
#SBATCH -J dna_assembly_check_quast
#SBATCH --mail-type=ALL
#SBATCH --mail-user villew7@gmail.com
#SBATCH --output=%x.%j.out

OUTPUT='/home/haddock/private/Genome_analysis/GenomeAnalysis/analyses/02_assembly/10-04-quast_longreads'
INPUT_PATH='/home/haddock/private/Genome_analysis/GenomeAnalysis/analyses/01_preprocessing/09-04-Flye_dna_assembly'
REFRENCE_PATH='/home/haddock/private/Genome_analysis/GenomeAnalysis/data/raw_data/reference_genome'

# Load modules
module load bioinfo-tools
module load quast

python '/sw/bioinfo/quast/5.0.2/rackham/bin/quast.py' -o "${OUTPUT}/R7" -r "${REFRENCE_PATH}/R7_genome.fasta" -t 2 "${INPUT_PATH}/R7/assembly.fasta" &
python '/sw/bioinfo/quast/5.0.2/rackham/bin/quast.py' -o "${OUTPUT}/DV3" -r "${REFRENCE_PATH}/DV3_genome.fasta" -t 2 "${INPUT_PATH}/DV3/assembly.fasta" &
python '/sw/bioinfo/quast/5.0.2/rackham/bin/quast.py' -o "${OUTPUT}/HP126" -r "${REFRENCE_PATH}/HP126_genome.fasta" -t 2 "${INPUT_PATH}/HP126/assembly.fasta" &

wait
