#!/bin/bash -l
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 15
#SBATCH -t 20:00:00
#SBATCH -J annotation_eggNOGmapper
#SBATCH --mail-type=ALL
#SBATCH --mail-user villew7@gmail.com
#SBATCH --output=%x.%j.out

OUTPUT='/home/haddock/private/Genome_analysis/GenomeAnalysis/analyses/03_anotation/eggNOGmapper'
INPUT_PATH='/home/haddock/private/Genome_analysis/GenomeAnalysis/analyses/03_anotation'

module load bioinfo-tools
module load eggNOG-mapper

emapper.py --cpu 5 --output "${OUTPUT}/HP126" -i "${INPUT_PATH}/HP126/HP126.faa" --data_dir $EGGNOG_DATA_ROOT --hmmer_mode &
emapper.py --cpu 5 --output "${OUTPUT}/R7" -i "${INPUT_PATH}/R7/R7.faa" --data_dir $EGGNOG_DATA_ROOT --hmmer_mode &
emapper.py --cpu 5 --output "${OUTPUT}/DV3" -i "${INPUT_PATH}/DV3/DV3.faa" --data_dir $EGGNOG_DATA_ROOT --hmmer_mode &

wait