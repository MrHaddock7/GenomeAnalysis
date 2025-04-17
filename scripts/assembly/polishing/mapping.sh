#!/bin/bash -l
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 15
#SBATCH -t 45:00
#SBATCH -J DNA_Mapping_unpaired
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

bwa mem -t 5 "${FLYE_INPUT}DV3/DV3_assembly_flye.fasta" "${ILLUMINA_INPUT}shortread_dna_80_1un.trimmed.fastq.gz" "${ILLUMINA_INPUT}shortread_dna_80_2un.trimmed.fastq.gz" > "${SNIC_TMP}/DV3.unpaired.sam" &
bwa mem -t 5 "${FLYE_INPUT}HP126/HP126_assembly_flye.fasta" "${ILLUMINA_INPUT}shortread_dna_65_1un.trimmed.fastq.gz" "${ILLUMINA_INPUT}shortread_dna_65_2un.trimmed.fastq.gz" > "${SNIC_TMP}/HP126.unpaired.sam" &
bwa mem -t 5 "${FLYE_INPUT}R7/R7_assembly_flye.fasta" "${ILLUMINA_INPUT}shortread_dna_71_1un.trimmed.fastq.gz" "${ILLUMINA_INPUT}shortread_dna_71_2un.trimmed.fastq.gz" > "${SNIC_TMP}/R7.unpaired.sam" &

wait

# Convert SAM output to BAM

samtools view -bSh DV3.unpaired.sam > DV3.unpaired.unsorted.bam &
samtools view -bSh HP126.unpaired.sam > HP126.unpaired.unsorted.bam &
samtools view -bSh R7.unpaired.sam > R7.unpaired.unsorted.bam &

wait

# Sort BAM files

samtools sort DV3.unpaired.unsorted.bam -o "${BAM_OUTPUT}DV3.unpaired.sorted.bam" &
samtools sort HP126.unpaired.unsorted.bam -o "${BAM_OUTPUT}HP126.unpaired.sorted.bam" &
samtools sort R7.unpaired.unsorted.bam -o "${BAM_OUTPUT}R7.unpaired.sorted.bam" &

wait

samtools index /home/haddock/private/Genome_analysis/GenomeAnalysis/data/mapped_outputs/DV3.unpaired.sorted.bam &
samtools index /home/haddock/private/Genome_analysis/GenomeAnalysis/data/mapped_outputs/HP126.unpaired.sorted.bam & 
samtools index /home/haddock/private/Genome_analysis/GenomeAnalysis/data/mapped_outputs/R7.unpaired.sorted.bam &

wait