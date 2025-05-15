#!/bin/bash -l
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 15
#SBATCH -t 05:00:00
#SBATCH -J RNA_counting_R7
#SBATCH --mail-type=ALL
#SBATCH --mail-user villew7@gmail.com
#SBATCH --output=%x.%j.out

module load bioinfo-tools
module load bwa samtools subread

cp -r '/home/haddock/private/Genome_analysis/GenomeAnalysis/data/assembly' $SNIC_TMP
cp -r '/home/haddock/private/Genome_analysis/GenomeAnalysis/analyses/01_preprocessing/02-04-trimomatic_rna' $SNIC_TMP 

cd $SNIC_TMP


mkdir R7

# R7 replicate 1

(
    bwa mem -t 5 assembly/R7_pilon.fasta 02-04-trimomatic_rna/shortread_rna_62_1.trimmed.fastq.gz \
    02-04-trimomatic_rna/shortread_rna_62_2.trimmed.fastq.gz \
    | samtools sort -@5 -o R7/R7_rep1_rna_map.sorted.bam

    samtools index R7/R7_rep1_rna_map.sorted.bam

) &

# R7 replicate 2

(
    bwa mem -t 5 assembly/R7_pilon.fasta 02-04-trimomatic_rna/shortread_rna_63_1.trimmed.fastq.gz \
    02-04-trimomatic_rna/shortread_rna_63_2.trimmed.fastq.gz \
    | samtools sort -@5 -o R7/R7_rep2_rna_map.sorted.bam

    samtools index R7/R7_rep2_rna_map.sorted.bam

) &

# R7 replicate 3

(
    bwa mem -t 5 assembly/R7_pilon.fasta 02-04-trimomatic_rna/shortread_rna_64_1.trimmed.fastq.gz \
    02-04-trimomatic_rna/shortread_rna_64_2.trimmed.fastq.gz \
    | samtools sort -@5 -o R7/R7_rep3_rna_map.sorted.bam

    samtools index R7/R7_rep3_rna_map.sorted.bam

) &

wait

featureCounts -T 15 -p -s 2 \
-a assembly/R7.gff \
-t CDS -g ID \
-o R7/featureCount_R7.txt R7/R7*.sorted.bam 

cp -r $SNIC_TMP/R7 /home/haddock/private/Genome_analysis/GenomeAnalysis/analyses/05_rna_count/