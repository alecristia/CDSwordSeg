#!/usr/bin/env bash

# Script for launching DIBS, the step 2 of segment_one_corpus.sh
# Author: Mathieu Bernard <mmathieubernardd@gmail.com>

ABSPATH=$1
KEYNAME=$2
RESFOLDER=$3

ALGO="dibs"

# 2.1 Navigate to the DIBS folder
cd ${ABSPATH}algos/DiBS

# 2.2 DIBS requires a bit of corpus to calculate some
# statistics. We'll use 200 lines from the version with the word
# boundaries to this end (we remove syllable boundaries, which are not
# needed):

head -200 $RESFOLDER$KEYNAME-text-klatt-syls-tags.txt | sed 's/;esyll//g' > clean_train.txt

# 2.3 Remove word and syllable boundaries to create the test file that
# will be segmented:
sed 's/;esyll//g' $RESFOLDER$KEYNAME-text-klatt-syls-tags.txt | sed 's/;eword//g' | sed 's/  / /g' > clean_test.txt

# 2.4 Actual algo running
python apply-dibs.py clean_train.txt clean_test.txt dirty_output.txt diphones_output.txt

# 2.5 Clean up the output file & store it in your desired location
# (probably the same as the input)
OUTFILE=$RESFOLDER$KEYNAME-dibs-output.txt
sed "s/.*$(printf '\t')//" dirty_output.txt | sed 's/;eword/;aword/g' > $OUTFILE

rm *.txt

# 2.6 Do the evaluation
cd ${ABSPATH}scripts
./doAllEval.text $RESFOLDER $KEYNAME $ALGO

echo "done with dibs"
