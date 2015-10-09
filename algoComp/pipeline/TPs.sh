#!/usr/bin/env bash

# Script for launching TPS, the step 3 of segment_one_corpus.sh
# Author: Mathieu Bernard <mmathieubernardd@gmail.com>

ABSPATH=$1
KEYNAME=$2
RESFOLDER=$3


# 3.1 Navigate to the TP folder
cd ${ABSPATH}algos/TPs


# Reformat the test file into two formats, one for training and
# another for segmentation:

sed 's/;esyll/-/g'  $RESFOLDER$KEYNAME-text-klatt-syls-tags.txt | sed 's/ //g' | sed 's/;eword/ /g' | sed 's/ -/ /g' | sed 's/ $//g' | tr '\n' '?' | sed 's/?/ UB /g' > syllable+wordboundaries_marked.txt


sed 's/ //g'  $RESFOLDER$KEYNAME-text-klatt-syls-tags.txt | sed 's/;esyll/ /g' | sed 's/;eword/ /g' | sed 's/  / /g' | sed 's/ $//g' | tr '\n' '?' | sed 's/?/ UB /g'  > syllableboundaries_marked.txt


# 3.2 Actual algo running
python TPsegmentation.py syllable+wordboundaries_marked.txt syllableboundaries_marked.txt tempABS.txt tempREL.txt

#for the time being, the output is messed up - this is a quick fix,
#but it would be better to modify the python code so that it's
#produced in the right format

lf=$'\n'

ALGO="tpABS"
cut -c 3- tempABS.txt | sed s/\'\]\]$// |  tr "\]" "\n" | sed s/"\', \'"//g | tr -d "," | tr -d "[" | tr -d "\'" | tr "\n" ";" | sed 's/;/ ;aword /g' | sed -e "s/UB ;aword/\\$lf/g" > $RESFOLDER$KEYNAME-${ALGO}-output.txt

ALGO="tpREL"
cut -c 3- tempREL.txt | sed s/\'\]\]$// |  tr "\]" "\n" | sed s/"\', \'"//g | tr -d "," | tr -d "[" | tr -d "\'" | tr "\n" ";" | sed 's/;/ ;aword /g' | sed "s/UB ;aword/\\$lf/g" > $RESFOLDER$KEYNAME-${ALGO}-output.txt

 rm syllable*
 rm temp*

# 3.3 Do the evaluation
cd ${ABSPATH}scripts
ALGO="tpABS"
./doAllEval.text $RESFOLDER $KEYNAME $ALGO

ALGO="tpREL"
./doAllEval.text $RESFOLDER $KEYNAME $ALGO


echo "done with tps"
