#!/usr/bin/env bash
#
# The first part of the bernstein recipe is to get a phonologized form
# of ADS and CDS data
#
# Mathieu Bernard

# Input arguments
RAW_FOLDER=$1
PROCESSED_FOLDER=$2

SCRIPTS=../../database_creation/scripts

# in the data folder, both ADS and CDS are in cha format, we need to
# preprocess them
for corpus in ADS CDS
do
    resfolder=$PROCESSED_FOLDER/$corpus
    mkdir -p $resfolder

    inclines=$resfolder/includedlines.txt
    ortho=$resfolder/ortholines.txt
    touch $inclines
    for f in ${RAW_FOLDER}_$corpus/*.cha
    do
        $SCRIPTS/cha2sel.sh $f $inclines
    done
    $SCRIPTS/selcha2clean.sh $inclines $ortho
    ./extraclean.sh $ortho


done

exit 0
