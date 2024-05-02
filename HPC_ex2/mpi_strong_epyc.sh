#!/bin/bash
#SBATCH --job-name=HPC-MPI-Scaling
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=128
#SBATCH --time=02:00:00
#SBATCH --partition=EPYC
#SBATCH --exclusive

module load openMPI/4.1.5/gnu/12.2.1

# Imposta il numero di thread OpenMP per ciascun processo MPI
export OMP_NUM_THREADS=1

# Nome del file CSV per salvare i tempi di esecuzione
OUTPUT_CSV="mpi_strong_epyc.csv"

# Creiamo l'intestazione del file CSV
echo "Total Tasks,Execution Time (s)" > $OUTPUT_CSV

# Loop attraverso un numero variabile di task MPI totali
for total_tasks in {2..256..2}; do
    echo "Running with $total_tasks MPI tasks."

    # Esegui mpirun e misura il tempo di esecuzione usando il comando `time`
    execution_time=$( { time mpirun -np $total_tasks --map-by core ./mandel 800 600 -2.0 -1.0 1.0 1.0 255 $OMP_NUM_THREADS; } 2>&1 | grep real | awk '{print $2}' | tr -d 'm' | awk -F's' '{print ($1 * 60) + $2}')

    # Aggiungi i risultati al file CSV
    echo "$total_tasks,$execution_time" >> $OUTPUT_CSV
done

