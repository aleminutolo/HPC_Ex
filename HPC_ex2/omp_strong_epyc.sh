#!/bin/bash
#SBATCH --job-name=HPC-OMP-Scaling
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=128  # Utilizza tutti i core logici disponibili
#SBATCH --time=02:00:00
#SBATCH --partition=EPYC
#SBATCH --exclusive

module load openMPI/4.1.5/gnu/12.2.1

export OMP_PROC_BIND=spread
export OMP_PLACES=cores
export OMP_DISPLAY_ENV=true
export OMP_VERBOSE=VERBOSE

# Definisci il nome del file CSV per salvare i risultati
OUTPUT_CSV="omp_strong_epyc.csv"

# Inizializza il file CSV con l'intestazione se non esiste
echo "OMP_NUM_THREADS,Execution_Time" > $OUTPUT_CSV

for OMP_NUM_THREADS in {1..128}; do
    export OMP_NUM_THREADS
    echo "Running with $OMP_NUM_THREADS OpenMP threads."
    
    # Esegui il programma e salva il tempo di esecuzione
    execution_time=$(mpirun -np 1 --map-by socket --bind-to socket ./mandel 800 600 -2.0 -1.0 1.0 1.0 255 $OMP_NUM_THREADS)
    
    # Salva il tempo di esecuzione nel file CSV
    echo "$OMP_NUM_THREADS,$execution_time" >> $OUTPUT_CSV
    
done

