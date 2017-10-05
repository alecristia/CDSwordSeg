#!/usr/bin/env bash

# Script for launching puddle
# Author: Alex Cristia <alecristia@gmail.com>

ABSPATH=$1
RESFOLDER=$2

ALGO="puddle"
ALGOPATH=${ABSPATH}/algos/PUDDLE

ROOT=$RESFOLDER

echo Running $ALGO...

# subprogram used in this script for 5-folds cross evaltuation
CROSSEVAL=$ABSPATH/crossevaluation.py

# puddle word segmentation algorithm
PUDDLE="gawk -f $ABSPATH/algos/PUDDLE/segment.vowelconstraint_1char.awk"

# Remove word and syllable tags to create input:
sed 's/;esyll//g' $RESFOLDER/tags.txt |
    sed 's/;eword/ /g' |
    sed 's/  *//g' > $RESFOLDER/input.txt

NFOLDS=5
echo "Creating $NFOLDS folds for cross evaluation"
$CROSSEVAL fold $RESFOLDER/input.txt --nfolds $NFOLDS


# folds are processed in parallel
echo "Running puddle on each fold..."
for FOLD in $RESFOLDER/input-fold*.txt
do
    (
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

        n=`basename $FOLD | sed 's/.*fold//' | sed 's/\.txt//'`
        echo "fold $n done"
    ) &
done

# wait for all the folds to be processed
wait

echo Unfolding to cfgold.txt
$CROSSEVAL unfold $RESFOLDER/output-fold*.txt \
           --index $RESFOLDER/input-index.txt \
           --output $RESFOLDER/cfgold.txt

# local cleanup
#rm -f $RESFOLDER/output* $RESFOLDER/input*

echo Evaluating
cd ${ABSPATH}/scripts
./doAllEval.text $RESFOLDER

echo "done with puddle"
