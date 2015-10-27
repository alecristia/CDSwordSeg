#!/usr/bin/env bash

# Script for launching puddle
# Author: Alex Cristia <alecristia@gmail.com>

ABSPATH=$1
KEYNAME=$2
RESFOLDER=$3

ALGO="puddle"



# Navigate to the folder
cd ${ABSPATH}algos/puddle


# Remove word and syllable tags to create input:
sed 's/;esyll//g'  $RESFOLDER$KEYNAME-tags.txt | sed 's/;eword/ /g' |sed '/^$/d' | sed 's/  *//g'  > clean_test.txt


# Actual algo running
gawk -f segment.vowelconstraint.awk clean_test.txt > dirty_output.txt

# Clean up the output file & store it in your desired location
OUTFILE=$RESFOLDER$KEYNAME-$ALGO-output.txt
sed "s/.*://" dirty_output.txt  > $OUTFILE

# Local clean up
rm *.txt

# Do the evaluation
cd ${ABSPATH}scripts
./doAllEval.text $RESFOLDER $KEYNAME $ALGO


echo "done with puddle"
