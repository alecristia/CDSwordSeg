#!/usr/bin/env bash
#
# Wrapper to run WinnipegLENA experiments 201511
# Alex Cristia <alecristia@gmail.com> 2017-01-14
# Mathieu Bernard
# Laia Fibla 2017-01-19


PROCESSED_FOLDER="/fhgfs/bootphon/scratch/lfibla/seg/SegCatSpa/RES_corpus_"
CONCATENATED_FOLDER="/fhgfs/bootphon/scratch/lfibla/seg/SegCatSpa/conc_"
RES_FOLDER="/fhgfs/bootphon/scratch/lfibla/seg/results/segcatspares_"


# Turn the cha-like files into a single clean file per type
#./1_cha2ortho.sh $PROCESSED_FOLDER  || exit 1

# Phonologize the ortholines files
#./2_ortho2phono.sh $PROCESSED_FOLDER  || exit 1

# Concatenate
#rm -r ${PROCESSED_FOLDER}spa/*-cutlines.txt
#rm -r ${CONCATENATED_FOLDER}spa/*/*
#./3_laiconcatenate.sh ${PROCESSED_FOLDER}spa  ${CONCATENATED_FOLDER}spa
#./3_laiconcatenate.sh ${PROCESSED_FOLDER}cat  ${CONCATENATED_FOLDER}cat

#rm -r ${CONCATENATED_FOLDER}bil/100/*
#rm -r ${CONCATENATED_FOLDER}bil/2/*
#./3B_concbil.sh ${PROCESSED_FOLDER}  ${CONCATENATED_FOLDER}bil
#echo "done concatenating"

# include head and tail
./3C_cut.sh ${CONCATENATED_FOLDER}bil ${CONCATENATED_FOLDER}bil_head
./3C_cut.sh ${CONCATENATED_FOLDER}bil ${CONCATENATED_FOLDER}bil_tail

# Analyze
#rm -r ${RES_FOLDER}spa/100/AG*
#rm -r ${RES_FOLDER}spa/2/AG*
#rm -r ${RES_FOLDER}cat/100/AG*
#rm -r ${RES_FOLDER}cat/2/AG*
rm -r ${RES_FOLDER}bil_head/100/*
rm -r ${RES_FOLDER}bil_head/2/*
rm -r ${RES_FOLDER}bil_tail/100/*
rm -r ${RES_FOLDER}bil_tail/2/*
rm -r ${RES_FOLDER}bil/2/*
rm -r ${RES_FOLDER}bil/100/*
#./4_analyze.sh ${CONCATENATED_FOLDER}spa ${RES_FOLDER}spa
#./4_analyze.sh ${CONCATENATED_FOLDER}cat ${RES_FOLDER}cat
./4_analyze.sh ${CONCATENATED_FOLDER}bil_head ${RES_FOLDER}bil_head
./4_analyze.sh ${CONCATENATED_FOLDER}bil_tail ${RES_FOLDER}bil_tail
./4_analyze.sh ${CONCATENATED_FOLDER}bil ${RES_FOLDER}bil
echo "done analysing"
echo ${RES_FOLDER}

# Collapse results
#rm ${RES_FOLDER}spa/results.txt
#rm ${RES_FOLDER}cat/results.txt
#rm ${RES_FOLDER}bil_head/results.txt
#rm ${RES_FOLDER}bil_tail/results.txt
#rm ${RES_FOLDER}bil/results.txt
#./5_collapse_results.sh ${RES_FOLDER}spa
#./5_collapse_results.sh ${RES_FOLDER}cat
#./5_collapse_results.sh ${RES_FOLDER}bil_head
#./5_collapse_results.sh ${RES_FOLDER}bil_tail
#./5_collapse_results.sh ${RES_FOLDER}bil

#echo "done collapsing results"
