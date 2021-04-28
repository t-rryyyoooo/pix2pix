 generateArgument(){
  if [ $1 = "No" ];then
   echo ""
  
  else
   if [ $# = 3 ];then
    echo "$2 $3"
   else
    echo "$2 $1"
   fi

  fi
 }

printVarInfo(){
 #[ -n "$1" ] && printf "%7s : %s\n" "$1" ${!1:-(null)}
 echo "$1 : ${!1:-(null)}"
}

readonly INPUT_DIRECTORY="input"
JSON_NAME=${0//.sh/.json}

echo -n "Is json file name ${JSON_NAME}?[y/n]:"
read which
while [ ! $which = "y" -a ! $which = "n" ]
do
 echo -n "Is json file name ${JSON_NAME}?[y/n]:"
 read which
done

# Specify json file path.
if [ $which = "n" ];then
 echo -n "JSON_FILE_NAME="
 read JSON_NAME
fi

readonly JSON_FILE="${INPUT_DIRECTORY}/${JSON_NAME}"

readonly RUN_TRAINING=$(cat ${JSON_FILE} | jq -r ".run_training")
readonly RUN_TRANSLATING=$(cat ${JSON_FILE} | jq -r ".run_translating")

# Training input
readonly DATASET_PATH=$(eval echo $(cat ${JSON_FILE} | jq -r ".dataset_path"))
readonly LOG_PATH=$(eval echo $(cat ${JSON_FILE} | jq -r ".log_path"))
readonly TRAIN_LIST=$(cat ${JSON_FILE} | jq -r ".train_list")
readonly VAL_LIST=$(cat ${JSON_FILE} | jq -r ".val_list")
readonly TEST_LIST=$(cat ${JSON_FILE} | jq -r ".test_list")
readonly NUM_COLUMNS=$(cat ${JSON_FILE} | jq -r ".num_columns")
readonly LR=$(cat ${JSON_FILE} | jq -r ".lr")
readonly L1_LAMBDA=$(cat ${JSON_FILE} | jq -r ".l1_lambda")
readonly BATCH_SIZE=$(cat ${JSON_FILE} | jq -r ".batch_size")
readonly NUM_WORKERS=$(cat ${JSON_FILE} | jq -r ".num_workers")
readonly G_INPUT_CH=$(cat ${JSON_FILE} | jq -r ".g_input_ch")
readonly G_OUTPUT_CH=$(cat ${JSON_FILE} | jq -r ".g_output_ch")
readonly G_NAME=$(cat ${JSON_FILE} | jq -r ".g_name")
readonly D_INPUT_CH=$(cat ${JSON_FILE} | jq -r ".d_input_ch")
readonly D_NAME=$(cat ${JSON_FILE} | jq -r ".d_name")
readonly D_N_LAYERS=$(cat ${JSON_FILE} | jq -r ".d_n_layers")
readonly NGF=$(cat ${JSON_FILE} | jq -r ".ngf")
readonly EPOCH=$(cat ${JSON_FILE} | jq -r ".epoch")
readonly GPU_IDS=$(cat ${JSON_FILE} | jq -r ".gpu_ids")

# Translating input
readonly DATA_DIRECTORY=$(eval echo $(cat ${JSON_FILE} | jq -r ".data_directory"))
readonly TRANSLATE_LIST=$(cat ${JSON_FILE} | jq -r ".translate_list[]")
readonly INPUT_NAME=$(cat ${JSON_FILE} | jq -r ".input_name")
readonly TRANSLATE_NAME=$(cat ${JSON_FILE} | jq -r ".translate_name")
readonly MODEL_NAME=$(cat ${JSON_FILE} | jq -r ".model_name")
readonly MASK_NAME=$(cat ${JSON_FILE} | jq -r ".mask_name")
readonly INPUT_PATCH_WIDTH=$(cat ${JSON_FILE} | jq -r ".input_patch_width")
readonly TARGET_PATCH_WIDTH=$(cat ${JSON_FILE} | jq -r ".target_patch_width")
readonly PLANE_SIZE=$(cat ${JSON_FILE} | jq -r ".plane_size")
readonly OVERLAP=$(cat ${JSON_FILE} | jq -r ".overlap")
readonly AXIS=$(cat ${JSON_FILE} | jq -r ".axis")
readonly MIN_VALUE=$(cat ${JSON_FILE} | jq -r ".min_value")
readonly MAX_VALUE=$(cat ${JSON_FILE} | jq -r ".max_value")

if $RUN_TRAINING; then
 echo "---------- Training ----------"
 printVarInfo DATASET_PATH
 printVarInfo LOG_PATH
 printVarInfo TRAIN_LIST
 printVarInfo VAL_LIST
 printVarInfo TEST_LIST
 printVarInfo NUM_COLUMNS
 printVarInfo LR
 printVarInfo L1_LAMBDA
 printVarInfo BATCH_SIZE
 printVarInfo NUM_WORKERS
 printVarInfo G_INPUT_CH
 printVarInfo G_OUTPUT_CH
 printVarInfo G_NAME
 printVarInfo D_INPUT_CH
 printVarInfo D_NAME
 printVarInfo D_N_LAYERS
 printVarInfo NGF
 printVarInfo EPOCH
 printVarInfo GPU_IDS

 python3 train.py ${DATASET_PATH} ${LOG_PATH} --train_list ${TRAIN_LIST} --val_list ${VAL_LIST} --test_list ${TEST_LIST} --num_columns ${NUM_COLUMNS} --lr ${LR} --batch_size ${BATCH_SIZE} --num_workers ${NUM_WORKERS} --G_input_ch ${G_INPUT_CH} --G_output_ch ${G_OUTPUT_CH} --G_name ${G_NAME} --D_input_ch ${D_INPUT_CH} --D_name ${D_NAME} --ngf ${NGF} --epoch ${EPOCH} --gpu_ids ${GPU_IDS} --D_n_layers ${D_N_LAYERS}

else
  echo "---------- No training ----------"
fi

if $RUN_TRANSLATING; then
 echo "---------- Translating ----------"
 model_path="${LOG_PATH}/${MODEL_NAME}"
 for number in ${TRANSLATE_LIST[@]};
 do
  data="${DATA_DIRECTORY}/case_${number}"
  image_path="${data}/${INPUT_NAME}"
  save_path="${DATASET_PATH}/segmentation/case_${number}/${TRANSLATE_NAME}"

  mask=`generateArgument $MASK_NAME --mask_image_path "${data}/${MASK_NAME}"`
  plane_size=`generateArgument $PLANE_SIZE --plane_size`

  printVarInfo image_path
  printVarInfo model_path
  printVarInfo save_path
  printVarInfo MASK_NAME
  printVarInfo INPUT_PATCH_WIDTH
  printVarInfo TARGET_PATCH_WIDTH
  printVarInfo PLANE_SIZE
  printVarInfo OVERLAP 
  printVarInfo AXIS
  printVarInfo MIN_VALUE
  printVarInfo MAX_VALUE

  python3 translate.py ${image_path} ${model_path} ${save_path} ${mask} --input_patch_width ${INPUT_PATCH_WIDTH} --target_patch_width ${TARGET_PATCH_WIDTH} ${plane_size} --overlap ${OVERLAP} --axis ${AXIS} --min_value ${MIN_VALUE} --max_value ${MAX_VALUE} --gpu_ids ${GPU_IDS} 

 done
else
  echo "---------- No translating ----------"
fi

readonly IP_ADDR=`hostname -I | cut -d ' ' -f1`
JSON_SAVE_NAME="${IP_ADDR}.json"
JSON_SAVE_PATH="${LOG_PATH}/${JSON_SAVE_NAME}"
echo "Json file is copied to ${JSON_SAVE_PATH}"

cp ${JSON_FILE} ${JSON_SAVE_PATH}
