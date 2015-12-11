#!/usr/bin/env bash

# Script for launching TPS, the step 3 of segment_one_corpus.sh
# Author: Mathieu Bernard <mmathieubernardd@gmail.com>

ABSPATH=$1
RESFOLDER=$2

ALGO="TPs"


BIN=${ABSPATH}/algos/TPs/TPsegmentation.py

# Reformat the test file for segmentation
sed 's/ //g' $RESFOLDER/tags.txt |
    sed 's/;esyll/ /g' |
    sed 's/;eword//g' |
    sed 's/  / /g' |
    sed 's/ $//g' |
    tr '\n' '?' |
    sed 's/?/ UB /g' > $RESFOLDER/syllableboundaries_marked.txt
# NOTE (was a bug) add a newline at the end of file
echo '\n' >>  $RESFOLDER/syllableboundaries_marked.txt

# Actual algo running
$BIN $RESFOLDER/syllableboundaries_marked.txt > $RESFOLDER/cfgold.txt

# Local clean up
#rm syllable*

# Do the evaluation
cd ${ABSPATH}scripts
./doAllEval.text $RESFOLDER

echo done with $ALGO
