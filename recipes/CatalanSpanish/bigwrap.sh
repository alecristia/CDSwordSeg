#!/usr/bin/env bash

# Wrapper to run WinnipegLENA experiments 201511
# Alex Cristia <alecristia@gmail.com> 2017-01-14
# Mathieu Bernard
# Laia Fibla 2017-01-19

# Here change big_corpora or mini_corpora
PROCESSED_FOLDER="/fhgfs/bootphon/scratch/lfibla/seg/SegCatSpa/big_corpora/RES_corpus_"
CONCATENATED_FOLDER="/fhgfs/bootphon/scratch/lfibla/seg/SegCatSpa/big_corpora/conc_"
RES_FOLDER="/fhgfs/bootphon/scratch/lfibla/seg/results/big_corpora/segcatspares_"

# 1 and 2 to be adapted 
# Turn the cha-like files into a single clean file per type
#./1_selAndClean.sh $PROCESSED_FOLDER  || exit 1

# Phonologize the ortholines files
#Language1=cspanish
#Language2=catalan
#./2_phonologize.sh $PROCESSED_FOLDER  || exit 1

# Concatenate
#./3_concatenate_mono.sh ${PROCESSED_FOLDER}spa  ${CONCATENATED_FOLDER}spa
#./3_concatenate_mono.sh ${PROCESSED_FOLDER}cat  ${CONCATENATED_FOLDER}cat

#This step is to create an artificial bilingual coprus, here we are mixing each 4 and 100 lines
#rm -r ${CONCATENATED_FOLDER}bil_all/100/*
#rm -r ${CONCATENATED_FOLDER}bil_all/4/*
#./3b_concatenate_bil.sh ${PROCESSED_FOLDER} ${CONCATENATED_FOLDER}bil_all
#echo "done concatenating"

# The bilingual copora is double size than the monolinguals, this step divides it in two parts
divide_half=2
#./4_cut.sh ${CONCATENATED_FOLDER}bil_all/4 ${CONCATENATED_FOLDER}bil_half/4 ${divide_half}
#./4_cut.sh ${CONCATENATED_FOLDER}bil_all/100 ${CONCATENATED_FOLDER}bil_half/100 ${divide_half}

# note, this step is just used with the big corpus!
# Divide the big corpus in 10 parts to evaluate the robustness of the F-score
divide_multiple=10
#./4_cut.sh ${CONCATENATED_FOLDER}spa/100 ${CONCATENATED_FOLDER}spa_10/100 ${divide_multiple}
#./4_cut.sh ${CONCATENATED_FOLDER}spa/4 ${CONCATENATED_FOLDER}spa_10/4 ${divide_multiple}
#./4_cut.sh ${CONCATENATED_FOLDER}cat/100 ${CONCATENATED_FOLDER}cat_10/100 ${divide_multiple}
#./4_cut.sh ${CONCATENATED_FOLDER}cat/4 ${CONCATENATED_FOLDER}cat_10/4 ${divide_multiple}
#./4_cut.sh ${CONCATENATED_FOLDER}bil_half/4/0 ${CONCATENATED_FOLDER}bil_half_10/4 ${divide_multiple}
#./4_cut.sh ${CONCATENATED_FOLDER}bil_half/100/0 ${CONCATENATED_FOLDER}bil_half_10/100 ${divide_multiple}

# Analyze
#rm -r ${RES_FOLDER}spa/100/AG*
#rm -r ${RES_FOLDER}cat/100/AG*
rm -r ${RES_FOLDER}bil_half_10/4/*
#rm -r ${RES_FOLDER}bil/100/*
#rm -r ${RES_FOLDER}spa_10/100/*
#rm -r ${RES_FOLDER}spa_10/4/*
#rm -r ${RES_FOLDER}cat_10/100/*
#rm -r ${RES_FOLDER}cat_10/4/*
#./5_analyze.sh ${CONCATENATED_FOLDER}spa ${RES_FOLDER}spa
#./5_analyze.sh ${CONCATENATED_FOLDER}cat ${RES_FOLDER}cat
#./5_analyze.sh ${CONCATENATED_FOLDER}bil ${RES_FOLDER}bil
#./5_analyze.sh ${CONCATENATED_FOLDER}spa_10/100 ${RES_FOLDER}spa_10/100
#./5_analyze.sh ${CONCATENATED_FOLDER}spa_10/4 ${RES_FOLDER}spa_10/4
#./5_analyze.sh ${CONCATENATED_FOLDER}cat_10/100 ${RES_FOLDER}cat_10/100
#./5_analyze.sh ${CONCATENATED_FOLDER}cat_10/100 ${RES_FOLDER}cat_10/4
./5_analyze.sh ${CONCATENATED_FOLDER}bil_half_10/4 ${RES_FOLDER}bil_half_10/4
echo ${CONCATENATED_FOLDER}
echo ${RES_FOLDER}

# Collapse results
#rm ${RES_FOLDER}spa/results.txt
#rm ${RES_FOLDER}cat/results.txt
#rm ${RES_FOLDER}bil_head/results.txt
#rm ${RES_FOLDER}bil_tail/results.txt
#rm ${RES_FOLDER}bil/results.txt
#rm ${RES_FOLDER}bil_head_10/2/results.txt
#rm ${RES_FOLDER}spa_10/100/results.txt
#rm ${RES_FOLDER}spa_10/2/results.txt
#rm ${RES_FOLDER}spa_10/4/results.txt
#./6_collapse_results.sh ${RES_FOLDER}spa/
#./6_collapse_results.sh ${RES_FOLDER}spa_10/100
#./6_collapse_results.sh ${RES_FOLDER}spa_10/2
#./6_collapse_results.sh ${RES_FOLDER}spa_10/4
#./6_collapse_results.sh ${RES_FOLDER}cat/
#./6_collapse_results.sh ${RES_FOLDER}cat_10/100
#./6_collapse_results.sh ${RES_FOLDER}cat_10/2
#./6_collapse_results.sh ${RES_FOLDER}cat_10/4
#./6_collapse_results.sh ${RES_FOLDER}bil_head
#./6_collapse_results.sh ${RES_FOLDER}bil_tail
#./6_collapse_results.sh ${RES_FOLDER}bil
#./6_collapse_results.sh ${RES_FOLDER}bil_head_10/2
#echo "done collapsing results"

# More analysis on the coprus
#./_describe_gold.sh 
