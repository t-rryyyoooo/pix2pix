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


# Translating input
readonly DATA_DIRECTORY=$(eval echo $(cat ${JSON_FILE} | jq -r ".data_directory"))
readonly SAVE_DIRECTORY=$(eval echo $(cat ${JSON_FILE} | jq -r ".save_directory"))
readonly TRANSLATE_LIST=$(cat ${JSON_FILE} | jq -r ".translate_list[]")
readonly INPUT_NAME=$(cat ${JSON_FILE} | jq -r ".input_name")
readonly TRANSLATE_NAME=$(cat ${JSON_FILE} | jq -r ".translate_name")
readonly MODEL_PATH=$(eval echo $(cat ${JSON_FILE} | jq -r ".model_path"))
readonly MASK_NAME=$(cat ${JSON_FILE} | jq -r ".mask_name")
readonly INPUT_PATCH_WIDTH=$(cat ${JSON_FILE} | jq -r ".input_patch_width")
readonly TARGET_PATCH_WIDTH=$(cat ${JSON_FILE} | jq -r ".target_patch_width")
readonly PLANE_SIZE=$(cat ${JSON_FILE} | jq -r ".plane_size")
readonly AXIS=$(cat ${JSON_FILE} | jq -r ".axis")
readonly SLIDE=$(cat ${JSON_FILE} | jq -r ".slide")
readonly GPU_IDS=$(cat ${JSON_FILE} | jq -r ".gpu_ids")

for number in ${TRANSLATE_LIST[@]};
do
image_path="${DATA_DIRECTORY}/case_${number}/${INPUT_NAME}"
save_path="${SAVE_DIRECTORY}/case_${number}/${TRANSLATE_NAME}"

mask=`generateArgument $MASK_NAME --mask_image_path "${data}/${MASK_NAME}"`
slide=`generateArgument $SLIDE --slide`
input_patch_width=`generateArgument $INPUT_PATCH_WIDTH --input_patch_width`
target_patch_width=`generateArgument $TARGET_PATCH_WIDTH --target_patch_width`
plane_size=`generateArgument $PLANE_SIZE --plane_size`

printVarInfo image_path
printVarInfo MODEL_PATH
printVarInfo save_path
printVarInfo MASK_NAME
printVarInfo INPUT_PATCH_WIDTH
printVarInfo TARGET_PATCH_WIDTH
printVarInfo AXIS
printVarInfo SLIDE
printVarInfo PLANE_SIZE
printVarInfo GPU_IDS

python3 translate.py ${image_path} ${MODEL_PATH} ${save_path} --axis ${AXIS} --gpu_ids ${GPU_IDS} ${mask} ${slide} ${input_patch_width} ${target_patch_width} ${plane_size}

done
