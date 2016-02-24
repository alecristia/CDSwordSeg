#!/usr/bin/env bash

# Script for analyzing a single corpus in the algoComp2015.1.0 project
# Alex Cristia alecristia@gmail.com 2015-08-25
# Mathieu Bernard adapted it for the bernstein recipe

#########VARIABLES###########################
DATAFOLDER=${1:-./data/matched}
RESFOLDER=${2:-./results}
PIPELINE=${3:-../../algoComp/segment.py}
#########

mkdir -p $RESFOLDER

# Run all algos in the cluster, once per version
for VERSION in $DATAFOLDER/*
do
    if [ -d $VERSION ]
    then
        VNAME=`basename ${VERSION#$RESFOLDER}`
        echo Clusterizing $VNAME
        $PIPELINE --goldfile $VERSION/gold.txt \
                  --output-dir $RESFOLDER/$VNAME \
                  --algorithms all \
                  --ag-median 5 \
                  --clusterize \
                  --jobs-basename $VNAME \
                  $VERSION/tags.txt || exit 1
    fi
done
