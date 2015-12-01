#!/usr/bin/env bash

# Script for launching DIBS, the step 2 of segment_one_corpus.sh
# Author: Mathieu Bernard <mmathieubernardd@gmail.com>

ABSPATH=$1
KEYNAME=$2
RESFOLDER=$3

ROOT=$RESFOLDER$KEYNAME
ALGO="dibs"

echo Running $ALGO...
DIBS=${ABSPATH}algos/DiBS/apply-dibs.py

# DIBS requires a bit of corpus to calculate some statistics. We'll
# use 200 lines from the version with the word boundaries to this end
# (we remove syllable boundaries, which are not needed):
head -200 $ROOT-tags.txt | sed 's/;esyll//g' > $ROOT-$ALGO-clean_train.txt

# Remove word and syllable boundaries to create the test file that
# will be segmented:
sed 's/;esyll//g' $ROOT-tags.txt |
    sed 's/;eword//g' |
    sed 's/  / /g' > $ROOT-$ALGO-clean_test.txt

# Actual algo running
$DIBS $ROOT-$ALGO-clean_train.txt $ROOT-$ALGO-clean_test.txt \
      $ROOT-$ALGO-dirty_output.txt $ROOT-$ALGO-diphones_output.txt

# Clean up the output file & store it in your desired location
sed "s/.*$(printf '\t')//" $ROOT-$ALGO-dirty_output.txt |
    sed 's/;eword/;aword/g' > $ROOT-$ALGO-output.txt

sed 's/ //g' $ROOT-$ALGO-output.txt |
    sed 's/;aword/ /g' > $ROOT-$ALGO-cfgold.txt

# Store the segmented output in a "full" file, and prepare the last
# 20% of lines for evaluation
N=`wc -l $ROOT-$ALGO-cfgold.txt | cut -f1 -d' '`
Ntest=`echo "$((N * 1 / 5))"`

mv $ROOT-$ALGO-cfgold.txt $ROOT-$ALGO-cfgold-full.txt
tail --lines=$Ntest $ROOT-$ALGO-cfgold-full.txt > $ROOT-$ALGO-cfgold.txt

# Local cleanup
#rm $ROOT-$ALGO-*.txt

# Do the evaluation
cd ${ABSPATH}scripts
./doAllEval.text $RESFOLDER $KEYNAME $ALGO

echo done with $ALGO
