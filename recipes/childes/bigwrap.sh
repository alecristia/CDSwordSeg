#!/usr/bin/env bash
#
# Wrapper to run childes experiments 2017
# Alex Cristia <alecristia@gmail.com> 2017-01-02


# Adapt the following variables, being careful to provide absolute paths
#ROOT="/fhgfs/bootphon/scratch/acristia/CDSwordSeg/"	#path to the CDSwordSeg folder - E.g. PATH_TO_SCRIPTS="/home/xcao/cao/projects/ANR_Alex/CDSwordSeg/"
#INPUT_FOLDER="/fhgfs/bootphon/scratch/xcao/Alex_CDS_ADS/Childes_Eng-NA/" #where you have put the talkbank corpora to be analyzedE.g. INPUT_CORPUS="/home/xcao/cao/projects/ANR_Alex/Childes_Eng-NA"
#PROCESSED_FOLDER="/fhgfs/bootphon/scratch/acristia/processed_corpora/Childes_Eng-NA-sel/"	#this is where we will put the processed versions of the transcripts E.g. RES_FOLDER="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/" - NOTICE THE / AT THE END OF THE NAME
#INPUT_FILE="/fhgfs/bootphon/scratch/acristia/CDSwordSeg/recipes/childes/cor2merge.csv" #E.g INPUT_FILES="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/childes_info.txt"
ROOT="/scratch1/users/acristia/CDSwordSeg/"	#path to the CDSwordSeg folder - E.g. PATH_TO_SCRIPTS="/home/xcao/cao/projects/ANR_Alex/CDSwordSeg/"
INPUT_FOLDER="/scratch1/users/acristia/data/Alex_CDS_ADS/res_Childes_Eng-NA_cds/Providence_res/"
PROCESSED_FOLDER="/scratch1/users/acristia/processed_corpora/Providence/"	#this is where we will put the processed versions of the transcripts E.g. RES_FOLDER="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/" - NOTICE THE / AT THE END OF THE NAME
# sample file /scratch1/users/acristia/data/Alex_CDS_ADS/res_Childes_Eng-NA_cds/Providence_res/eth01_cds/xx-ortholines.txt

module add festival
module add python-anaconda


# Do the selection and cleaning of cha-like files
#./1_selAndClean.sh $INPUT_FOLDER $INPUT_FILE $PROCESSED_FOLDER $ROOT > log_step1.txt || exit 1
#./1B_handannex.sh || exit 1

# Phonologize the ortholines files
#./2_ortho2phono.sh $PROCESSED_FOLDER $ROOT > log_step2_201801.txt || exit 1
./2_ortho2phono_perfile.sh $INPUT_FOLDER $ROOT  || exit 1


# Analyze
#./3_analyze.sh $PROCESSED_FOLDER $RES_FOLDER


# ./4_collapse_results.sh $RES_FOLDER
