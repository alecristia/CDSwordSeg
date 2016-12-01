#!/usr/bin/env bash
#
# Script for launching Adaptor Grammar on different grammars (AGu and AGc3sf).
#
# Copyright (C) 2016 by Alex Cristia, Mathieu Bernard

ABSPATH=$1
RESFOLDER=$2
ALGO=$3  # must be 'AGu' or 'AGc3sf'
DEBUG=$4

#*****CRUCIAL PART *******#
# This grammar file needs to be adapted to your purposes, meaning:
# - check or change the names of folders, input, and output files
# - check that the input files and the folders are there
# - when doing so CHECK that the grammar you are using (a) represents
# your intention (is the tree right?) and (b) contains all the
# terminals you encounter (is the alphabet correct?)
# Right now, the grammar is colloq zero or unigram
# (sentences are groups of words or
# single words; groups of words are single words or groups of words;
# words are groups of phonemes); and the alphabet is the Klatt English
# unicode-friendly.
GRAMMARFILE=$ABSPATH/algos/AG/do_AG_aes.sh

# Remove spaces within words and syllable boundaries, and replace word
# tags with spaces to create gold
sed 's/;esyll//g' $RESFOLDER/tags.txt |
    sed 's/;eword/ /g' |
    sed '/^$/d' |
    tr -d ' ' > $RESFOLDER/input.gold

# Remove word and syllable tags to create input
sed 's/;esyll//g' $RESFOLDER/tags.txt |
    sed 's/;eword/ /g' |
    sed '/^$/d' |
    sed 's/  */ /g' > $RESFOLDER/input.ylt

# actual algo running
$GRAMMARFILE $RESFOLDER $ALGO $DEBUG || exit 1

# Do the evaluation
cd $ABSPATH/scripts
./doAllEval.text $RESFOLDER

# # Final clean up
# cd $RESFOLDER
# rm *.seg
# rm *.wlt
# rm *.prs
# rm input.*
# rm tmp*

echo done with $ALGO
