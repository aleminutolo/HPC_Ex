#!/bin/bash
#SBATCH --job-name=HPC-OMP-WeakScaling
#SBATCH --nodes=1  # Utilizza un singolo nodo
#SBATCH --ntasks-per-node=1  # Un solo task per nodo
#SBATCH --cpus-per-task=128  # Massimo numero di thread OMP che vuoi testare
#SBATCH --time=02:00:00
#SBATCH --partition=EPYC
#SBATCH --exclusive

module load openMPI/4.1.5/gnu/12.2.1

# Definisci il nome del file CSV per salvare i risultati
OUTPUT_CSV="omp_weak_epyc.csv"

# Inizializza il file CSV con l'intestazione
echo "OMP_NUM_THREADS,Problem_Size,Execution_Time" > $OUTPUT_CSV
# Dimensione di base del problema per 1 thread OpenMP
BASE_COLS=800
BASE_ROWS=600

for OMP_NUM_THREADS in {2..128..2}; do
    export OMP_NUM_THREADS
    # Aumenta la dimensione del problema proporzionalmente alla radice quadrata del numero di thread
    let cols=$(echo "scale=0; sqrt($OMP_NUM_THREADS) * $BASE_COLS" | bc)
    let rows=$(echo "scale=0; sqrt($OMP_NUM_THREADS) * $BASE_ROWS" | bc)

    # Esegui il programma e salva il tempo di esecuzione
    mpirun --map-by socket --bind-to core ./mandel $cols $rows -2.0 -1.0 1.0 1.0 255 $OMP_NUM_THREADS

    if [ -f temp_execution_time.txt ]; then
        execution_time=$(<temp_execution_time.txt)
        echo "$OMP_NUM_THREADS,$cols*$rows,$execution_time" >> $OUTPUT_CSV
        rm temp_execution_time.txt # Rimuovi il file temporaneo
    else
        echo "$OMP_NUM_THREADS,$cols*$rows,FAILED" >> $OUTPUT_CSV
    fi
done

