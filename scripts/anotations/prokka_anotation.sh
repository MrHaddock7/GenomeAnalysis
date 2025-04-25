#!/bin/bash -l
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 15
#SBATCH -t 30:00
#SBATCH -J annotation_prokka
#SBATCH --mail-type=ALL
#SBATCH --mail-user villew7@gmail.com
#SBATCH --output=%x.%j.out

OUTPUT='/home/haddock/private/Genome_analysis/GenomeAnalysis/analyses/03_anotation'
INPUT_PATH='/home/haddock/private/Genome_analysis/GenomeAnalysis/data/mapped_outputs'

module load bioinfo-tools
module load prokka

prokka --cpus 5 --outdir "${OUTPUT}/HP126" --prefix "HP126" --kingdom Bacteria "${INPUT_PATH}/HP126_pilon.fasta" &
prokka --cpus 5 --outdir "${OUTPUT}/R7" --prefix "R7" --kingdom Bacteria "${INPUT_PATH}/R7_pilon.fasta" &
prokka --cpus 5 --outdir "${OUTPUT}/DV3" --prefix "DV3" --kingdom Bacteria "${INPUT_PATH}/DV3_pilon.fasta" &

wait