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
module load bwa
module load samtools

# Index the nanopore assembly
bwa index "${FLYE_INPUT}DV3/DV3_assembly_flye.fasta" &
bwa index "${FLYE_INPUT}HP126/HP126_assembly_flye.fasta" &
bwa index "${FLYE_INPUT}R7/R7_assembly_flye.fasta" &

wait

# Align the illumina reads to the nanopore assembly

cd $SNIC_TMP

bwa mem -t 5 "${FLYE_INPUT}DV3/DV3_assembly_flye.fasta" "${ILLUMINA_INPUT}shortread_dna_80_1.trimmed.fastq.gz" "${ILLUMINA_INPUT}shortread_dna_80_2.trimmed.fastq.gz" > "${SNIC_TMP}/DV3.paired.sam" &
bwa mem -t 5 "${FLYE_INPUT}HP126/HP126_assembly_flye.fasta" "${ILLUMINA_INPUT}shortread_dna_65_1.trimmed.fastq.gz" "${ILLUMINA_INPUT}shortread_dna_65_2.trimmed.fastq.gz" > "${SNIC_TMP}/HP126.paired.sam" &
bwa mem -t 5 "${FLYE_INPUT}R7/R7_assembly_flye.fasta" "${ILLUMINA_INPUT}shortread_dna_71_1.trimmed.fastq.gz" "${ILLUMINA_INPUT}shortread_dna_71_2.trimmed.fastq.gz" > "${SNIC_TMP}/R7.paired.sam" &

wait

# Convert SAM output to BAM

samtools view -bSh DV3.paired.sam > DV3.paired.unsorted.bam &
samtools view -bSh HP126.paired.sam > HP126.paired.unsorted.bam &
samtools view -bSh R7.paired.sam > R7.paired.unsorted.bam &

wait

# Sort BAM files

samtools sort DV3.paired.unsorted.bam -o "${BAM_OUTPUT}DV3.paired.sorted.bam" &
samtools sort HP126.paired.unsorted.bam -o "${BAM_OUTPUT}HP126.paired.sorted.bam" &
samtools sort R7.paired.unsorted.bam -o "${BAM_OUTPUT}R7.paired.sorted.bam" &

wait