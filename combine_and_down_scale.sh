#!/bin/bash -l
#SBATCH --nodes=1
#SBATCH --time=24:00:00

module load matlab/R2022a
pwd
matlab -nosplash < combine_and_down_scale/combine_and_down_scale_dataset.m
