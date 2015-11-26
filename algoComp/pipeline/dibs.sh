#!/usr/bin/env bash

# Script for launching DIBS, the step 2 of segment_one_corpus.sh
# Author: Mathieu Bernard <mmathieubernardd@gmail.com>

ABSPATH=$1
KEYNAME=$2
RESFOLDER=$3

ALGO="dibs"

# Navigate to the DIBS folder
cd ${ABSPATH}algos/DiBS

# DIBS requires a bit of corpus to calculate some
# statistics. We'll use 200 lines from the version with the word
# boundaries to this end (we remove syllable boundaries, which are not
# needed):

head -200 $RESFOLDER$KEYNAME-tags.txt | sed 's/;esyll//g' > clean_train.txt

# Remove word and syllable boundaries to create the test file that
# will be segmented:
sed 's/;esyll//g' $RESFOLDER$KEYNAME-tags.txt | sed 's/;eword//g' | sed 's/  / /g' > clean_test.txt

# Actual algo running
python apply-dibs.py clean_train.txt clean_test.txt dirty_output.txt diphones_output.txt

# Clean up the output file & store it in your desired location
OUTFILE=$RESFOLDER$KEYNAME-$ALGO-output.txt
sed "s/.*$(printf '\t')//" dirty_output.txt | sed 's/;eword/;aword/g' > $OUTFILE
sed 's/ //g'  $RESFOLDER$KEYNAME-${ALGO}-output.txt | sed 's/;aword/ /g' > $RESFOLDER$KEYNAME-${ALGO}-cfgold.txt

# Store	the segmented output in	a "full" file, and prepare the last 20%	of lines for evaluation 
N=`wc -l $RESFOLDER$KEYNAME-${ALGO}-cfgold.txt | cut -f1 -d' '`
Ntest=`echo "$((N * 1 / 5))"`

mv $RESFOLDER$KEYNAME-${ALGO}-cfgold.txt $RESFOLDER$KEYNAME-${ALGO}-cfgold-full.txt

tail -$Ntest -l $RESFOLDER$KEYNAME-${ALGO}-cfgold-full.txt > $RESFOLDER$KEYNAME-${ALGO}-cfgold.txt


# Local cleanup
rm *.txt

# Do the evaluation
cd ${ABSPATH}scripts
./doAllEval.text $RESFOLDER $KEYNAME $ALGO

echo "done with dibs"
