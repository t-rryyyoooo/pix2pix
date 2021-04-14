#!/bin/bash

image_path="$HOME/Desktop/data/tsukubaData/kidney/case_001/SE3_resampled.nii.gz"
model_path="test/log/latest.pkl"
save_path="test/case_001/translate.mha"
python3 translate.py ${image_path} ${model_path} ${save_path}
