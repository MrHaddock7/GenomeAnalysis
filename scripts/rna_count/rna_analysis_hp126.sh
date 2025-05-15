#!/bin/bash -l
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 15
#SBATCH -t 05:00:00
#SBATCH -J RNA_counting_HP126
#SBATCH --mail-type=ALL
#SBATCH --mail-user villew7@gmail.com
#SBATCH --output=%x.%j.out

module load bioinfo-tools
module load bwa samtools subread

cp -r '/home/haddock/private/Genome_analysis/GenomeAnalysis/data/assembly' $SNIC_TMP
cp -r '/home/haddock/private/Genome_analysis/GenomeAnalysis/analyses/01_preprocessing/02-04-trimomatic_rna' $SNIC_TMP 

cd $SNIC_TMP


mkdir HP126

# HP126 replicate 1

(
    bwa mem -t 5 assembly/HP126_pilon.fasta 02-04-trimomatic_rna/shortread_rna_59_1.trimmed.fastq.gz \
    02-04-trimomatic_rna/shortread_rna_59_2.trimmed.fastq.gz \
    | samtools sort -@5 -o HP126/HP126_rep1_rna_map.sorted.bam

    samtools index HP126/HP126_rep1_rna_map.sorted.bam

) &

# HP126 replicate 2

(
    bwa mem -t 5 assembly/HP126_pilon.fasta 02-04-trimomatic_rna/shortread_rna_60_1.trimmed.fastq.gz \
    02-04-trimomatic_rna/shortread_rna_60_2.trimmed.fastq.gz \
    | samtools sort -@5 -o HP126/HP126_rep2_rna_map.sorted.bam

    samtools index HP126/HP126_rep2_rna_map.sorted.bam

) &

# HP126 replicate 3

(
    bwa mem -t 5 assembly/HP126_pilon.fasta 02-04-trimomatic_rna/shortread_rna_61_1.trimmed.fastq.gz \
    02-04-trimomatic_rna/shortread_rna_61_2.trimmed.fastq.gz \
    | samtools sort -@5 -o HP126/HP126_rep3_rna_map.sorted.bam

    samtools index HP126/HP126_rep3_rna_map.sorted.bam

) &

wait

featureCounts -T 15 -p -s 2 \
-a assembly/HP126.gff \
-t CDS -g ID \
-o HP126/featureCount_HP126.txt HP126/HP126*.sorted.bam 

cp -r $SNIC_TMP/HP126 /home/haddock/private/Genome_analysis/GenomeAnalysis/analyses/05_rna_count/