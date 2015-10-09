#!/usr/bin/env bash

# Script for launching n-grams, the step 4 of segment_one_corpus.sh
# Author: Mathieu Bernard <mmathieubernardd@gmail.com>

ABSPATH=$1
KEYNAME=$2
RESFOLDER=$3

# 4.1 Navigate to the ngrams folder
cd ${ABSPATH}algos/ngrams

# Remove word boundaries to create input:
sed 's/;eword/;esyll/g'  $RESFOLDER$KEYNAME-text-klatt-syls-tags.txt  > input.txt

# 4.2 actual algo running
./mkngram.sh --syll input.txt > $RESFOLDER$KEYNAME-ngrams-freq-all.txt
rm *tmp

head -n 10000 $RESFOLDER$KEYNAME-ngrams-freq-all.txt > $RESFOLDER$KEYNAME-ngrams-freq-top.txt

# Note: n-grams doesn't have a full eval, like the others, because
# it's not a SEGMENTATION algorithm

echo "done with n-grams"
