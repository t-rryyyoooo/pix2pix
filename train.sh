#!/bin/bash

dataset_path="$HOME/Desktop/data/edges2shoes/pix2pix_test"
model_savepath="test/data/modelweight"
train_list="00"
val_list="01"
batch_size=4
G_input_ch=3
G_output_ch=3
D_input_ch=6
epoch=15
gpu_ids="0"

python3 train.py ${dataset_path} ${model_savepath} --train_list ${train_list} --val_list ${val_list} --batch_size ${batch_size} --G_input_ch ${G_input_ch} --G_output_ch ${G_output_ch} --D_input_ch ${D_input_ch} --epoch ${epoch} --gpu_ids ${gpu_ids}
