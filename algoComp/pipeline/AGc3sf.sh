#!/usr/bin/env bash

# Script for launching AG, the step 5 of segment_one_corpus.sh
# Author: Mathieu Bernard <mmathieubernardd@gmail.com>
# Changes by Alex Cristia <alecristia@gmail.com>

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

GRAMMARFILE="./do_coll3syll_english.sh"

###########################

ABSPATH=$1
KEYNAME=$2
RESFOLDER=$3

ALGO="agc3s"
ROOT=$RESFOLDER$KEYNAME

# Navigate to the AG folder
cd ${ABSPATH}/algos/AG

# Remove spaces within words and syllable boundaries, and replace word
# tags with spaces to create gold:
sed 's/;esyll//g'  $ROOT-tags.txt |
    sed 's/;eword/ /g' |
    sed '/^$/d' |
    tr -d ' ' > ${RESFOLDER}input.gold

# Remove word and syllable tags to create input:
sed 's/;esyll//g' $ROOT-tags.txt |
    sed 's/;eword/ /g' |
    sed '/^$/d' |
    sed 's/  */ /g'  > ${RESFOLDER}input.ylt

# actual algo running
$GRAMMARFILE $RESFOLDER $KEYNAME

# # write with standard format
# #sed 's/ /;/g' "${RESFOLDER}_mbr-Colloc0.seg" | sed 's/./& /g' | sed 's/ ;/;aword/g' > $ROOT-${ALGO}-output.txt
# #sed 's/ //g'  $ROOT-${ALGO}-output.txt | sed 's/;aword/ /g' > $ROOT-${ALGO}-cfgold.txt

# # Store	the segmented output in	a "full" file, and prepare the last 20%	of lines for evaluation
# N=`wc -l $ROOT-${ALGO}-cfgold.txt | cut -f1 -d' '`
# Ntest=`echo "$((N * 1 / 5))"`

# mv $ROOT-${ALGO}-cfgold.txt $ROOT-${ALGO}-cfgold-full.txt

# tail -$Ntest -l $ROOT-${ALGO}-cfgold-full.txt > $ROOT-${ALGO}-cfgold.txt


# # Do the evaluation
# cd ${ABSPATH}scripts
# ./doAllEval.text $RESFOLDER $KEYNAME $ALGO

# # Final clean up
# cd $RESFOLDER
# rm *.seg
# rm *.wlt
# rm *.prs
# rm input.*
# rm tmp*

# echo "done with AG colloc3syll"
