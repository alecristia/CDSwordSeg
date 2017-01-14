#!/usr/bin/env bash
#
# Wrapper to run WinnipegLENA experiments 201511
# Alex Cristia <alecristia@gmail.com> 2015-11-26
# Mathieu Bernard


PROCESSED_FOLDER="/fhgfs/bootphon/scratch/lfibla/SegCatSpa/RES_corpus_"
CONCATENATED_FOLDER="/fhgfs/bootphon/scratch/lfibla/SegCatSpa/conc_"
RES_FOLDER="/fhgfs/bootphon/scratch/lfibla/SegCatSpa/res_"


# Turn the cha-like files into a single clean file per type
#./2_cha2ortho.sh $PROCESSED_FOLDER  || exit 1

# Phonologize the ortholines files
#./3_ortho2phono.sh $PROCESSED_FOLDER  || exit 1

#./3_laiconcatenate.sh ${PROCESSED_FOLDER}spa  ${CONCATENATED_FOLDER}spa
#./3_laiconcatenate.sh ${PROCESSED_FOLDER}cat  ${CONCATENATED_FOLDER}cat

./3B_concbil.sh ${PROCESSED_FOLDER}  ${CONCATENATED_FOLDER}bil

# Analyze
 ./4_analyze.sh ${PROCESSED_FOLDER}bil

#rm $RES_FOLDER/results.txt
#rm $RES_FOLDER/WL*/results.txt
# ./5_collapse_results.sh $RES_FOLDER
