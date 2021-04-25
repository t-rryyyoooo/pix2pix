#!/bin/bash

# Input 
readonly INPUT_DIRECTORY="input"
echo -n "Is json file name sliceImage.json?[y/n]:"
read which
while [ ! $which = "y" -a ! $which = "n" ]
do
 echo -n "Is json file name the same as this file name?[y/n]:"
 read which
done

# Specify json file.
if [ $which = "y" ];then
 JSON_NAME="sliceImage.json"
else
 echo -n "JSON_FILE_NAME="
 read JSON_NAME
fi

# From json file, read required variables.
readonly JSON_FILE="${INPUT_DIRECTORY}/${JSON_NAME}"
readonly DATA_DIRECTORY=$(eval echo $(cat ${JSON_FILE} | jq -r ".data_directory"))
readonly SAVE_DIRECTORY=$(eval echo $(cat ${JSON_FILE} | jq -r ".save_directory"))
readonly INPUT_PATCH_SIZE=$(cat ${JSON_FILE} | jq -r ".input_patch_size")
readonly TARGET_PATCH_SIZE=$(cat ${JSON_FILE} | jq -r ".target_patch_size")
readonly PLANE_SIZE=$(cat ${JSON_FILE} | jq -r ".plane_size")
readonly INPUT_NAME=$(cat ${JSON_FILE} | jq -r ".input_name")
readonly TARGET_NAME=$(cat ${JSON_FILE} | jq -r ".target_name")
readonly MASK_NAME=$(cat ${JSON_FILE} | jq -r ".mask_name")
readonly SAVE_INPUT_NAME=$(cat ${JSON_FILE} | jq -r ".save_input_name")
readonly SAVE_TARGET_NAME=$(cat ${JSON_FILE} | jq -r ".save_target_name")
readonly SLIDE=$(cat ${JSON_FILE} | jq -r ".slide")
readonly AXIS=$(cat ${JSON_FILE} | jq -r ".axis")
readonly WITH_NONMASK=$(cat ${JSON_FILE} | jq -r ".with_nonmask")
readonly NUM_ARRAY=$(cat ${JSON_FILE} | jq -r ".num_array[]")
readonly LOG_FILE=$(eval echo $(cat ${JSON_FILE} | jq -r ".log_file"))

echo "LOG_FILE:${LOG_FILE}"

# Make directory to save LOG.
mkdir -p `dirname ${LOG_FILE}`
date >> $LOG_FILE

for number in ${NUM_ARRAY[@]}
do
 data="${DATA_DIRECTORY}/case_${number}"
 input="${data}/${INPUT_NAME}"
 target="${data}/${TARGET_NAME}"

 echo "input:${input}"
 echo "target:${target}"
 echo "SAVE_DIRECTORY:${SAVE_DIRECTORY}"
 echo "patient_id:${number}"
 echo "AXIS:${AXIS}"
 echo "SAVE_INPUT_NAME:${SAVE_INPUT_NAME}"
 echo "SAVE_TARGET_NAME:${SAVE_TARGET_NAME}"
 echo "WITH_NONMASK:${WITH_NONMASK}"

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

 mask=`generateArgument $MASK_NAME --mask_image_path "${data}/${MASK_NAME}"`
 input_patch_size=`generateArgument $INPUT_PATCH_SIZE --input_patch_size`
 target_patch_size=`generateArgument $TARGET_PATCH_SIZE --target_patch_size`
 plane_size=`generateArgument $PLANE_SIZE --plane_size`
 slide=`generateArgument $SLIDE --slide`

 echo "mask:${mask}"
 echo "INPUT_PATCH_SIZE:${INPUT_PATCH_SIZE}"
 echo "TARGET_PATCH_SIZE:${TARGET_PATCH_SIZE}"
 echo "PLANE_SIZE:${PLANE_SIZE}"
 echo "SLIDE:${SLIDE}"

 if [ $MASK_NAME = "No" ];then
  if $WITH_NONMASK ;then
   with_nonmask="--with_nonmask"

  else
   with_nonmask=""

  fi
 fi

 python3 sliceImage.py ${input} ${target} ${SAVE_DIRECTORY} ${number} ${mask} ${input_patch_size} ${target_patch_size} ${slide} --axis ${AXIS} --input_name ${SAVE_INPUT_NAME} --target_name ${SAVE_TARGET_NAME} ${with_nonmask} ${plane_size}


 # Judge if it works.
 if [ $? -eq 0 ]; then
  echo "case_${number} done."
 
 else
  echo "case_${number}" >> $LOG_FILE
  echo "case_${number} failed"
 
 fi

done


