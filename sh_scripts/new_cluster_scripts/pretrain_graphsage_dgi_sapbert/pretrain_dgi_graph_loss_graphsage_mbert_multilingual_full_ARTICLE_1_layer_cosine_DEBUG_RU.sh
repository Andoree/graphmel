#!/bin/bash
#SBATCH --job-name=mul_sage          # Название задачи
#SBATCH --error=/home/etutubalina/graph_entity_linking/graphmel/logs/pretrain_graphsage_dgi_multilingual_full/mbert_dgi_graph_loss_multilingual_pretrain_graphsage_mbert_article_1_layer_cosine_DEBUG.err        # Файл для вывода ошибок
#SBATCH --output=/home/etutubalina/graph_entity_linking/graphmel/logs/pretrain_graphsage_dgi_multilingual_full/mbert_dgi_graph_loss_multilingual_pretrain_graphsage_mbert_article_1_layer_cosine_DEBUG.txt       # Файл для вывода результатов
#SBATCH --time=12:59:59                      # Максимальное время выполнения
#SBATCH --cpus-per-task=6                   # Количество CPU на одну задачу




export CUDA_VISIBLE_DEVICES=0,1
nvidia-smi
python /home/etutubalina/graph_entity_linking/graphmel/graphmel/scripts/self_alignment_pretraining/train_graphsage_dgi_sapbert.py --train_dir="/home/etutubalina/graph_entity_linking/pos_pairs_graph_data/2020AB/RUS_RUSSIAN_FULL/" \
--text_encoder="/home/etutubalina/graph_entity_linking/huggingface_models/bert-base-multilingual-uncased" \
--dataloader_num_workers=0 \
--graphsage_num_outer_layers 1 \
--graphsage_num_inner_layers 3 \
--graphsage_num_hidden_channels 256 \
--graphsage_num_neighbors 3 \
--graphsage_dropout_p 0.3 \
--dgi_loss_weight 0.01 \
--intermodal_loss_weight 0.1 \
--graph_loss_weight 0.1 \
--modality_distance "cosine" \
--text_loss_weight 1.0 \
--remove_selfloops \
--max_length=32 \
--use_cuda \
--learning_rate=2e-5 \
--weight_decay=0.01  \
--batch_size=128 \
--num_epochs=1 \
--parallel \
--amp \
--random_seed=42 \
--loss="ms_loss" \
--use_miner \
--type_of_triplets "all" \
--miner_margin 0.2 \
--agg_mode "cls" \
--save_every_N_epoch=1 \
--output_dir="/home/etutubalina/graph_entity_linking/results/pretrained_graphsapbert/2020AB/DGI_GRAPH_LOSS_GraphSAGE/MULTILINGUAL_FULL_MBERT_DEBUG"



