#!/bin/bash
#SBATCH --job-name=HPC-MPI-Scaling
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=128
#SBATCH --time=02:00:00
#SBATCH --partition=EPYC
#SBATCH --exclusive

module load openMPI/4.1.5/gnu/12.2.1

export OMP_NUM_THREADS=1

# Nome del file CSV per salvare i tempi di esecuzione
output_file="mpi_strong_epyc.csv"

# Creiamo l'intestazione del file CSV
echo "Total Tasks,Execution Time (s)" > $output_file

# Loop attraverso un numero variabile di task MPI totali
for total_tasks in {2..256..2}; do
    echo "Running with $total_tasks MPI tasks."
    
    # Esegui mpirun e cattura il tempo di esecuzione
    execution_time=$(mpirun -np $total_tasks ./mandel 2400 1600 -2.0 -1.0 1.0 1.0 255 $OMP_NUM_THREADS)
  
    echo "$total_tasks,$execution_time" >> $output_file
  
done

