#!/usr/bin/env bash

# Script for launching DIBS, the step 2 of segment_one_corpus.sh
# Author: Mathieu Bernard <mmathieubernardd@gmail.com>

ABSPATH=$1
RESFOLDER=$2
ALGO="dibs"

echo Running $ALGO...
DIBS=$ABSPATH/algos/DiBS/apply-dibs.py

# DIBS requires a bit of corpus to calculate some statistics. We'll
# use 200 lines from the version with the word boundaries to this end
# (we remove syllable boundaries, which are not needed):
head -200 $RESFOLDER/tags.txt | sed 's/;esyll//g' > $RESFOLDER/clean_train.txt

# Remove word and syllable boundaries to create the test file that
# will be segmented:
sed 's/;esyll//g' $RESFOLDER/tags.txt |
    sed 's/;eword//g' |
    sed 's/  / /g' > $RESFOLDER/clean_test.txt

# Actual algo running
#$DIBS $RESFOLDER/clean_train.txt $RESFOLDER/clean_test.txt \
$DIBS $RESFOLDER/clean_test.txt $RESFOLDER/clean_test.txt \. #!!! attention!!! now training is the whole test file — so this is the “baseline”!!!
      $RESFOLDER/dirty_output.txt $RESFOLDER/diphones_output.txt

# Clean up the output file & store it in your desired location
sed "s/.*$(printf '\t')//" $RESFOLDER/dirty_output.txt |
    sed 's/;eword/;aword/g' > $RESFOLDER/output.txt

sed 's/ //g' $RESFOLDER/output.txt |
    sed 's/;aword/ /g' > $RESFOLDER/cfgold.txt

# Do the evaluation
cd $ABSPATH/scripts
./doAllEval.text $RESFOLDER

echo done with $ALGO
