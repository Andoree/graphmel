#!/bin/bash
#SBATCH --job-name=create_pos_pairs          # Название задачи
#SBATCH --error=~/graph_entity_linking/graphmel/logs/create_pos_pairs_dataset/create_pos_pairs_dataset_full_multilingual.err        # Файл для вывода ошибок
#SBATCH --output=~/graph_entity_linking/graphmel/logs/create_pos_pairs_dataset/create_pos_pairs_dataset_full_multilingual.txt       # Файл для вывода результатов
#SBATCH --time=09:50:00                      # Максимальное время выполнения
#SBATCH --cpus-per-task=1                   # Количество CPU на одну задачу

python ../../scripts/self_alignment_pretraining/create_positive_triplets_dataset.py --mrconso "~/graph_entity_linking/UMLS/2020AB/MRCONSO.RRF" \
--mrrel "~/graph_entity_linking/UMLS/2020AB/MRREL.RRF" \
--langs "ENG" "FRE" "GER" "SPA" "DUT" "RUS" \
--output_dir "~/graph_entity_linking/pos_pairs_graph_data/2020AB/MULTILINGUAL_FULL/"

