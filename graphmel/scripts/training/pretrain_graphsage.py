import logging
import os
import random
from argparse import ArgumentParser

import numpy as np
from tqdm import tqdm

from graphmel.scripts.training.data.dataset import NeighborSampler, \
    load_data_and_bert_model, convert_edges_tuples_to_edge_index
from graphmel.scripts.training.model import GraphSAGEOverBert
from graphmel.scripts.training.training import train_model
from graphmel.scripts.utils.io import save_dict
import torch
import torch.nn.functional as F


# from torch_geometric.data import NeighborSampler as RawNeighborSampler


def graphsage_step(model, input_ids, attention_mask, adjs, device):
    input_ids = input_ids.to(device)
    attention_mask = attention_mask.to(device)

    model_output = model(input_ids, attention_mask, adjs)
    model_output, pos_out, neg_out = model_output.split(model_output.size(0) // 3, dim=0)

    pos_loss = F.logsigmoid((model_output * pos_out).sum(-1)).mean()
    neg_loss = F.logsigmoid(-(model_output * neg_out).sum(-1)).mean()
    loss = -pos_loss - neg_loss

    return model_output, loss


def graphsage_train_epoch(model, train_loader, optimizer, device):
    model.train()
    total_loss = 0
    num_steps = 0

    for (batch_size, n_id, adjs, input_ids, attention_mask) in tqdm(train_loader, miniters=len(train_loader) // 100):
        # `adjs` holds a list of `(edge_index, e_id, size)` tuples.
        adjs = [adj.to(device) for adj in adjs]
        optimizer.zero_grad()
        model_output, loss = graphsage_step(model, input_ids, attention_mask, adjs, device)
        loss.backward()
        optimizer.step()

        total_loss += float(loss) * model_output.size(0)
        num_steps += 1

    return total_loss / len(train_loader), num_steps


def graphsage_val_epoch(model, val_loader, device):
    model.eval()
    total_loss = 0
    with torch.no_grad():
        for (batch_size, n_id, adjs, input_ids, attention_mask) in tqdm(val_loader, miniters=len(val_loader) // 100):
            # `adjs` holds a list of `(edge_index, e_id, size)` tuples.
            adjs = [adj.to(device) for adj in adjs]
            model_output, loss = graphsage_step(model, input_ids, attention_mask, adjs, device)
            total_loss += float(loss) * model_output.size(0)

    return total_loss / len(val_loader)


def main(args):
    output_dir = args.output_dir
    output_subdir = f"gs_{args.graphsage_num_layers}-{args.graphsage_num_channels}_" \
                    f"{'.'.join((str(x) for x in args.train_graph_num_neighbors))}_{args.graphsage_dropout}_" \
                    f"lr_{args.learning_rate}_b_{args.batch_size}_rwl_{args.num_neighbors}"
    output_dir = os.path.join(output_dir, output_subdir)
    if not os.path.exists(output_dir) and output_dir != '':
        os.makedirs(output_dir)
    model_descr_path = os.path.join(output_dir, "model_description.tsv")
    save_dict(save_path=model_descr_path, dictionary=vars(args), )

    bert_encoder, tokenizer, train_node_id2token_ids_dict, train_edges_tuples, val_node_id2token_ids_dict, val_edges_tuples = \
        load_data_and_bert_model(train_node2terms_path=args.train_node2terms_path,
                                 train_edges_path=args.train_edges_path,
                                 val_node2terms_path=args.val_node2terms_path,
                                 val_edges_path=args.val_edges_path, text_encoder_name=args.text_encoder,
                                 text_encoder_seq_length=args.text_encoder_seq_length, drop_relations_info=True)
    train_num_nodes = len(set(train_node_id2token_ids_dict.keys()))
    val_num_nodes = len(set(val_node_id2token_ids_dict.keys()))

    # train_edge_index = convert_edges_tuples_to_oriented_edge_index_with_relations(edges_tuples=train_edges_tuples)
    # val_edge_index = convert_edges_tuples_to_oriented_edge_index_with_relations(edges_tuples=val_edges_tuples)
    train_edge_index = convert_edges_tuples_to_edge_index(edges_tuples=train_edges_tuples)
    val_edge_index = convert_edges_tuples_to_edge_index(edges_tuples=val_edges_tuples)

    logging.info(f"There are {train_num_nodes} nodes in train and {val_num_nodes} nodes in validation")
    train_loader = NeighborSampler(node_id_to_token_ids_dict=train_node_id2token_ids_dict, edge_index=train_edge_index,
                                   sizes=args.train_graph_num_neighbors, random_walk_length=args.num_neighbors,
                                   batch_size=args.batch_size, num_workers=args.dataloader_num_workers,
                                   shuffle=True, num_nodes=train_num_nodes, seq_max_length=args.text_encoder_seq_length)
    val_loader = NeighborSampler(node_id_to_token_ids_dict=val_node_id2token_ids_dict, edge_index=val_edge_index,
                                 sizes=args.val_graph_num_neighbors, random_walk_length=args.num_neighbors,
                                 batch_size=args.batch_size, num_workers=args.dataloader_num_workers,
                                 shuffle=False, num_nodes=val_num_nodes, seq_max_length=args.text_encoder_seq_length)

    device = torch.device('cuda:0' if torch.cuda.is_available() else 'cpu')
    # device = torch.device('cpu')
    multigpu_flag = False
    if args.gpus > 1:
        multigpu_flag = True
    model = GraphSAGEOverBert(bert_encoder=bert_encoder, hidden_channels=args.graphsage_num_channels,
                              num_layers=args.graphsage_num_layers, multigpu_flag=multigpu_flag,
                              graphsage_dropout=args.graphsage_dropout).to(device)

    train_model(model=model, train_epoch_fn=graphsage_train_epoch, val_epoch_fn=graphsage_val_epoch,
                chkpnt_path=args.model_checkpoint_path, train_loader=train_loader, val_loader=val_loader,
                learning_rate=args.learning_rate, num_epochs=args.num_epochs, output_dir=output_dir,
                save_chkpnt_epoch_interval=args.save_every_N_epoch, device=device)


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)s %(message)s',
                        datefmt='%Y-%m-%d %H:%M:%S', )
    parser = ArgumentParser()
    parser.add_argument('--train_node2terms_path', type=str)
    parser.add_argument('--train_edges_path', type=str)
    parser.add_argument('--val_node2terms_path', type=str)
    parser.add_argument('--val_edges_path', type=str)
    parser.add_argument('--text_encoder', type=str)
    parser.add_argument('--text_encoder_seq_length', type=int)
    parser.add_argument('--dataloader_num_workers', type=int)
    parser.add_argument('--model_checkpoint_path', required=False, default=None)
    parser.add_argument('--save_every_N_epoch', type=int, default=1)
    parser.add_argument('--graphsage_num_layers', type=int)
    parser.add_argument('--graphsage_num_channels', type=int)
    parser.add_argument('--train_graph_num_neighbors', type=int, nargs='+', )
    parser.add_argument('--val_graph_num_neighbors', type=int, nargs='+', default=(7, 7))
    parser.add_argument('--graphsage_dropout', type=float, )
    parser.add_argument('--num_neighbors', type=int)
    parser.add_argument('--batch_size', type=int)
    parser.add_argument('--learning_rate', type=float)
    parser.add_argument('--num_epochs', type=int)
    parser.add_argument('--random_state', type=int)
    parser.add_argument('--gpus', type=int, default=1)
    parser.add_argument('--output_dir', type=str)
    arguments = parser.parse_args()
    seed = arguments.random_state
    torch.manual_seed(seed)
    torch.random.manual_seed(seed)
    os.environ['PYTHONHASHSEED'] = str(seed)
    random.seed(seed)
    np.random.seed(seed)
    torch.cuda.random.manual_seed(seed)
    torch.cuda.random.manual_seed_all(seed)
    torch.backends.cudnn.deterministic = True
    main(arguments)
