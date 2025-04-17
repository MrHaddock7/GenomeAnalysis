#!/bin/bash -l
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 6
#SBATCH -t 15:00 --qos=short
#SBATCH -J dna_assembly_check_quast

module load bioinfo-tools
module load samtools

samtools index /home/haddock/private/Genome_analysis/GenomeAnalysis/data/mapped_outputs/DV3.paired.sorted.bam &
samtools index /home/haddock/private/Genome_analysis/GenomeAnalysis/data/mapped_outputs/HP126.paired.sorted.bam & 
samtools index /home/haddock/private/Genome_analysis/GenomeAnalysis/data/mapped_outputs/R7.paired.sorted.bam &

wait
