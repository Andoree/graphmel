#!/bin/bash
#SBATCH --job-name=gs_sage          # Название задачи
#SBATCH --error=../../logs/grid_search/grid_search_multi_full_graphsage_sapbert.err        # Файл для вывода ошибок
#SBATCH --output=../../logs/grid_search/grid_search_multi_full_graphsage_sapbert.txt       # Файл для вывода результатов
#SBATCH --time=36:00:59                      # Максимальное время выполнения
#SBATCH --cpus-per-task=4                   # Количество CPU на одну задачу
#SBATCH --gpus=4                   # Требуемое количество GPU
#SBATCH --constraint=type_c|type_b|type_a

#--train_dir="../../data/umls_graph/2020AB_pos_pairs_datasets/ENG_FRE_GER_SPA_DUT_RUS_pos_pairs_multilingual_FULL" \
export CUDA_VISIBLE_DEVICES=0,1,2,3
nvidia-smi

python ../../scripts/grid_search/graphsage_sapbert_grid_search.py --train_dir="../../data/umls_graph/2020AB_pos_pairs_datasets/ENG_FRE_GER_SPA_DUT_RUS_pos_pairs_multilingual_FULL" \
--text_encoder="../../models/bert-base-multilingual-uncased/" \
--dataloader_num_workers=4 \
--max_length=32 \
--num_graphsage_channels 256 768 \
--num_graphsage_layers 1 2 \
--num_inner_graphsage_layers 1 2 3 \
--graphsage_dropout_p 0.1 \
--graphsage_num_neighbors 2 3 \
--graph_loss_weight 1. 0.1 0.01 \
--remove_selfloops \
--batch_size 128 \
--train_subset_ratio 0.001 \
--use_cuda \
--learning_rate=2e-5 \
--weight_decay=0.01  \
--num_epochs=1 \
--data_folder "/home/etutubalina/classification_transfer_learning/graphmel/data/medical_crossing_data/data_medical_crossing/datasets/mantra/de/DISO" "/home/etutubalina/classification_transfer_learning/graphmel/data/medical_crossing_data/data_medical_crossing/datasets/mantra/es/DISO" "/home/etutubalina/classification_transfer_learning/graphmel/data/medical_crossing_data/data_medical_crossing/datasets/mantra/nl/DISO" "/home/etutubalina/classification_transfer_learning/graphmel/data/medical_crossing_data/data_medical_crossing/datasets/mantra/fr/DISO" \
--vocab "/home/etutubalina/classification_transfer_learning/graphmel/data/medical_crossing_data/data_medical_crossing/vocabs/mantra_de_dict_DISO.txt" "/home/etutubalina/classification_transfer_learning/graphmel/data/medical_crossing_data/data_medical_crossing/vocabs/mantra_es_dict_DISO.txt" "/home/etutubalina/classification_transfer_learning/graphmel/data/medical_crossing_data/data_medical_crossing/vocabs/mantra_nl_dict_DISO.txt" "/home/etutubalina/classification_transfer_learning/graphmel/data/medical_crossing_data/data_medical_crossing/vocabs/mantra_fr_dict_DISO.txt" \
--eval_dataset_name "MANTRA_DE" "MANTRA_ES" "MANTRA_NL" "MANTRA_FR" \
--amp \
--parallel \
--random_seed=42 \
--loss="ms_loss" \
--use_miner \
--type_of_triplets "all" \
--miner_margin 0.2 \
--agg_mode "cls" \
--save_every_N_epoch=1 \
--output_dir="../../grid_search/2020AB/GraphSAGE/gs_MULTI_FULL"

