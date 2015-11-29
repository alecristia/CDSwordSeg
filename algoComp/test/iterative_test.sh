#!/usr/bin/env bash

# Script for testing crossevaluation
# Author: Mathieu Bernard

ABSPATH=`readlink -f ..`/
KEYNAME=test
RESFOLDER=`readlink -f ../test`/

ROOT=$RESFOLDER$KEYNAME
ALGO="test"

# input file
echo 'a b c d e f g h' | sed 's/ /\n/g' > $ROOT-in.txt

# create 3 folds named $ROOT-in_fold[0,1,2].txt
$ABSPATH/crossevaluation.py fold $ROOT-in.txt -n 3

for FOLD in $ROOT-in_fold*.txt
do
    # add an incremental score
    sed 1d $FOLD | awk '{printf "%s %d\n", $0, NR}' >> ${FOLD/in/out}
done

# unfold the results
$ABSPATH/crossevaluation.py unfold $ROOT-out-fold*.txt -i $ROOT-in-index.txt

