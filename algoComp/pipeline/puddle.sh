#!/usr/bin/env bash

# Script for launching puddle
# Author: Alex Cristia <alecristia@gmail.com>

ABSPATH=$1
KEYNAME=$2
RESFOLDER=$3

ROOT=$RESFOLDER$KEYNAME
ALGO="puddle"

# Navigate to the folder
cd ${ABSPATH}algos/PUDDLE

# Remove word and syllable tags to create input:
sed 's/;esyll//g' $ROOT-tags.txt |
    sed 's/;eword/ /g' |
    sed 's/  *//g' > $ROOT-$ALGO-input.txt

# create 5 folds for cross evaluation.  This creates 5 files
# $ROOT-$ALGO-input-fold$N.txt and an index file
# $ROOT-$ALGO-input-index.txt
$ABSPATH/crossevaluation.py fold $ROOT-$ALGO-input.txt -n 5

for FOLD in $ROOT-$ALGO-input-fold*.txt
do
    echo Processing $FOLD
    # Remove word and syllable tags
    sed 's/;esyll//g' $FOLD |
        sed 's/;eword/ /g' |
        sed 's/  *//g' |
        # Actual algo running
        gawk -f segment.vowelconstraint.awk |
        # Clean up the output & store it
        sed 's/.*:\s//' |
        sed 's/\s;aword//g' |
        sed 's/\s*$//g' > ${FOLD/input/output}
done

# unfold the results. Creates the file $ROOT-$ALGO-output-unfolded.txt
$ABSPATH/crossevaluation.py unfold $ROOT-$ALGO-output-fold*.txt \
                            --index $ROOT-$ALGO-input-index.txt
mv $ROOT-$ALGO-output-unfolded.txt $ROOT-$ALGO-cfgold.txt

# Do the evaluation
cd ${ABSPATH}scripts
./doAllEval.text $RESFOLDER $KEYNAME $ALGO

echo "done with puddle"
