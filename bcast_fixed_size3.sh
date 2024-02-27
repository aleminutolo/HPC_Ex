#!/bin/bash
#SBATCH --job-name=HPC
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=128
#SBATCH --time=02:00:00
#SBATCH --partition=EPYC
#SBATCH --exclusive
#SBATCH --exclude=fat[001-002]

module load openMPI/4.1.5/gnu/12.2.1

echo "Processes,Latency" > output_processes_epyc_fixed_size_bcast_3_new.csv

# Numero di ripetizioni per ottenere una media
repetitions=10000
size=2
echo "size = $size"
# Ciclo esterno per il numero di processori
for i in {1..8}; do
  processes=$((2**i))
  
  # Esegui osu_bcast con numero di processi, dimensione fissa e numero di ripetizioni su due nodi
  result_bcast=$(mpirun --map-by core -np $processes --mca coll_tuned_use_dynamic_rules true --mca coll_tuned_bcast_algorithm 3 osu_bcast -m $size -x $repetitions -i $repetitions | tail -n 1 | awk '{print $2}')
	
  echo "$processes, $result_bcast"
  # Scrivi i risultati nel file CSV
  echo "$processes,$result_bcast" >> output_processes_epyc_fixed_size_bcast_3_new.csv
done
