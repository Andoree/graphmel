#!/bin/bash
#SBATCH --job-name=fair_ev          # Название задачи
#SBATCH --error=/home/echernyak/graph_entity_linking/graphmel/logs/fair_evaluation/fair_eval_dgi_0.0_graphloss_gatv2_mbert_intermodal_layer_1_sapbert_loss_0.1.err        # Файл для вывода ошибок
#SBATCH --output=/home/echernyak/graph_entity_linking/graphmel/logs/fair_evaluation/fair_eval_dgi_0.0_graphloss_gatv2_mbert_intermodal_layer_1_sapbert_loss_0.1.txt       # Файл для вывода результатов
#SBATCH --time=20:30:00                      # Максимальное время выполнения
#SBATCH --cpus-per-task=3                   # Количество CPU на одну задачу
#SBATCH --gpus=1


export CUDA_VISIBLE_DEVICES=0
MODEL="/home/echernyak/graph_entity_linking/results/pretrained_encoders/2020AB/GATV2_DGI_GRAPH_LOSS/MULTILINGUAL_FULL_MBERT/gatv2_3_256_1_3_0.3_2_0.1_graph_loss_0.1_rel_remove_loops_True_dgi_0.0_text_loss_1.0_intermodal_sapbert_0.1_lr_2e-05_b_128/checkpoint_e_1_steps_159510.pth"


echo "dataset mantra/es/ SPLIT DISO-fair_exact_vocab"
echo VOCAB "mantra_es_dict_DISO.txt"
python /home/echernyak/graph_entity_linking/Fair-Evaluation-BERT/eval_bert_ranking.py --model_dir $MODEL \
    --data_folder "/home/echernyak/graph_entity_linking/data_medical_crossing/datasets/mantra/es/DISO-fair_exact_vocab" \
    --vocab "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/mantra_es_dict_DISO.txt"


echo "dataset mantra/es/ SPLIT DISO"
echo VOCAB "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/mantra_es_dict_DISO.txt"
python /home/echernyak/graph_entity_linking/Fair-Evaluation-BERT/eval_bert_ranking.py --model_dir $MODEL \
    --data_folder "/home/echernyak/graph_entity_linking/data_medical_crossing/datasets/mantra/es/DISO" \
    --vocab "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/mantra_es_dict_DISO.txt"


echo "dataset mantra/es/ SPLIT DISO-fair_levenshtein_0.2"
echo VOCAB "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/mantra_es_dict_DISO.txt"
python /home/echernyak/graph_entity_linking/Fair-Evaluation-BERT/eval_bert_ranking.py --model_dir $MODEL \
    --data_folder "/home/echernyak/graph_entity_linking/data_medical_crossing/datasets/mantra/es/DISO-fair_levenshtein_0.2" \
    --vocab "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/mantra_es_dict_DISO.txt"


echo "dataset mantra/nl/ SPLIT DISO-fair_exact_vocab"
echo VOCAB "mantra_nl_dict_DISO.txt"
python /home/echernyak/graph_entity_linking/Fair-Evaluation-BERT/eval_bert_ranking.py --model_dir $MODEL \
    --data_folder "/home/echernyak/graph_entity_linking/data_medical_crossing/datasets/mantra/nl/DISO-fair_exact_vocab" \
    --vocab "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/mantra_nl_dict_DISO.txt"


echo "dataset mantra/nl/ SPLIT DISO"
echo VOCAB "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/mantra_nl_dict_DISO.txt"
python /home/echernyak/graph_entity_linking/Fair-Evaluation-BERT/eval_bert_ranking.py --model_dir $MODEL \
    --data_folder "/home/echernyak/graph_entity_linking/data_medical_crossing/datasets/mantra/nl/DISO" \
    --vocab "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/mantra_nl_dict_DISO.txt"


echo "dataset mantra/nl/ SPLIT DISO-fair_levenshtein_0.2"
echo VOCAB "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/mantra_nl_dict_DISO.txt"
python /home/echernyak/graph_entity_linking/Fair-Evaluation-BERT/eval_bert_ranking.py --model_dir $MODEL \
    --data_folder "/home/echernyak/graph_entity_linking/data_medical_crossing/datasets/mantra/nl/DISO-fair_levenshtein_0.2" \
    --vocab "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/mantra_nl_dict_DISO.txt"


echo "dataset mantra/fr/ SPLIT DISO-fair_exact_vocab"
echo VOCAB "mantra_fr_dict_DISO.txt"
python /home/echernyak/graph_entity_linking/Fair-Evaluation-BERT/eval_bert_ranking.py --model_dir $MODEL \
    --data_folder "/home/echernyak/graph_entity_linking/data_medical_crossing/datasets/mantra/fr/DISO-fair_exact_vocab" \
    --vocab "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/mantra_fr_dict_DISO.txt"


echo "dataset mantra/fr/ SPLIT DISO"
echo VOCAB "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/mantra_fr_dict_DISO.txt"
python /home/echernyak/graph_entity_linking/Fair-Evaluation-BERT/eval_bert_ranking.py --model_dir $MODEL \
    --data_folder "/home/echernyak/graph_entity_linking/data_medical_crossing/datasets/mantra/fr/DISO" \
    --vocab "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/mantra_fr_dict_DISO.txt"


echo "dataset mantra/fr/ SPLIT DISO-fair_levenshtein_0.2"
echo VOCAB "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/mantra_fr_dict_DISO.txt"
python /home/echernyak/graph_entity_linking/Fair-Evaluation-BERT/eval_bert_ranking.py --model_dir $MODEL \
    --data_folder "/home/echernyak/graph_entity_linking/data_medical_crossing/datasets/mantra/fr/DISO-fair_levenshtein_0.2" \
    --vocab "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/mantra_fr_dict_DISO.txt"


echo "dataset mantra/de/ SPLIT DISO-fair_exact_vocab"
echo VOCAB "mantra_de_dict_DISO.txt"
python /home/echernyak/graph_entity_linking/Fair-Evaluation-BERT/eval_bert_ranking.py --model_dir $MODEL \
    --data_folder "/home/echernyak/graph_entity_linking/data_medical_crossing/datasets/mantra/de/DISO-fair_exact_vocab" \
    --vocab "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/mantra_de_dict_DISO.txt"


echo "dataset mantra/de/ SPLIT DISO"
echo VOCAB "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/mantra_de_dict_DISO.txt"
python /home/echernyak/graph_entity_linking/Fair-Evaluation-BERT/eval_bert_ranking.py --model_dir $MODEL \
    --data_folder "/home/echernyak/graph_entity_linking/data_medical_crossing/datasets/mantra/de/DISO" \
    --vocab "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/mantra_de_dict_DISO.txt"


echo "dataset mantra/de/ SPLIT DISO-fair_levenshtein_0.2"
echo VOCAB "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/mantra_de_dict_DISO.txt"
python /home/echernyak/graph_entity_linking/Fair-Evaluation-BERT/eval_bert_ranking.py --model_dir $MODEL \
    --data_folder "/home/echernyak/graph_entity_linking/data_medical_crossing/datasets/mantra/de/DISO-fair_levenshtein_0.2" \
    --vocab "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/mantra_de_dict_DISO.txt"

echo "dataset codiesp/DIAGNOSTICO/ SPLIT test"
echo VOCAB "codiesp-d-codes-es.txt"
python /home/echernyak/graph_entity_linking/Fair-Evaluation-BERT/eval_bert_ranking.py --model_dir $MODEL \
    --data_folder "/home/echernyak/graph_entity_linking/data_medical_crossing/datasets/codiesp/DIAGNOSTICO/test" \
    --vocab "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/codiesp-d-codes-es.txt"


echo "dataset codiesp/DIAGNOSTICO/ SPLIT test-fair_exact"
echo VOCAB "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/codiesp-d-codes-es.txt"
python /home/echernyak/graph_entity_linking/Fair-Evaluation-BERT/eval_bert_ranking.py --model_dir $MODEL \
    --data_folder "/home/echernyak/graph_entity_linking/data_medical_crossing/datasets/codiesp/DIAGNOSTICO/test-fair_exact" \
    --vocab "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/codiesp-d-codes-es.txt"


echo "dataset codiesp/DIAGNOSTICO/ SPLIT test-fair_exact_vocab"
echo VOCAB "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/codiesp-d-codes-es.txt"
python /home/echernyak/graph_entity_linking/Fair-Evaluation-BERT/eval_bert_ranking.py --model_dir $MODEL \
    --data_folder "/home/echernyak/graph_entity_linking/data_medical_crossing/datasets/codiesp/DIAGNOSTICO/test-fair_exact_vocab" \
    --vocab "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/codiesp-d-codes-es.txt"


echo "dataset codiesp/DIAGNOSTICO/ SPLIT test-fair_levenshtein_0.2"
echo VOCAB "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/codiesp-d-codes-es.txt"
python /home/echernyak/graph_entity_linking/Fair-Evaluation-BERT/eval_bert_ranking.py --model_dir $MODEL \
    --data_folder "/home/echernyak/graph_entity_linking/data_medical_crossing/datasets/codiesp/DIAGNOSTICO/test-fair_levenshtein_0.2" \
    --vocab "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/codiesp-d-codes-es.txt"


echo "dataset codiesp/DIAGNOSTICO/ SPLIT test-fair_levenshtein_train_0.2"
echo VOCAB "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/codiesp-d-codes-es.txt"
python /home/echernyak/graph_entity_linking/Fair-Evaluation-BERT/eval_bert_ranking.py --model_dir $MODEL \
    --data_folder "/home/echernyak/graph_entity_linking/data_medical_crossing/datasets/codiesp/DIAGNOSTICO/test-fair_levenshtein_train_0.2" \
    --vocab "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/codiesp-d-codes-es.txt"


echo "dataset codiesp/PROCEDIMIENTO/ SPLIT test"
echo VOCAB "codiesp-p-codes-es.txt"
python /home/echernyak/graph_entity_linking/Fair-Evaluation-BERT/eval_bert_ranking.py --model_dir $MODEL \
    --data_folder "/home/echernyak/graph_entity_linking/data_medical_crossing/datasets/codiesp/PROCEDIMIENTO/test" \
    --vocab "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/codiesp-p-codes-es.txt"


echo "dataset codiesp/PROCEDIMIENTO/ SPLIT test-fair_exact"
echo VOCAB "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/codiesp-p-codes-es.txt"
python /home/echernyak/graph_entity_linking/Fair-Evaluation-BERT/eval_bert_ranking.py --model_dir $MODEL \
    --data_folder "/home/echernyak/graph_entity_linking/data_medical_crossing/datasets/codiesp/PROCEDIMIENTO/test-fair_exact" \
    --vocab "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/codiesp-p-codes-es.txt"


echo "dataset codiesp/PROCEDIMIENTO/ SPLIT test-fair_exact_vocab"
echo VOCAB "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/codiesp-p-codes-es.txt"
python /home/echernyak/graph_entity_linking/Fair-Evaluation-BERT/eval_bert_ranking.py --model_dir $MODEL \
    --data_folder "/home/echernyak/graph_entity_linking/data_medical_crossing/datasets/codiesp/PROCEDIMIENTO/test-fair_exact_vocab" \
    --vocab "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/codiesp-p-codes-es.txt"


echo "dataset codiesp/PROCEDIMIENTO/ SPLIT test-fair_levenshtein_0.2"
echo VOCAB "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/codiesp-p-codes-es.txt"
python /home/echernyak/graph_entity_linking/Fair-Evaluation-BERT/eval_bert_ranking.py --model_dir $MODEL \
    --data_folder "/home/echernyak/graph_entity_linking/data_medical_crossing/datasets/codiesp/PROCEDIMIENTO/test-fair_levenshtein_0.2" \
    --vocab "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/codiesp-p-codes-es.txt"


echo "dataset codiesp/PROCEDIMIENTO/ SPLIT test-fair_levenshtein_train_0.2"
echo VOCAB "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/codiesp-p-codes-es.txt"
python /home/echernyak/graph_entity_linking/Fair-Evaluation-BERT/eval_bert_ranking.py --model_dir $MODEL \
    --data_folder "/home/echernyak/graph_entity_linking/data_medical_crossing/datasets/codiesp/PROCEDIMIENTO/test-fair_levenshtein_train_0.2" \
    --vocab "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/codiesp-p-codes-es.txt"


echo "dataset cantemist/test-set/ SPLIT cantemist-norm-concepts"
echo VOCAB "CANTEMIST-lopez-ubeda-et-al.txt"
python /home/echernyak/graph_entity_linking/Fair-Evaluation-BERT/eval_bert_ranking.py --model_dir $MODEL \
    --data_folder "/home/echernyak/graph_entity_linking/data_medical_crossing/datasets/cantemist/test-set/cantemist-norm-concepts" \
    --vocab "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/CANTEMIST-lopez-ubeda-et-al.txt"


echo "dataset cantemist/test-set/ SPLIT cantemist-norm-concepts-fair_exact"
echo VOCAB "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/CANTEMIST-lopez-ubeda-et-al.txt"
python /home/echernyak/graph_entity_linking/Fair-Evaluation-BERT/eval_bert_ranking.py --model_dir $MODEL \
    --data_folder "/home/echernyak/graph_entity_linking/data_medical_crossing/datasets/cantemist/test-set/cantemist-norm-concepts-fair_exact" \
    --vocab "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/CANTEMIST-lopez-ubeda-et-al.txt"


echo "dataset cantemist/test-set/ SPLIT cantemist-norm-concepts-fair_exact_vocab"
echo VOCAB "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/CANTEMIST-lopez-ubeda-et-al.txt"
python /home/echernyak/graph_entity_linking/Fair-Evaluation-BERT/eval_bert_ranking.py --model_dir $MODEL \
    --data_folder "/home/echernyak/graph_entity_linking/data_medical_crossing/datasets/cantemist/test-set/cantemist-norm-concepts-fair_exact_vocab" \
    --vocab "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/CANTEMIST-lopez-ubeda-et-al.txt"


echo "dataset cantemist/test-set/ SPLIT cantemist-norm-concepts-fair_levenshtein_0.2"
echo VOCAB "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/CANTEMIST-lopez-ubeda-et-al.txt"
python /home/echernyak/graph_entity_linking/Fair-Evaluation-BERT/eval_bert_ranking.py --model_dir $MODEL \
    --data_folder "/home/echernyak/graph_entity_linking/data_medical_crossing/datasets/cantemist/test-set/cantemist-norm-concepts-fair_levenshtein_0.2" \
    --vocab "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/CANTEMIST-lopez-ubeda-et-al.txt"


echo "dataset cantemist/test-set/ SPLIT cantemist-norm-concepts-fair_levenshtein_train_0.2"
echo VOCAB "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/CANTEMIST-lopez-ubeda-et-al.txt"
python /home/echernyak/graph_entity_linking/Fair-Evaluation-BERT/eval_bert_ranking.py --model_dir $MODEL \
    --data_folder "/home/echernyak/graph_entity_linking/data_medical_crossing/datasets/cantemist/test-set/cantemist-norm-concepts-fair_levenshtein_train_0.2" \
    --vocab "/home/echernyak/graph_entity_linking/data_medical_crossing/vocabs/CANTEMIST-lopez-ubeda-et-al.txt"


