#!/bin/bash -l
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 16
#SBATCH -t 30:00
#SBATCH -J blastp_dna
#SBATCH --output=%x.%j.out

OUTPUT='/home/haddock/private/Genome_analysis/GenomeAnalysis/analyses/04_genomic_comparison/'
INPUT_PATH='/home/haddock/private/Genome_analysis/GenomeAnalysis/data/mapped_outputs'

module load bioinfo-tools
module load blast

cp "${INPUT_PATH}"/*.fasta $SNIC_TMP
cd $SNIC_TMP


makeblastdb -in R7_pilon_reverse1.fasta -dbtype nucl -title asm_db -out asm_db

blastn -query HP126_pilon.fasta -db asm_db -num_threads 8 -outfmt 6 -out HP126_R7_blastn.crunch &
blastn -query DV3_pilon.fasta -db asm_db -num_threads 8  -outfmt 6 -out DV3_R7_blastn.crunch &

wait

cp *.crunch $OUTPUT


# act /home/haddock/private/Genome_analysis/GenomeAnalysis/analyses/03_anotation/R7/R7.gbk \
# /home/haddock/private/Genome_analysis/GenomeAnalysis/analyses/03_anotation/HP126/HP126.gbk \
# HP126_R7_blastn.xml \
# /home/haddock/private/Genome_analysis/GenomeAnalysis/analyses/03_anotation/HP126/DV3.gbk \
# DV3_R7_blastn.xml \