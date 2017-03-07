#!/usr/bin/env bash

# Script for launching puddle - python version
# Author: Elin Larsen <elin_larsen1@hotmail.com>
# to be run in the folder where is stored this script

ALGO=« puddle_py »
ABSPATH=$1
RESFOLDER=$2
WINDOW=$3

#run puddle
echo $ALGO running
$python ../algos/PUDDLE/puddle_py.py -p $ABSPATH/tags.txt -r $RESFOLDER -o $RESFOLDER/cfgold.txt -w $WINDOW

# subprograms used in this script
#CROSSEVAL=../crossevaluation.py

#NFOLDS=5
#echo Creating $NFOLDS folds for cross evaluation
#$CROSSEVAL fold $RESFOLDER/input.txt --nfolds $NFOLDS

# TODO parallelize
#for FOLD in $RESFOLDER/input-fold*.txt
#do
#N=`basename $FOLD | sed 's/.*fold//' | sed 's/\.txt//'`
#echo Processing fold $N

# Actual algo running
#$python ../algos/PUDDLE/puddle_py.py -p $FOLD -r $RESFOLDER -o ${FOLD/input/output} -w $WINDOW

#done

#echo Unfolding to cfgold.txt
#$CROSSEVAL unfold $RESFOLDER/output-fold*.txt \
#--index $RESFOLDER/input-index.txt \
#--output $RESFOLDER/cfgold.txt


#Evaluate against the gold
echo evaluation running
$python ../scripts/evalGold.py -g $ABSPATH/gold.txt < $RESFOLDER/cfgold.txt \
> $RESFOLDER/cfgold-res.txt

echo evaluation done

echo "done with puddle"


 


