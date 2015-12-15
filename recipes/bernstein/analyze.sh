#!/usr/bin/env bash

# Script for analyzing a single corpus in the algoComp2015.1.0 project
# Alex Cristia alecristia@gmail.com 2015-08-25
# Mathieu Bernard adapted it for the bernstein recipe

#########VARIABLES###########################
PHONFOLDER=${1:-./phono}
RESFOLDER=${2:-${PHONFOLDER/phono/results}}
PIPELINE=${3:-../../algoComp/segment.py}
#########

mkdir -p $RESFOLDER

# Run all algos in the cluster, once per version
#for VERSION in ${PHONFOLDER}/WL_ADS_*S
for VERSION in $PHONFOLDER/*
do
    if [ -d $VERSION ]
    then
        VNAME=`basename ${VERSION#$RESFOLDER}`
        echo Clusterizing $VNAME
        $PIPELINE --goldfile $VERSION/gold.txt \
                  --output-dir $RESFOLDER/$VNAME \
                  --algorithms all \
                  --clusterize \
                  --jobs-basename $VNAME \
                  $VERSION/tags.txt
    fi
done
