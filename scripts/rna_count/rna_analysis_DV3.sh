#!/bin/bash -l
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 15
#SBATCH -t 05:00:00
#SBATCH -J RNA_counting_DV3
#SBATCH --mail-type=ALL
#SBATCH --mail-user villew7@gmail.com
#SBATCH --output=%x.%j.out

module load bioinfo-tools
module load bwa samtools subread

cp -r '/home/haddock/private/Genome_analysis/GenomeAnalysis/data/assembly' $SNIC_TMP
cp -r '/home/haddock/private/Genome_analysis/GenomeAnalysis/analyses/01_preprocessing/02-04-trimomatic_rna' $SNIC_TMP 

cd $SNIC_TMP


mkdir DV3

# DV3 replicate 1

(
    bwa mem -t 5 assembly/DV3_pilon.fasta 02-04-trimomatic_rna/shortread_rna_56_1.trimmed.fastq.gz \
    02-04-trimomatic_rna/shortread_rna_56_2.trimmed.fastq.gz \
    | samtools sort -@5 -o DV3/DV3_rep1_rna_map.sorted.bam

    samtools index DV3/DV3_rep1_rna_map.sorted.bam

) &

# DV3 replicate 2

(
    bwa mem -t 5 assembly/DV3_pilon.fasta 02-04-trimomatic_rna/shortread_rna_57_1.trimmed.fastq.gz \
    02-04-trimomatic_rna/shortread_rna_57_2.trimmed.fastq.gz \
    | samtools sort -@5 -o DV3/DV3_rep2_rna_map.sorted.bam

    samtools index DV3/DV3_rep2_rna_map.sorted.bam

) &

# DV3 replicate 3

(
    bwa mem -t 5 assembly/DV3_pilon.fasta 02-04-trimomatic_rna/shortread_rna_58_1.trimmed.fastq.gz \
    02-04-trimomatic_rna/shortread_rna_58_2.trimmed.fastq.gz \
    | samtools sort -@5 -o DV3/DV3_rep3_rna_map.sorted.bam

    samtools index DV3/DV3_rep3_rna_map.sorted.bam

) &

wait

featureCounts -T 15 -p -s 2 \
-a assembly/DV3.gff \
-t CDS -g ID \
-o DV3/featureCount_DV3.txt DV3/DV3*.sorted.bam 

cp -r $SNIC_TMP/DV3 /home/haddock/private/Genome_analysis/GenomeAnalysis/analyses/05_rna_count/