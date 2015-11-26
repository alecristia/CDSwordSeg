#!/usr/bin/env bash

# Script for launching puddle
# Author: Alex Cristia <alecristia@gmail.com>

ABSPATH=$1
KEYNAME=$2
RESFOLDER=$3

ROOT=$RESFOLDER$KEYNAME
ALGO="puddle"

# Navigate to the folder
cd ${ABSPATH}algos/PUDDLE

# Remove word and syllable tags to create input:
cat $ROOT-tags.txt |
    sed 's/;esyll//g' |
    sed 's/;eword/ /g' |
    sed 's/  *//g' > clean_test.txt

# Actual algo running
gawk -f segment.vowelconstraint.awk clean_test.txt > dirty_output.txt

# Clean up the output file & store it in your desired location
sed "s/.*://" dirty_output.txt  > $ROOT-${ALGO}-cfgold.txt

# Local clean up
#rm *.txt

# Do the evaluation
cd ${ABSPATH}scripts
./doAllEval.text $RESFOLDER $KEYNAME $ALGO

echo "done with puddle"
