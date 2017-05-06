#!/usr/bin/env bash

# Wrapper to run SegEngSpa M2 Project Laia Fibla 2016-2017
# Alex Cristia <alecristia@gmail.com> 2017-01-14
# Mathieu Bernard
# Laia Fibla 2017-01-19

############ VARIABLES ##############
# Here change the paths
ORIG_FOLDER="/fhgfs/bootphon/scratch/lfibla/seg/SegEngSpa/Bernstein/berns_all/original_corpus"
PROCESSED_FOLDER="/fhgfs/bootphon/scratch/lfibla/seg/SegEngSpa/Bernstein/berns_all/adapted_corpus/"
CONCATENATED_FOLDER="/fhgfs/bootphon/scratch/lfibla/seg/SegEngSpa/Bernstein/berns_all/conc_"
RES_FOLDER="/fhgfs/bootphon/scratch/lfibla/seg/results/Bernstein/segengspares_"
#####################################

# Matching phonology from English to Spanish to make language comparisons and create a bilingual corpus Eng Spa
#./1_match_phones.sh ${ORIG_FOLDER} ${PROCESSED_FOLDER}

# Cut the Bernstein coprus on small parts to be able to concatenate afterwards
divide_in_small_parts=10
#./2_cut_in_small_parts.sh ${PROCESSED_FOLDER} ${CONCATENATED_FOLDER} ${divide_in_small_parts}

# Concantenate monolingual corpus each 4 and 100 lines
#./3_concatenate_eng.sh ${CONCATENATED_FOLDER}eng/all ${CONCATENATED_FOLDER}eng/mixings/4
#./3_concatenate_eng.sh ${CONCATENATED_FOLDER}eng/all ${CONCATENATED_FOLDER}eng/mixings/100

#This step is to create an artificial bilingual coprus, here we are mixing each 4 and 100 lines
#rm -r ${CONCATENATED_FOLDER}bil_all/100/*
#rm -r ${CONCATENATED_FOLDER}bil_all/4/*
#./3b_concatenate_bil.sh ${CONCATENATED_FOLDER}eng/all ${CONCATENATED_FOLDER}bil_all
#echo "done concatenating"

# The bilingual copora is double size than the monolinguals, this step divides it in two parts
divide_half=2
#./4_cut.sh ${CONCATENATED_FOLDER}bil_all/4 ${CONCATENATED_FOLDER}bil_half/4 ${divide_half}
#./4_cut.sh ${CONCATENATED_FOLDER}bil_all/100 ${CONCATENATED_FOLDER}bil_half/100 ${divide_half}

# note, this step is just used with the big corpus!
# Divide the big corpus in 10 parts to evaluate the robustness of the F-score
divide_multiple=10
#./4_cut.sh ${CONCATENATED_FOLDER}eng/mixings/4 ${CONCATENATED_FOLDER}eng_10/4 ${divide_multiple}
#./4_cut.sh ${CONCATENATED_FOLDER}eng/mixings/100 ${CONCATENATED_FOLDER}eng_10/100 ${divide_multiple}

#./4_cut.sh ${CONCATENATED_FOLDER}bil_half/4/0 ${CONCATENATED_FOLDER}bil_half_10/4 ${divide_multiple}
#./4_cut.sh ${CONCATENATED_FOLDER}bil_half/100/0 ${CONCATENATED_FOLDER}bil_half_10/100 ${divide_multiple}

# Analyze
#rm -r ${RES_FOLDER}spa/100/AG*
#rm -r ${RES_FOLDER}cat/100/AG*
#rm -r ${RES_FOLDER}bil/100/*
#rm -r ${RES_FOLDER}spa_10/100/*
#rm -r ${RES_FOLDER}spa_10/4/*
#rm -r ${RES_FOLDER}cat_10/100/*
#rm -r ${RES_FOLDER}cat_10/4/*
#rm -r ${RES_FOLDER}bil_half_10/4/*
#./5_analyze.sh ${CONCATENATED_FOLDER}eng/mixings ${RES_FOLDER}eng
#./5_analyze.sh ${CONCATENATED_FOLDER}bil_all ${RES_FOLDER}bil
#./5_analyze.sh ${CONCATENATED_FOLDER}eng_10/4 ${RES_FOLDER}eng_10/4
#./5_analyze.sh ${CONCATENATED_FOLDER}eng_10/100 ${RES_FOLDER}eng_10/100

#./5_analyze.sh ${CONCATENATED_FOLDER}bil_half_10/4 ${RES_FOLDER}bil_half_10/4
#echo ${CONCATENATED_FOLDER}
#echo ${RES_FOLDER}

# Collapse results
#rm ${RES_FOLDER}eng/results.txt
#rm ${RES_FOLDER}spa/results.txt
#rm ${RES_FOLDER}bil_all/results.txt
#rm ${RES_FOLDER}eng_10/4/results.txt
#rm ${RES_FOLDER}eng_10/100/results.txt
#rm ${RES_FOLDER}spa_10/4/results.txt
#rm ${RES_FOLDER}spa_10/100/results.txt
#rm ${RES_FOLDER}bil_half_10/4/results.txt
#./6_collapse_results.sh ${RES_FOLDER}eng
#./6_collapse_results.sh ${RES_FOLDER}spa
#./6_collapse_results.sh ${RES_FOLDER}eng_10/4
#./6_collapse_results.sh ${RES_FOLDER}eng_10/100
#./6_collapse_results.sh ${RES_FOLDER}spa_10/4
#./6_collapse_results.sh ${RES_FOLDER}spa_10/100
#./6_collapse_results.sh ${RES_FOLDER}bil_all
#./6_collapse_results.sh ${RES_FOLDER}bil_half_10/4
#echo "done collapsing results"

# More analysis on the coprus
#./_describe_gold.sh
#./_compare_languages.sh
