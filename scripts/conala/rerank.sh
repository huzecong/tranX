#!/bin/bash
set -e

seed=0
#vocab="data/conala/vocab.src_freq3.code_freq3.mined_100000.snippet5.bin"
vocab="data/conala/vocab.src_freq3.code_freq3.mined_100000.goldmine_intent_count100k_topk1_temp5.bin"
dev_file="data/conala/dev.bin"
test_file="data/conala/test.var_str_sep.bin"
dev_decode_file=$1".dev.bin.decode"
test_decode_file=$1".test.decode"
dropout=0.3
hidden_size=256
embed_size=128
action_embed_size=128
field_embed_size=64
type_embed_size=64
lr=0.001
lr_decay=0.5
batch_size=16
max_epoch=80
beam_size=15
lstm='lstm'  # lstm
lr_decay_after_epoch=15
num_workers=70
model_name=reranker.conala.$(basename ${vocab})

echo "**** Writing results to logs/conala/${model_name}.log ****"
mkdir -p logs/conala
echo commit hash: `git rev-parse HEAD` > logs/conala/${model_name}.log

python -u exp.py \
    --cuda \
    --seed ${seed} \
    --mode rerank \
    --batch-size ${batch_size} \
    --evaluator conala_evaluator \
    --asdl-file asdl/lang/py3/py3_asdl.simplified.txt \
    --transition-system python3 \
    --load-reranker saved_models/conala/reranker.conala.vocab.src_freq3.code_freq3.mined_100000.intent_count100k_topk1_temp5.bin \
    --save-decode-to decodes/conala/${model_name}.best \
    --dev-file ${dev_file} \
    --test-file ${test_file} \
    --dev-decode-file ${dev_decode_file} \
    --test-decode-file ${test_decode_file} \
    --vocab ${vocab} \
    --features reconstructor paraphrase_identifier word_cnt parser_score \
    --lstm ${lstm} \
    --num-workers ${num_workers} \
    --no-parent-field-type-embed \
    --no-parent-production-embed \
    --hidden-size ${hidden_size} \
    --embed-size ${embed_size} \
    --action-embed-size ${action_embed_size} \
    --field-embed-size ${field_embed_size} \
    --type-embed-size ${type_embed_size} \
    --dropout ${dropout} \
    --patience 5 \
    --max-num-trial 5 \
    --glorot-init \
    --lr ${lr} \
    --lr-decay ${lr_decay} \
    --lr-decay-after-epoch ${lr_decay_after_epoch} \
    --max-epoch ${max_epoch} \
    --beam-size ${beam_size} \
    --log-every 50 \
    --save-to saved_models/conala/${model_name} 2>&1 | tee logs/conala/${model_name}.log

