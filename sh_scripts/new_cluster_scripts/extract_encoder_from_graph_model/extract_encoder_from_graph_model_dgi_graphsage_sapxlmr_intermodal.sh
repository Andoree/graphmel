#!/bin/bash
#SBATCH --job-name=extract_encoder_from_graph_model          # Название задачи
#SBATCH --error=/home/echernyak/graph_entity_linking/graphmel/logs/extract_encoder_from_graph_model/extract_encoder_from_graph_model_dgi_graphsage_sapxlmr_intermodal.err        # Файл для вывода ошибок
#SBATCH --output=/home/echernyak/graph_entity_linking/graphmel/logs/extract_encoder_from_graph_model/extract_encoder_from_graph_model_dgi_graphsage_sapxlmr_intermodal.txt       # Файл для вывода результатов
#SBATCH --time=20:30:00                      # Максимальное время выполнения
#SBATCH --cpus-per-task=3                   # Количество CPU на одну задачу
#SBATCH --gpus=1

python /home/echernyak/graph_entity_linking/graphmel/scripts/postprocessing/extract_encoder_from_graph_model.py --input_pretrained_graph_models_dir="/home/echernyak/graph_entity_linking/results/pretrained_graphsapbert/2020AB/DGI_GraphSAGE/MULTILINGUAL_FULL_XLMR" \
--bert_initialization_model="/home/echernyak/graph_entity_linking/huggingface_models/xlm-roberta-base/" \
--output_dir="/home/echernyak/graph_entity_linking/results/pretrained_encoders/2020AB/DGI_GraphSAGE/MULTILINGUAL_FULL_XLMR/"