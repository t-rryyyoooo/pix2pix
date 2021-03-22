#!/bin/bash

image_dir="/home/vmlab/Desktop/data/edges2shoes/pix2pix_test/case_01"
model_path="test/data/modelweight/latest.pkl"
save_dir="test"
python3 translate.py ${image_dir} ${model_path} ${save_dir}
