#!/bin/bash
#SBATCH --job-name=en_hesage          # Название задачи
#SBATCH --error=/home/etutubalina/graph_entity_linking/graphmel/logs/pretrain_heterosage_graphloss_dgi_multilingual_full/pretrain_dgi_0.01_graph_loss_hetero_sage_full_final_intermodal_768_0.2_FINAL_ENGLISH_b_512.err         # Файл для вывода ошибок
#SBATCH --output=/home/etutubalina/graph_entity_linking/graphmel/logs/pretrain_heterosage_graphloss_dgi_multilingual_full/pretrain_dgi_0.01_graph_loss_hetero_sage_full_final_intermodal_768_0.2_FINAL_ENGLISH_b_512.txt       # Файл для вывода результатов
#SBATCH --time=128:00:59                      # Максимальное время выполнения
#SBATCH --cpus-per-task=5                   # Количество CPU на одну задачу
#SBATCH --gpus=4                   # Требуемое количество GPU
#SBATCH --constraint=type_c|type_b|type_a
#SBATCH --nodes=1


export CUDA_VISIBLE_DEVICES=0,1,2,3
export TOKENIZERS_PARALLELISM=false
nvidia-smi
python /home/etutubalina/graph_entity_linking/graphmel/graphmel/scripts/self_alignment_pretraining/train_hetero_graphsage_dgi_sapbert.py --train_dir="/home/etutubalina/graph_entity_linking/pos_pairs_graph_data/2020AB/ENG_ENGLISH_FULL/" \
--text_encoder="/home/etutubalina/graph_entity_linking/huggingface_models/microsoft/BiomedNLP-PubMedBERT-base-uncased-abstract-fulltext/" \
--dataloader_num_workers=0 \
--graphsage_num_neighbors 1 \
--num_graphsage_layers 3 \
--graphsage_hidden_channels 768 \
--graphsage_dropout_p 0.3 \
--graph_loss_weight 0.1 \
--dgi_loss_weight 0.01 \
--intermodal_loss_weight 0.1 \
--use_intermodal_miner \
--modality_distance "sapbert" \
--freeze_non_target_nodes \
--text_loss_weight 1.0 \
--max_length=32 \
--use_cuda \
--learning_rate=2e-5 \
--weight_decay=0.01  \
--batch_size=512 \
--num_epochs=1 \
--amp \
--parallel \
--random_seed=42 \
--loss="ms_loss" \
--use_miner \
--type_of_triplets "all" \
--miner_margin 0.2 \
--agg_mode "cls" \
--save_every_N_epoch=1 \
--output_dir="/home/etutubalina/graph_entity_linking/results/pretrained_graphsapbert/2020AB/768_0.2_FINAL_ENGLISH_b_512/HETERO_SAGE_DGI_ENGLISH/"


