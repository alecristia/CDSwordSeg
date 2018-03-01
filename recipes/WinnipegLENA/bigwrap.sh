#!/usr/bin/env bash
#
# Wrapper to run WinnipegLENA experiments 201511
# Alex Cristia <alecristia@gmail.com> 2015-11-26
# Mathieu Bernard

RAW_FOLDER="/scratch1/users/acristia/data/WinnipegLENA/trs"
PROCESSED_FOLDER="/scratch1/users/acristia/processed_corpora/WinnipegLENA"
RES_FOLDER="/scratch1/users/acristia/results/WinnipegLENA"

#if using dmcmc
module load boost

#if using an AG
module load python-anaconda

#if phonologizing
#module load festival

# Create the trs folder and put Winnipeg trs files in it
#./0_gettrs.sh $RAW_FOLDER $PROCESSED_FOLDER || exit 1

# Turn the trs files into cha-like format
#./1_trs2cha.sh $PROCESSED_FOLDER || exit 1

# Turn the cha-like files into a single clean file per type
#./2_cha2ortho.sh $PROCESSED_FOLDER  || exit 1

# Phonologize the ortholines files
#./3_ortho2phono.sh $PROCESSED_FOLDER  || exit 1

# Add length-matched versions of all the corpora
#./4_length_match.sh $PROCESSED_FOLDER  || exit 1

# Analyze
# ./5_analyze.sh $PROCESSED_FOLDER $RES_FOLDER || exit 1


#rm $RES_FOLDER/results.txt
#rm $RES_FOLDER/WL*/results.txt
# ./6_collapse_results.sh $RES_FOLDER

####### RESAMPLE FOR CONFIDENCE INTERVALS
#./7_cha2ortho_files.sh $PROCESSED_FOLDER  || exit 1
#./8_ortho2phono_files.sh $PROCESSED_FOLDER  || exit 1

#mkdir -p $PROCESSED_FOLDER/resamples/
#./9_generate_resamples.sh  $PROCESSED_FOLDER/phono/ $PROCESSED_FOLDER/resamples/ || exit 1
#./10_generate_gold.sh  $PROCESSED_FOLDER/resamples/ || exit 1

#mkdir -p ${RES_FOLDER}_resamples/
./11_analyze.sh $PROCESSED_FOLDER/resamples ${RES_FOLDER}_resamples/ || exit 1
#./12_collapse_res_resampling.sh ${RES_FOLDER}_resamples/
