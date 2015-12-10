#!/usr/bin/env bash

# Script for launching n-grams, the step 4 of segment_one_corpus.sh
# Author: Mathieu Bernard <mmathieubernardd@gmail.com>

ABSPATH=$1
RESFOLDER=$2
ALGO="ngrams"

# Remove word boundaries to create input:
sed 's/;eword/;esyll/g' $RESFOLDER/tags.txt > $RESFOLDER/input.txt

# actual algo running
BIN=$ABSPATH/algos/ngrams/mkngram.sh
$BIN --syll $RESFOLDER/input.txt > $RESFOLDER/freq-all.txt
head -n 10000 $RESFOLDER/freq-all.txt > $RESFOLDER/freq-top.txt

# Note: n-grams doesn't have a full eval, like the others, because
# it's not a SEGMENTATION algorithm
echo done with $ALGO
