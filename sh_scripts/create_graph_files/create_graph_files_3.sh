#!/bin/bash
#SBATCH --job-name=create_umls_graph_files          # Название задачи
#SBATCH --error=../../logs/create_umls_graph_files_3.err        # Файл для вывода ошибок
#SBATCH --output=../../logs/create_umls_graph_files_3.txt       # Файл для вывода результатов
#SBATCH --time=06:50:00                      # Максимальное время выполнения
#SBATCH --cpus-per-task=1                   # Количество CPU на одну задачу

python ../../scripts/preprocessing/reformat_umls_to_graph.py --mrconso "../../UMLS/2020AB/ENG_FRE_GER_SPA_DUT_RUS_MRCONSO_filt.RRF" \
--mrrel "../../UMLS/2020AB/MRREL.RRF" \
--output_dir "../../data/umls_graph/2020AB_w_loops/FULL_ENG_FRE_GER_SPA_DUT_RUS/"

