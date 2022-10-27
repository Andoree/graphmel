import torch
from torch import nn as nn
from torch.nn import functional as F, Parameter
from torch_geometric.nn import SAGEConv, FastRGCNConv, RGCNConv, GATv2Conv
from torch_geometric.nn.inits import glorot


class GraphSAGEEncoder(nn.Module):
    def __init__(self, in_channels, num_outer_layers: int, num_inner_layers: int, num_hidden_channels,
                 dropout_p: float, set_out_input_dim_equal: bool = False):
        super().__init__()
        self.convs = nn.ModuleList()
        self.num_outer_layers = num_outer_layers
        self.num_inner_layers = num_inner_layers
        self.num_hidden_channels = num_hidden_channels
        self.dropout_p = dropout_p
        self.set_out_input_dim_equal = set_out_input_dim_equal

        for i in range(num_outer_layers):
            inner_convs = nn.ModuleList()
            for j in range(num_inner_layers):
                input_num_channels = in_channels if (j == 0 and i == 0) else num_hidden_channels

                output_num_channels = num_hidden_channels
                if set_out_input_dim_equal and (i == num_outer_layers - 1) and (j == num_inner_layers - 1):
                    output_num_channels = in_channels
                sage_conv = SAGEConv(input_num_channels, output_num_channels)
                inner_convs.append(sage_conv)

            self.convs.append(inner_convs)

        self.gelu = nn.GELU()

    def forward(self, embs, adjs, *args, **kwargs):
        x = embs
        for i, ((edge_index, _, size), inner_convs_list) in enumerate(zip(adjs, self.convs)):
            for j, conv in enumerate(inner_convs_list):
                x = conv(x, edge_index)
                if not (i == self.num_outer_layers - 1 and j == self.num_inner_layers - 1):
                    x = F.dropout(x, p=self.dropout_p, training=self.training)

                    x = self.gelu(x)

        return x


class ModalityDistanceLoss(nn.Module):
    def __init__(self, dist_name):
        super(ModalityDistanceLoss, self).__init__()
        self.dist_name = dist_name
        if dist_name == "cosine":
            self.distance = nn.CosineSimilarity()
        elif dist_name == "MSE":
            self.distance = nn.MSELoss()
        else:
            raise AttributeError(f"Invalid dist_name: {self.dist_name}")

    def forward(self, text_emb, graph_emb):
        loss = torch.mean(self.distance(text_emb, graph_emb))
        if self.dist_name == "cosine":
            loss = 1. - loss
        return loss


# class GCNLayer(nn.Module):
#     def __init__(self, in_channels, hidden_channels, add_self_loops: bool):
#         super().__init__()
#         self.conv = GCNConv(in_channels, hidden_channels, cached=True, add_self_loops=add_self_loops)
#         self.prelu = nn.PReLU(hidden_channels)
#
#     def forward(self, x, edge_index):
#         x = self.conv(x, edge_index=edge_index)
#         x = self.prelu(x)
#         return x


class RGCNEncoder(nn.Module):
    def __init__(self, in_channels, num_outer_layers: int, num_inner_layers: int, num_hidden_channels: int,
                 dropout_p: float, use_fast_conv: bool, num_bases: int, num_blocks: int, num_relations: int,
                 set_out_input_dim_equal: bool):
        super().__init__()
        RGCNConvClass = FastRGCNConv if use_fast_conv else RGCNConv
        self.num_outer_layers = num_outer_layers
        self.num_inner_layers = num_inner_layers
        self.num_hidden_channels = num_hidden_channels
        self.dropout_p = dropout_p
        self.set_out_input_dim_equal = set_out_input_dim_equal

        self.convs = nn.ModuleList()
        for i in range(num_outer_layers):
            inner_convs = nn.ModuleList()
            for j in range(num_inner_layers):
                input_num_channels = in_channels if (j == 0 and i == 0) else num_hidden_channels

                output_num_channels = num_hidden_channels
                if set_out_input_dim_equal and (i == num_outer_layers - 1) and (j == num_inner_layers - 1):
                    output_num_channels = in_channels

                rgcn_conv = RGCNConvClass(in_channels=input_num_channels, out_channels=output_num_channels,
                                          num_relations=num_relations, num_bases=num_bases, num_blocks=num_blocks, )
                inner_convs.append(rgcn_conv)

            self.convs.append(inner_convs)

        self.gelu = nn.GELU()

    def forward(self, embs, adjs, rel_types, batch_size, ):
        x = embs
        for i, ((edge_index, _, size), inner_convs_list, rel_type) in enumerate(zip(adjs, self.convs, rel_types)):
            for j, conv in enumerate(inner_convs_list):
                x = conv(x, edge_index=edge_index, edge_type=rel_type)
                if not (i == self.num_outer_layers - 1 and j == self.num_inner_layers - 1):
                    x = F.dropout(x, p=self.dropout_p, training=self.training)
                    x = self.gelu(x)

        return x


class GATv2Encoder(nn.Module):
    def __init__(self, in_channels, num_outer_layers: int, num_inner_layers: int, num_hidden_channels, dropout_p: float,
                 num_relations: int, num_att_heads: int, attention_dropout_p: float, set_out_input_dim_equal):
        super().__init__()

        self.num_outer_layers = num_outer_layers
        self.num_inner_layers = num_inner_layers
        self.num_att_heads = num_att_heads
        self.num_hidden_channels = num_hidden_channels
        self.dropout_p = dropout_p
        self.convs = nn.ModuleList()
        for i in range(num_outer_layers):
            inner_convs = nn.ModuleList()
            for j in range(num_inner_layers):
                input_num_channels = in_channels if (j == 0 and i == 0) else num_hidden_channels

                output_num_channels = num_hidden_channels
                if set_out_input_dim_equal and (i == num_outer_layers - 1) and (j == num_inner_layers - 1):
                    output_num_channels = in_channels
                gat_conv = GATv2Conv(in_channels=input_num_channels, out_channels=output_num_channels,
                                     heads=num_att_heads, dropout=attention_dropout_p,
                                     add_self_loops=False, edge_dim=in_channels, share_weights=True)
                inner_convs.append(gat_conv)

            self.convs.append(inner_convs)

        self.gelu = nn.GELU()
        self.relation_matrices = Parameter(torch.Tensor(num_relations, in_channels * 2, in_channels))
        glorot(self.relation_matrices)

    def create_edge_attrs(self, embs, adjs, edge_type_list):
        edge_attrs_list = []

        rel_matrices_list = [self.relation_matrices[edge_type] for edge_type in edge_type_list]
        for (edge_index, _, size), rel_matrices in zip(adjs, rel_matrices_list):
            edge_src_node_ids = edge_index[0]
            edge_trg_node_ids = edge_index[1]

            e_src_emb = embs[edge_src_node_ids]
            e_trg_emb = embs[edge_trg_node_ids]

            assert e_src_emb.dim() == e_trg_emb.dim() == 2

            e_emb = torch.cat((e_src_emb, e_trg_emb), dim=1)
            e_emb = self.gelu(torch.bmm(e_emb.unsqueeze(1), rel_matrices).squeeze(1))

            edge_attrs_list.append(e_emb)
        return edge_attrs_list

    def forward(self, embs, adjs, edge_type_list, batch_size):
        edge_attrs_list = self.create_edge_attrs(embs=embs, adjs=adjs, edge_type_list=edge_type_list)
        x = embs
        for i, ((edge_index, _, size), inner_convs_list, edge_attr) in enumerate(
                zip(adjs, self.convs, edge_attrs_list)):
            for j, conv in enumerate(inner_convs_list):
                x = conv(x, edge_index=edge_index, edge_attr=edge_attr)
                if not (i == self.num_outer_layers - 1 and j == self.num_inner_layers - 1):
                    x = F.dropout(x, p=self.dropout_p, training=self.training)
                    x = self.gelu(x)
        return x