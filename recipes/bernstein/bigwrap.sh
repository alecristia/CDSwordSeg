#!/usr/bin/env bash
#
# Wrapper to run Bernstein experiments 201612
# 2018-04-01


RAW_FOLDER="/scratch1/users/acristia/data/Bernstein/"
PROCESSED_FOLDER="/scratch1/users/acristia/processed_corpora/Bernstein/"
RES_FOLDER="/scratch1/users/acristia/results/Bernstein/"

# Turn the cha-like files into a single clean file per type & phonologize them
#./1_data2clean.sh $RAW_FOLDER $PROCESSED_FOLDER  || exit 1

#./2_clean2phono.sh  $PROCESSED_FOLDER  || exit 1


# Add length-matched versions of all the corpora
#./3_length_match.sh $PROCESSED_FOLDER  || exit 1

# Analyze
#./4_analyze.sh $PROCESSED_FOLDER $RES_FOLDER


#./5_collapse_results.sh $RES_FOLDER

./6_stats.sh $PROCESSED_FOLDER 

