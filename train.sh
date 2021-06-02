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

python3 train.py ${DATASET_PATH} ${LOG_PATH} --train_list ${TRAIN_LIST} --val_list ${VAL_LIST} --test_list ${TEST_LIST} --num_columns ${NUM_COLUMNS} --lr ${LR} --batch_size ${BATCH_SIZE} --num_workers ${NUM_WORKERS} --G_input_ch ${G_INPUT_CH} --G_output_ch ${G_OUTPUT_CH} --G_name ${G_NAME} --D_input_ch ${D_INPUT_CH} --D_name ${D_NAME} --ngf ${NGF} --epoch ${EPOCH} --gpu_ids ${GPU_IDS} --D_n_layers ${D_N_LAYERS}


readonly IP_ADDR=`hostname -I | cut -d ' ' -f1`
JSON_SAVE_NAME="${IP_ADDR}.json"
JSON_SAVE_PATH="${LOG_PATH}/${JSON_SAVE_NAME}"
echo "Json file is copied to ${JSON_SAVE_PATH}"

cp ${JSON_FILE} ${JSON_SAVE_PATH}
