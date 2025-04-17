#!/bin/bash -l
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 15
#SBATCH -t 45:00
#SBATCH -J DNA_Polishing
#SBATCH --output=%x.%j.out

BAM_OUTPUT='/home/haddock/private/Genome_analysis/GenomeAnalysis/data/mapped_outputs/'
FLYE_INPUT='/home/haddock/private/Genome_analysis/GenomeAnalysis/analyses/01_preprocessing/09-04-Flye_dna_assembly/'

# Load modules
module load bioinfo-tools
module load Pilon

for i in DV3 HP126 R7;
do (
java -jar "${PILON_HOME}/pilon.jar" \
 --threads 5 \
 --genome "${FLYE_INPUT}${i}/${i}_assembly_flye.fasta" \
 --frags "${BAM_OUTPUT}${i}.paired.sorted.bam" \
 --unpaired "${BAM_OUTPUT}${i}.unpaired.sorted.bam" \
 --outdir "${BAM_OUTPUT}" \
 --output "${i}_pilon" \
 --changes \
 --vcf
) &
done

wait
