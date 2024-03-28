#!/bin/bash
#SBATCH --job-name=HPC
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=24
#SBATCH --time=02:00:00
#SBATCH --partition THIN
#SBATCH --exclusive
#SBATCH --exclude fat[001-002]

module load gcc/9.3.0
module load openmpi/4.0.3

mpirun ./mandelbrot 800 600 -2.0 -1.0 1.0 1.#!/bin/bash

