#!/usr/bin/env bash
#
# Script for testing crossevaluation. Run this scripts from its local
# directory and observe the created files in the ./xval subdirectory.
#
# Author: Mathieu Bernard

ROOT=./xval
CROSSEVAL=../crossevaluation.py

# test setup
mkdir -p $ROOT
rm -f $ROOT/*.txt

# input file has one letter per line
echo Create $ROOT/input.txt
echo 'aa b c d e f g h' | sed 's/ /\n/g' > $ROOT/input.txt

# create 3 folds named $ROOT-in-fold[0,1,2].txt with reordered lines
# must be consistent with dmcmc bugfix

$CROSSEVAL fold $ROOT/input.txt --nfolds 3 --verbose --dmcmc-bugfix
echo Folding done

for FOLD in $ROOT/input-fold*.txt
do
    input=$FOLD
    output=${FOLD/input/output}
    echo Process $input to $output

    # add an incremental score to each line
    cat $input | awk '{printf "%s %d\n", $0, NR}' >> $output
done

# unfold the results in $ROOT-output-unfolded.txt
$CROSSEVAL unfold $ROOT/output-fold*.txt --index $ROOT/input-index.txt --verbose
echo Unfolding done
