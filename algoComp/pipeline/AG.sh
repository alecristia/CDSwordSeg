#!/usr/bin/env bash

# Script for launching AG, the step 5 of segment_one_corpus.sh
# Author: Mathieu Bernard <mmathieubernardd@gmail.com>

ABSPATH=$1
KEYNAME=$2
RESFOLDER=$3

ALGO="ag"
# 5.1a Navigate to the AG folder
cd ${ABSPATH}algos/AG

# Remove spaces within words and syllable boundaries, and replace word
# tags with spaces to create gold:
sed 's/;esyll//g'  $RESFOLDER$KEYNAME-text-klatt-syls-tags.txt | sed 's/;eword/ /g' |sed '/^$/d' | tr -d ' ' > input/input.gold

# 5.1b Remove word and syllable tags to create input:
sed 's/;esyll//g'  $RESFOLDER$KEYNAME-text-klatt-syls-tags.txt | sed 's/;eword/ /g' |sed '/^$/d' | sed 's/  */ /g'  > input/input.ylt

# 5.2 Open do_colloq0_klatt.sh and adapt to your purposes, meaning:
# - check or change the names of folders, input, and output files
# - check that the input files and the folders are there
# - when doing so CHECK that the grammar you are using (a) represents
# your intention (is the tree right?) and (b) contains all the
# terminals you encounter (is the alphabet correct?) Right now, the
# grammar is colloq zero or unigram (sentences are groups of words or
# single words; groups of words are single words or groups of words;
# words are groups of phonemes); and the alphabet is the Klatt English
# unicode-friendly.

# 5.3 actual algo running
./do_colloq0_${LANGUAGE}.sh

# 5.4 clean up & write with standard format
sed 's/ /;/g' "output/_mbr-Colloc0.seg" | sed 's/./& /g' | sed 's/ ;/;aword/g' > $RESFOLDER$KEYNAME-${ALGO}-output.txt

cd output
rm *.seg
rm *.wlt
rm *.prs

# 5.5 Do the evaluation
cd ${ABSPATH}scripts
./doAllEval.text $RESFOLDER $KEYNAME $ALGO

echo "done with AG"
