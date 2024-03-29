#!/bin/bash
#SBATCH --job-name=pretrain_graphsage          # Название задачи
#SBATCH --error=../../logs/pretrain_graphsage/ru_pretrain_graphsage_4.err        # Файл для вывода ошибок
#SBATCH --output=../../logs/pretrain_graphsage/ru_pretrain_graphsage_4.txt       # Файл для вывода результатов
#SBATCH --time=23:59:59                      # Максимальное время выполнения
#SBATCH --cpus-per-task=8                   # Количество CPU на одну задачу
#SBATCH --gpus=4                   # Требуемое количество GPU
#SBATCH --constraint=type_c|type_b|type_a

nvidia-smi
python ../../scripts/training/pretrain_graphsage.py --train_node2terms_path="../../data/umls_graph/2020AB/RU/train_synonyms" \
--train_edges_path="../../data/umls_graph/2020AB/RU/train_edges" \
--val_node2terms_path="../../data/umls_graph/2020AB/RU/val_synonyms" \
--val_edges_path="../../data/umls_graph/2020AB/RU/val_edges" \
--text_encoder="../../models/cambridgeltl/SapBERT-UMLS-2020AB-all-lang-from-XLMR/" \
--text_encoder_seq_length=32 \
--dataloader_num_workers=8 \
--graphsage_num_layers=2 \
--graphsage_num_channels=512 \
--train_graph_num_neighbors 4 4 \
--graphsage_dropout=0.2 \
--random_walk_length=2 \
--batch_size=96 \
--learning_rate=2e-5 \
--num_epochs=25 \
--random_state=42 \
--save_every_N_epoch=5 \
--gpus=4 \
--output_dir="../../pretrained_models/2020AB/GraphSAGE/RU_split_w_loops"
