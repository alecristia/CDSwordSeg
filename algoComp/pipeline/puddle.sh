#!/usr/bin/env bash

# Script for launching puddle
# Author: Alex Cristia <alecristia@gmail.com>

ABSPATH=$1
KEYNAME=$2
RESFOLDER=$3

ALGO="puddle"
ALGOPATH=${ABSPATH}algos/PUDDLE

ROOT=$RESFOLDER$KEYNAME

# Remove word and syllable tags to create input:
sed 's/;esyll//g' $ROOT-tags.txt |
    sed 's/;eword/ /g' |
    sed 's/  *//g' > clean_test.txt

# Actual algo running
gawk -f $ALGOPATH/segment.vowelconstraint.awk clean_test.txt > dirty_output.txt

# Clean up the output file & store it in your desired location
sed "s/.*://" dirty_output.txt  > $ROOT-${ALGO}-cfgold.txt

# Local clean up
#rm *.txt
