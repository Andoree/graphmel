#!/bin/bash
#SBATCH --job-name=create_pos_pairs          # Название задачи
#SBATCH --error=../../logs/create_pos_pairs_dataset/create_pos_pairs_dataset_4.err        # Файл для вывода ошибок
#SBATCH --output=../../logs/create_pos_pairs_dataset/create_pos_pairs_dataset_4.txt       # Файл для вывода результатов
#SBATCH --time=09:50:00                      # Максимальное время выполнения
#SBATCH --cpus-per-task=2                   # Количество CPU на одну задачу

python ../../scripts/self_alignment_pretraining/create_positive_triplets_dataset.py --mrconso "../../UMLS/2020AB/MRCONSO.RRF" \
--mrrel "../../UMLS/2020AB/MRREL.RRF" \
--langs "RUS" \
--output_dir "../../data/umls_graph/2020AB_pos_pairs_datasets/pos_pairs_russian_FULL"

