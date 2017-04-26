#!/usr/bin/env bash
#
# Wrapper to run WinnipegLENA experiments 201511
# Alex Cristia <alecristia@gmail.com> 2017-01-14
# Mathieu Bernard
# Laia Fibla 2017-01-19

# Here change big_corpora or mini_corpora
PROCESSED_FOLDER="/fhgfs/bootphon/scratch/lfibla/seg/SegCatSpa/big_corpora/RES_corpus_"
CONCATENATED_FOLDER="/fhgfs/bootphon/scratch/lfibla/seg/SegCatSpa/big_corpora/conc_"
RES_FOLDER="/fhgfs/bootphon/scratch/lfibla/seg/results/big_corpora/segcatspares_"


# Turn the cha-like files into a single clean file per type
#./1_selAndClean.sh $PROCESSED_FOLDER  || exit 1

# Phonologize the ortholines files
#Language=cspanish
#Language=catalan
#./2_phonologize.sh $PROCESSED_FOLDER  || exit 1

# Concatenate
#rm -r ${PROCESSED_FOLDER}spa/*-cutlines.txt
#rm -r ${CONCATENATED_FOLDER}spa/100/*
#rm -r ${CONCATENATED_FOLDER}spa/4/*
#rm -r ${PROCESSED_FOLDER}cat/*-cutlines.txt
#rm -r ${CONCATENATED_FOLDER}cat/100/*
#rm -r ${CONCATENATED_FOLDER}cat/4/*
#./3_concatenate_mono.sh ${PROCESSED_FOLDER}spa  ${CONCATENATED_FOLDER}spa
#./3_concatenate_mono.sh ${PROCESSED_FOLDER}cat  ${CONCATENATED_FOLDER}cat

#rm -r ${CONCATENATED_FOLDER}bil/100/*
#rm -r ${CONCATENATED_FOLDER}bil/2/*
#./3b_concatenate_bil.sh ${PROCESSED_FOLDER}  ${CONCATENATED_FOLDER}bil
#echo "done concatenating"

# include head and tail MODIFY ! # note, this step is just used with the big corpus!
#divide=2
#./4_cut.sh ${CONCATENATED_FOLDER}bil ${CONCATENATED_FOLDER}bil_head
#./4_cut.sh ${CONCATENATED_FOLDER}bil ${CONCATENATED_FOLDER}bil_tail

# note, this step is just used with the big corpus!
#divide=10
#./4_cut.sh ${CONCATENATED_FOLDER}spa/2 ${CONCATENATED_FOLDER}spa_10/2
#./4_cut.sh ${CONCATENATED_FOLDER}spa/100 ${CONCATENATED_FOLDER}spa_10/100
#./4_cut.sh ${CONCATENATED_FOLDER}spa/4 ${CONCATENATED_FOLDER}spa_10/4
#./4_cut.sh ${CONCATENATED_FOLDER}cat/2 ${CONCATENATED_FOLDER}cat_10/2
#./4_cut.sh ${CONCATENATED_FOLDER}cat/100 ${CONCATENATED_FOLDER}cat_10/100
#./4_cut.sh ${CONCATENATED_FOLDER}cat/4 ${CONCATENATED_FOLDER}cat_10/4
#./4_cut.sh ${CONCATENATED_FOLDER}bil_head/2 ${CONCATENATED_FOLDER}bil_head_10/2
#./4_cut.sh ${CONCATENATED_FOLDER}bil_head/100 ${CONCATENATED_FOLDER}bil_head_10/100

# Analyze
#rm -r ${RES_FOLDER}spa/100/AG*
#rm -r ${RES_FOLDER}spa/2/AG*
#rm -r ${RES_FOLDER}cat/100/AG*
#rm -r ${RES_FOLDER}cat/2/AG*
#rm -r ${RES_FOLDER}bil_head/100/*
#rm -r ${RES_FOLDER}bil_head/2/*
#rm -r ${RES_FOLDER}bil_tail/100/*
#rm -r ${RES_FOLDER}bil_tail/2/*
#rm -r ${RES_FOLDER}bil/2/*
#rm -r ${RES_FOLDER}bil/100/*
#rm -r ${RES_FOLDER}spa_10/100/*
#rm -r ${RES_FOLDER}spa_10/2/*
#rm -r ${RES_FOLDER}spa_10/4/*
#rm -r ${RES_FOLDER}cat_10/100/*
#rm -r ${RES_FOLDER}spa_10/2/*
#rm -r ${RES_FOLDER}spa_10/4/*
#./5_analyze.sh ${CONCATENATED_FOLDER}spa ${RES_FOLDER}spa
#./5_analyze.sh ${CONCATENATED_FOLDER}cat ${RES_FOLDER}cat
#./5_analyze.sh ${CONCATENATED_FOLDER}bil_head ${RES_FOLDER}bil_head
#./5_analyze.sh ${CONCATENATED_FOLDER}bil_tail ${RES_FOLDER}bil_tail
#./5_analyze.sh ${CONCATENATED_FOLDER}bil ${RES_FOLDER}bil
#./5_analyze.sh ${CONCATENATED_FOLDER}spa_10/100 ${RES_FOLDER}spa_10/100
#./5_analyze.sh ${CONCATENATED_FOLDER}spa_10/2 ${RES_FOLDER}spa_10/2
#./5_analyze.sh ${CONCATENATED_FOLDER}spa_10/2 ${RES_FOLDER}spa_10/4
#./5_analyze.sh ${CONCATENATED_FOLDER}cat_10/2 ${RES_FOLDER}cat_10/2
#./5_analyze.sh ${CONCATENATED_FOLDER}cat_10/100 ${RES_FOLDER}cat_10/100
#./5_analyze.sh ${CONCATENATED_FOLDER}cat_10/100 ${RES_FOLDER}cat_10/4
#./5_analyze.sh ${CONCATENATED_FOLDER}bil_head_10/2 ${RES_FOLDER}bil_head_10/2
#echo "done analysing"
#echo ${RES_FOLDER}

# Collapse results
#rm ${RES_FOLDER}spa/results.txt
#rm ${RES_FOLDER}cat/results.txt
#rm ${RES_FOLDER}bil_head/results.txt
#rm ${RES_FOLDER}bil_tail/results.txt
#rm ${RES_FOLDER}bil/results.txt
rm ${RES_FOLDER}bil_head_10/2/results.txt
#./6_collapse_results.sh ${RES_FOLDER}spa_10/100
#./6_collapse_results.sh ${RES_FOLDER}spa_10/2
#./6_collapse_results.sh ${RES_FOLDER}spa_10/4
#./6_collapse_results.sh ${RES_FOLDER}cat_10/100
#./6_collapse_results.sh ${RES_FOLDER}cat_10/2
#./6_collapse_results.sh ${RES_FOLDER}cat_10/4
#./6_collapse_results.sh ${RES_FOLDER}bil_head
#./6_collapse_results.sh ${RES_FOLDER}bil_tail
#./6_collapse_results.sh ${RES_FOLDER}bil
./6_collapse_results.sh ${RES_FOLDER}bil_head_10/2
echo "done collapsing results"
