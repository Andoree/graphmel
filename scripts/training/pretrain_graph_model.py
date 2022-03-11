import logging
import os
import random
from argparse import ArgumentParser

import numpy as np
import torch

from graphmel.scripts.training.dataset import tokenize_node_terms, NeighborSampler, convert_edges_tuples_to_edge_index
from graphmel.scripts.utils.io import load_node_id2terms_list, load_tuples, update_log_file
import torch
import torch.nn as nn
import torch.nn.functional as F
from sklearn.linear_model import LogisticRegression
from torch_geometric.nn import SAGEConv
# from torch_geometric.data import NeighborSampler as RawNeighborSampler
from transformers import AutoTokenizer
from transformers import AutoModel


class GraphSAGEOverBert(nn.Module):
    def __init__(self, bert_encoder, hidden_channels, num_layers, graphsage_dropout):
        super(GraphSAGEOverBert, self).__init__()
        self.num_layers = num_layers
        self.convs = nn.ModuleList()
        self.bert_encoder = bert_encoder
        self.bert_hidden_dim = bert_encoder.config.hidden_size
        self.graphsage_dropout = graphsage_dropout

        for i in range(num_layers):
            in_channels = self.bert_hidden_dim if i == 0 else hidden_channels
            self.convs.append(SAGEConv(in_channels, hidden_channels))

    def forward(self, input_ids, attention_mask, adjs):
        last_hidden_states = self.bert_encoder(input_ids, attention_mask=attention_mask,
                                               return_dict=True)['last_hidden_state']
        x = torch.stack([elem[0, :] for elem in last_hidden_states])
        for i, (edge_index, _, size) in enumerate(adjs):
            x_target = x[:size[1]]  # Target nodes are always placed first.
            x = self.convs[i]((x, x_target), edge_index)
            if i != self.num_layers - 1:
                x = x.relu()
                x = F.dropout(x, p=self.graphsage_dropout, training=self.training)
        return x

    def full_forward(self, x, edge_index):
        for i, conv in enumerate(self.convs):
            x = conv(x, edge_index)
            if i != self.num_layers - 1:
                x = x.relu()
                x = F.dropout(x, p=self.graphsage_dropout, training=self.training)
        return x


def model_step(model, input_ids, attention_mask, adjs, device):
    input_ids = input_ids.to(device)
    attention_mask = attention_mask.to(device)

    model_output = model(input_ids, attention_mask, adjs)
    model_output, pos_out, neg_out = model_output.split(model_output.size(0) // 3, dim=0)

    pos_loss = F.logsigmoid((model_output * pos_out).sum(-1)).mean()
    neg_loss = F.logsigmoid(-(model_output * neg_out).sum(-1)).mean()
    loss = -pos_loss - neg_loss

    return model_output, loss


def train_epoch(model, train_loader, optimizer, device):
    model.train()
    total_loss = 0
    num_steps = 0
    for (batch_size, n_id, adjs, input_ids, attention_mask) in train_loader:
        # `adjs` holds a list of `(edge_index, e_id, size)` tuples.
        adjs = [adj.to(device) for adj in adjs]
        optimizer.zero_grad()
        model_output, loss = model_step(model, input_ids, attention_mask, adjs, device)
        loss.backward()
        optimizer.step()

        total_loss += float(loss) * model_output.size(0)
        num_steps += 1

    return total_loss / len(train_loader), num_steps


def eval_epoch(model, val_loader, device):
    model.eval()
    total_loss = 0
    with torch.no_grad():
        for (batch_size, n_id, adjs, input_ids, attention_mask) in val_loader:
            # `adjs` holds a list of `(edge_index, e_id, size)` tuples.
            adjs = [adj.to(device) for adj in adjs]
            model_output, loss = model_step(model, input_ids, attention_mask, adjs, device)
            total_loss += float(loss) * model_output.size(0)

    return total_loss / len(val_loader)


def train_model(model, train_loader, val_loader, learning_rate: float, num_epochs: int, output_dir: str,
                device: torch.device):
    optimizer = torch.optim.Adam(model.parameters(), lr=learning_rate)
    log_file_path = os.path.join(output_dir, "training_log.txt")

    train_loss_history = []
    val_loss_history = []
    logging.info("Starting training process....")
    global_num_steps = 0
    for i in range(num_epochs):
        epoch_train_loss, num_steps = train_epoch(model=model, train_loader=train_loader, optimizer=optimizer,
                                                  device=device)
        global_num_steps += num_steps
        epoch_val_loss_1 = eval_epoch(model=model, val_loader=val_loader, device=device)
        epoch_val_loss_2 = eval_epoch(model=model, val_loader=val_loader, device=device)
        assert epoch_val_loss_1 == epoch_val_loss_2
        log_dict = {"epoch": i, "train loss": {epoch_train_loss}, "val loss": epoch_val_loss_1}
        logging.info(', '.join((f"{k}: {v}" for k, v in log_dict.items())))

        # TODO: Потом убрать двойную проверку как удостоверюсь, что валидация детерминирована
        train_loss_history.append(epoch_train_loss)
        val_loss_history.append(epoch_val_loss_1)

        chkpnt_path = os.path.join(output_dir, f"checkpoint_e_{i}_steps_{num_steps}")
        torch.save(model.state_dict(), chkpnt_path)
        update_log_file(path=log_file_path, dict_to_log=log_dict)


def main(args):
    output_dir = args.output_dir
    if not os.path.exists(output_dir) and output_dir != '':
        os.makedirs(output_dir)
    train_node_id2terms_dict = load_node_id2terms_list(dict_path=args.train_node2terms_path, )
    train_edges_tuples = load_tuples(args.train_edges_path)
    val_node_id2terms_dict = load_node_id2terms_list(dict_path=args.val_node2terms_path, )
    val_edges_tuples = load_tuples(args.val_edges_path)

    tokenizer = AutoTokenizer.from_pretrained(args.text_encoder)
    bert_encoder = AutoModel.from_pretrained(args.text_encoder)

    train_node_id2token_ids_dict = tokenize_node_terms(train_node_id2terms_dict, tokenizer,
                                                       max_length=args.text_encoder_seq_length)
    train_num_nodes = len(set(train_node_id2terms_dict.keys()))
    train_edge_index = convert_edges_tuples_to_edge_index(edges_tuples=train_edges_tuples, num_nodes=train_num_nodes)

    val_node_id2token_ids_dict = tokenize_node_terms(val_node_id2terms_dict, tokenizer,
                                                     max_length=args.text_encoder_seq_length)
    val_num_nodes = len(set(val_node_id2terms_dict.keys()))
    val_edge_index = convert_edges_tuples_to_edge_index(edges_tuples=val_edges_tuples, num_nodes=val_num_nodes)

    train_loader = NeighborSampler(node_id_to_token_ids_dict=train_node_id2token_ids_dict, edge_index=train_edge_index,
                                   sizes=args.num_graph_neighbors, random_walk_length=args.random_walk_length,
                                   batch_size=args.batch_size,
                                   shuffle=True, num_nodes=train_num_nodes, seq_max_length=args.text_encoder_seq_length)
    val_loader = NeighborSampler(node_id_to_token_ids_dict=val_node_id2token_ids_dict, edge_index=val_edge_index,
                                 sizes=args.num_graph_neighbors, random_walk_length=args.random_walk_length,
                                 batch_size=args.batch_size,
                                 shuffle=False, num_nodes=val_num_nodes, seq_max_length=args.text_encoder_seq_length)

    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

    model = GraphSAGEOverBert(bert_encoder=bert_encoder, hidden_channels=args.graphsage_num_channels,
                              num_layers=args.graphsage_num_layers,
                              graphsage_dropout=args.graphsage_dropout).to(device)
    train_model(model=model, train_loader=train_loader, val_loader=val_loader, learning_rate=args.learning_rate,
                num_epochs=args.num_epochs, output_dir=output_dir, device=device)


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
    parser.add_argument('--graphsage_num_layers', type=int)
    parser.add_argument('--graphsage_num_channels', type=int)
    parser.add_argument('--graph_num_neighbors', type=int, nargs='+', )
    parser.add_argument('--graphsage_dropout', type=float, )
    parser.add_argument('--random_walk_length', type=int)
    parser.add_argument('--batch_size', type=int)
    parser.add_argument('--learning_rate', type=float)
    parser.add_argument('--num_epochs', type=int)
    parser.add_argument('--random_state', type=int)
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