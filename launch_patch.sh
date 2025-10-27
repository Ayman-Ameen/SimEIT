#!/bin/bash -l
#SBATCH --nodes=1
#SBATCH --time=24:00:00

module load matlab/R2022a
matlab -nosplash < generate_dataset.m
