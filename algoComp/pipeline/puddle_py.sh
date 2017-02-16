#!/usr/bin/env bash

# Script for launching puddle - python version
# Author: Elin Larsen <elin_larsen1@hotmail.com>

ABSPATH=$1
RESFOLDER=$2

ALGOPATH=${ABSPATH}algos/PUDDLE

ROOT=$RESFOLDER

# Remove word and syllable tags to create input:
sed 's/;esyll//g' $RESFOLDER/tags.txt |
    sed 's/;eword/ /g' |
    sed 's/  *//g' > $RESFOLDER/input.txt

echo Running $ALGO...
$python ${ABSPATH}algos/PUDDLE/puddle.py -i $RESFOLDER/input.txt -o $RESFOLDER/freq-top.txt


 


