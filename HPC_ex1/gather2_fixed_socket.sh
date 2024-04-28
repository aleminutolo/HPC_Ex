#!/bin/bash
#SBATCH --job-name=HPC
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=24
#SBATCH --time=02:00:00
#SBATCH --partition THIN
#SBATCH --exclusive
#SBATCH --exclude fat[001-002]

module load openMPI/4.1.5/gnu/12.2.1

echo "Processes,Size,Latency" > gather2_fixed_socket.csv

# Numero di ripetizioni per ottenere una media
repetitions=10000

# Ciclo esterno per il numero di processori
for processes in {2..48..2}
do
    # Calcola la dimensione come 2 elevato alla potenza corrente
    size=1

    # Esegui osu_bcast con numero di processi, dimensione fissa e numero di ripetizioni su due nodi
    result_bcast=$(mpirun --map-by socket -np $processes --mca coll_tuned_use_dynamic_rules true --mca coll_tuned_bcast_algorithm 2 osu_gather -m $size -x $repetitions -i $repetitions | tail -n 1 | awk '{print $2}')
	
    echo "$processes, $size, $result_bcast"
    # Scrivi i risultati nel file CSV
    echo "$processes,$size,$result_bcast" >> gather2_fixed_socket.csv
    
done