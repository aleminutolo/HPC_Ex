#!/bin/bash
#SBATCH --job-name=HPC
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=24
#SBATCH --time=02:00:00
#SBATCH --partition THIN
#SBATCH --exclusive
#SBATCH --exclude fat[001-002]

module load openMPI/4.1.5/gnu/12.2.1

echo "Processes,Latency" > output_processes_fixed_size_bcast_5_new.csv

# Numero di ripetizioni per ottenere una media
repetitions=10000
echo "size = 2"
# Ciclo esterno per il numero di processori
for processes in {2..48..2}
do
  
  # Esegui osu_bcast con numero di processi, dimensione fissa e numero di ripetizioni su due nodi
  result_bcast=$(mpirun --map-by core -np $processes --mca coll_tuned_use_dynamic_rules true --mca coll_tuned_bcast_algorithm 5 osu_bcast -m 2 -x $repetitions -i $repetitions | tail -n 1 | awk '{print $2}')
	
	echo "$processes, $result_bcast"
        # Scrivi i risultati nel file CSV
        echo "$processes,$size,$result_bcast" >> output_processes_fixed_size_bcast_5_new.csv
done
