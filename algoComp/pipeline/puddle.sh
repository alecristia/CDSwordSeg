#!/usr/bin/env bash

# Script for launching puddle
# Author: Alex Cristia <alecristia@gmail.com>

ABSPATH=$1
KEYNAME=$2
RESFOLDER=$3

ROOT=$RESFOLDER$KEYNAME
ALGO="puddle"

# subprograms used in this script
CROSSEVAL="$ABSPATH/crossevaluation.py"
PUDDLE="gawk -f $ABSPATH/algos/PUDDLE/segment.vowelconstraint.awk"

# Remove word and syllable tags to create input:
sed 's/;esyll//g' $ROOT-tags.txt |
    sed 's/;eword/ /g' |
    sed 's/  *//g' > $ROOT-$ALGO-input.txt

# create 5 folds for cross evaluation.
$CROSSEVAL fold $ROOT-$ALGO-input.txt --nfolds 5

for FOLD in $ROOT-$ALGO-input-fold*.txt
do
    echo Processing `basename $FOLD`
    # Remove word and syllable tags
    sed 's/;esyll//g' $FOLD |
        sed 's/;eword/ /g' |
        sed 's/  *//g' |
        # Actual algo running
        $PUDDLE |
        # Clean up the output & store it
        sed 's/.*:\s//' |
        sed 's/\s;aword//g' |
        sed 's/\s*$//g' > ${FOLD/input/output}
done

# unfold the results.
$CROSSEVAL unfold $ROOT-$ALGO-output-fold*.txt \
           --index $ROOT-$ALGO-input-index.txt \
           --output $ROOT-$ALGO-cfgold.txt

# local cleanup
rm -f $ROOT-$ALGO-output* $ROOT-$ALGO-input*

# Do the evaluation
cd ${ABSPATH}scripts
./doAllEval.text $RESFOLDER $KEYNAME $ALGO

echo "done with puddle"
