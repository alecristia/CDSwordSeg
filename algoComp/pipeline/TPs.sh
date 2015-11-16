#!/usr/bin/env bash

# Script for launching TPS, the step 3 of segment_one_corpus.sh
# Author: Mathieu Bernard <mmathieubernardd@gmail.com>

ABSPATH=$1
KEYNAME=$2
RESFOLDER=$3

ALGO="tpREL"


# Navigate to the TP folder
cd ${ABSPATH}algos/TPs


# Reformat the test file for segmentation:

sed 's/ //g'  $RESFOLDER$KEYNAME-tags.txt | sed 's/;esyll/ /g' | sed 's/;eword//g' | sed 's/  / /g' | sed 's/ $//g' | tr '\n' '?' | sed 's/?/ UB /g'  > syllableboundaries_marked.txt
#sed 's/ //g'  $RESFOLDER$KEYNAME-tags.txt | sed 's/;esyll/ /g' | sed 's/;eword/ /g' | sed 's/  / /g' | sed 's/ $//g' | tr '\n' '?' | sed 's/?/ UB /g'  > syllableboundaries_marked.txt


# Actual algo running
python TPsegmentation.py syllableboundaries_marked.txt > $RESFOLDER$KEYNAME-${ALGO}-output.txt 

# Local clean up
# rm syllable*
# rm temp*

# Do the evaluation
cd ${ABSPATH}scripts
./doAllEval.text $RESFOLDER $KEYNAME $ALGO


echo "done with tps"
