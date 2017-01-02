#!/usr/bin/env bash
#
# Wrapper to run childes experiments 2017
# Alex Cristia <alecristia@gmail.com> 2017-01-02


# Adapt the following variables, being careful to provide absolute paths
ROOT="/fhgfs/bootphon/scratch/acristia/CDSwordSeg/"	#path to the CDSwordSeg folder - E.g. PATH_TO_SCRIPTS="/home/xcao/cao/projects/ANR_Alex/CDSwordSeg/"

INPUT_FOLDER="/fhgfs/bootphon/scratch/xcao/Alex_CDS_ADS/Childes_Eng-NA" #where you have put the talkbank corpora to be analyzedE.g. INPUT_CORPUS="/home/xcao/cao/projects/ANR_Alex/Childes_Eng-NA"

PROCESSED_FOLDER="/fhgfs/bootphon/scratch/acristia/processed_corpora/Childes_Eng-NA-sel/"	#this is where we will put the processed versions of the transcripts E.g. RES_FOLDER="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/" - NOTICE THE / AT THE END OF THE NAME


INPUT_FILE="/fhgfs/bootphon/scratch/scratch/acristia/CDSwordSeg/recipes/childes/cor2merge.csv" #E.g INPUT_FILES="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/childes_info.txt"

OUTPUT_FILE="/fhgfs/bootphon/scratch/acristia/processed_corpora/Childes_Eng-NA-sel/processed_files.txt" #E.g. OUTPUT_FILE2="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/processed_files.txt"



# Do the selection and cleaning of cha-like files
./1_selAndClean.sh $INPUT_FOLDER $INPUT_FILE $OUTPUT_FILE $PROCESSED_FOLDER $ROOT || exit 1

# Phonologize the ortholines files
./2_ortho2phono.sh $PROCESSED_FOLDER  || exit 1


# Analyze
./3_analyze.sh $PROCESSED_FOLDER $RES_FOLDER


# ./4_collapse_results.sh $RES_FOLDER
