#!/usr/bin/env bash

# Script for launching puddle
# Author: Alex Cristia <alecristia@gmail.com>

ABSPATH=$1
KEYNAME=$2
RESFOLDER=$3

ALGO="puddle"
ALGOPATH=${ABSPATH}algos/PUDDLE

ROOT=$RESFOLDER$KEYNAME

echo Running $ALGO...

# subprograms used in this script
CROSSEVAL="$ABSPATH/crossevaluation.py"
PUDDLE="gawk -f $ABSPATH/algos/PUDDLE/segment.vowelconstraint.awk"

# Remove word and syllable tags to create input:
sed 's/;esyll//g' $ROOT-tags.txt |
    sed 's/;eword/ /g' |
    sed 's/  *//g' > $ROOT-$ALGO-input.txt

NFOLDS=5
echo Creating $NFOLDS folds for cross evaluation
$CROSSEVAL fold $ROOT-$ALGO-input.txt --nfolds $NFOLDS

for FOLD in $ROOT-$ALGO-input-fold*.txt
do
    N=`basename $FOLD | sed 's/.*fold//' | sed 's/\.txt//'`
    echo Processing fold $N
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

echo Unfolding to $KEYNAME-$ALGO-cfgold.txt
$CROSSEVAL unfold $ROOT-$ALGO-output-fold*.txt \
           --index $ROOT-$ALGO-input-index.txt \
           --output $ROOT-$ALGO-cfgold.txt

# local cleanup
rm -f $ROOT-$ALGO-output* $ROOT-$ALGO-input*

echo Evaluating
cd ${ABSPATH}scripts
./doAllEval.text $RESFOLDER $KEYNAME $ALGO

echo "done with puddle"
