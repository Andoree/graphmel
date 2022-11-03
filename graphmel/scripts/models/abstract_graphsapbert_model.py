from abc import ABC

import torch
from torch.cuda.amp import autocast


class AbstractGraphSapMetricLearningModel(ABC):

    @autocast()
    def calculate_sapbert_loss(self, emb_1, emb_2, labels, batch_size):
        text_embed = torch.cat([emb_1[:batch_size], emb_2[:batch_size]], dim=0)

        if self.use_miner:
            hard_pairs_text = self.miner(text_embed, labels)
            sapbert_loss = self.loss(text_embed, labels, hard_pairs_text)
        else:
            sapbert_loss = self.loss(text_embed, labels, )
        return sapbert_loss

    @autocast()
    def calculate_intermodal_loss(self, text_embed_1, text_embed_2, graph_embed_1, graph_embed_2, labels, batch_size):
        intermodal_loss = None
        if self.modality_distance == "sapbert":

            text_graph_embed_1 = torch.cat([text_embed_1[:batch_size], graph_embed_1[:batch_size]], dim=0)
            text_graph_embed_2 = torch.cat([text_embed_2[:batch_size], graph_embed_2[:batch_size]], dim=0)
            if self.use_intermodal_miner:
                intermodal_hard_pairs_1 = self.intermodal_miner(text_graph_embed_1, labels)
                intermodal_hard_pairs_2 = self.intermodal_miner(text_graph_embed_2, labels)
                intermodal_loss_1 = self.intermodal_loss(text_graph_embed_1, labels, intermodal_hard_pairs_1)
                intermodal_loss_2 = self.intermodal_loss(text_graph_embed_2, labels, intermodal_hard_pairs_2)
                intermodal_loss = (intermodal_loss_1 + intermodal_loss_2) / 2
            else:
                intermodal_loss_1 = self.intermodal_loss(text_graph_embed_1, labels, )
                intermodal_loss_2 = self.intermodal_loss(text_graph_embed_2, labels, )
                intermodal_loss = (intermodal_loss_1 + intermodal_loss_2) / 2

        elif self.modality_distance is not None:
            intermodal_loss_1 = self.intermodal_loss(text_embed_1[:batch_size], graph_embed_1[:batch_size])
            intermodal_loss_2 = self.intermodal_loss(text_embed_2[:batch_size], graph_embed_2[:batch_size])
            intermodal_loss = (intermodal_loss_1 + intermodal_loss_2) / 2
        return intermodal_loss

    @autocast()
    def eval_step_loss(self, term_1_input_ids, term_1_att_masks, term_2_input_ids, term_2_att_masks, concept_ids,
                       batch_size):
        """
        query : (N, h), candidates : (N, topk, h)

        output : (N, topk)
        """

        text_embed_1 = self.bert_encoder(term_1_input_ids, attention_mask=term_1_att_masks,
                                         return_dict=True)['last_hidden_state'][:batch_size, 0]
        text_embed_2 = self.bert_encoder(term_2_input_ids, attention_mask=term_2_att_masks,
                                         return_dict=True)['last_hidden_state'][:batch_size, 0]
        labels = torch.cat([concept_ids, concept_ids], dim=0)
        text_loss = self.calculate_sapbert_loss(text_embed_1, text_embed_2, labels, batch_size)

        return text_loss