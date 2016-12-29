#!/usr/bin/env bash
#
# Wrapper to run WinnipegLENA experiments 201511
# Alex Cristia <alecristia@gmail.com> 2015-11-26
# Mathieu Bernard

RAW_FOLDER="/fhgfs/bootphon/scratch/acristia/data/WinnipegLENA/trs"
PROCESSED_FOLDER="/fhgfs/bootphon/scratch/acristia/processed_corpora/WinnipegLENA"
RES_FOLDER="/fhgfs/bootphon/scratch/acristia/results/WinnipegLENA"


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
 ./5_analyze.sh $PROCESSED_FOLDER $RES_FOLDER
 ./6_collapse_results.sh $RES_FOLDER
