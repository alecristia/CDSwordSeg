#!/usr/bin/env bash
#
# Wrapper to run WinnipegLENA experiments 201511
# Alex Cristia <alecristia@gmail.com> 2017-01-14
# Mathieu Bernard
# Laia Fibla


PROCESSED_FOLDER="/fhgfs/bootphon/scratch/lfibla/SegCatSpa/RES_corpus_"
CONCATENATED_FOLDER="/fhgfs/bootphon/scratch/lfibla/SegCatSpa/conc_"
RES_FOLDER="/fhgfs/bootphon/scratch/lfibla/SegCatSpa/results/segcatspares_"


# Turn the cha-like files into a single clean file per type
#./1_cha2ortho.sh $PROCESSED_FOLDER  || exit 1

# Phonologize the ortholines files
#./2_ortho2phono.sh $PROCESSED_FOLDER  || exit 1

# Concatenate
#./3_laiconcatenate.sh ${PROCESSED_FOLDER}spa  ${CONCATENATED_FOLDER}spa
#./3_laiconcatenate.sh ${PROCESSED_FOLDER}cat  ${CONCATENATED_FOLDER}cat

#./3B_concbil.sh ${PROCESSED_FOLDER}  ${CONCATENATED_FOLDER}bil
#echo "done concatenating"

# include head and tail 

# Analyze
./4_analyze.sh ${CONCATENATED_FOLDER}spa ${RES_FOLDER}spa
#./4_analyze.sh ${CONCATENATED_FOLDER}cat ${RES_FOLDER}cat
#./4_analyze.sh ${CONCATENATED_FOLDER}bil_head ${RES_FOLDER}bil_head
#echo "done analysing"

# Collapese results
#rm ${RES_FOLDER}spa/results.txt
#rm ${RES_FOLDER}cat/results.txt
#rm ${RES_FOLDER}bil_head/results.txt
#./5_collapse_results.sh ${RES_FOLDER}spa
#./5_collapse_results.sh ${RES_FOLDER}cat
#./5_collapse_results.sh ${RES_FOLDER}bil_head

#echo "done collapsing results"
