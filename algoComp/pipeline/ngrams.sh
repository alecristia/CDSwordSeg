#!/usr/bin/env bash

# Script for launching n-grams, the step 4 of segment_one_corpus.sh
# Author: Mathieu Bernard <mmathieubernardd@gmail.com>

ABSPATH=$1
KEYNAME=$2
RESFOLDER=$3

ALGO="ngrams"


# Navigate to the ngrams folder
cd ${ABSPATH}algos/ngrams

# Remove word boundaries to create input:
sed 's/;eword/;esyll/g'  $RESFOLDER$KEYNAME-tags.txt  > input.txt

# actual algo running
./mkngram.sh --syll input.txt > $RESFOLDER$KEYNAME-${ALGO}-freq-all.txt

# Local clean up
rm *tmp
rm input.txt

head -n 10000 $RESFOLDER$KEYNAME-${ALGO}-freq-all.txt \
     > $RESFOLDER$KEYNAME-${ALGO}-freq-top.txt

# Note: n-grams doesn't have a full eval, like the others, because
# it's not a SEGMENTATION algorithm

echo "done with n-grams"
