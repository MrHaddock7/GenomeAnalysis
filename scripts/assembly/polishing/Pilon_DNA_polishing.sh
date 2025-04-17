#!/bin/bash -l
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 15
#SBATCH -t 45:00
#SBATCH -J DNA_Mapping
#SBATCH --output=%x.%j.out

BAM_OUTPUT='/home/haddock/private/Genome_analysis/GenomeAnalysis/data/mapped_outputs/'
FLYE_INPUT='/home/haddock/private/Genome_analysis/GenomeAnalysis/analyses/01_preprocessing/09-04-Flye_dna_assembly/'
ILLUMINA_INPUT='/home/haddock/private/Genome_analysis/GenomeAnalysis/analyses/01_preprocessing/02-04-trimomatic_dna/'

# Load modules
module load bioinfo-tools
module load Pilon

