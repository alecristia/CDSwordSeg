#!/usr/bin/env bash

# Script for analyzing a single corpus in the algoComp2015.1.0 project
# Alex Cristia alecristia@gmail.com 2015-08-25
# Updated by Mathieu Bernard for 'clusterization' of the pipeline
# And again by Alex
# 2015-11-26 for winnipeglena corpus analysis

#########VARIABLES###########################
RESFOLDER=${1:-./results\/test_dmcmc}
PHONFOLDER=${2:-./phono}
PIPELINE=${3:-../../algoComp/segment.py}
#########

mkdir -p $RESFOLDER

# Run all algos in the cluster, once per version
#for VERSION in ${PHONFOLDER}/WL_ADS_*S
for VERSION in ${PHONFOLDER}/WL_CDS_LS
do
    VNAME=`basename ${VERSION#$RESFOLDER}`
    echo Clusterizing $VNAME
    $PIPELINE --goldfile $VERSION/gold.txt \
              --output-dir $RESFOLDER/$VNAME \
              --algorithms dmcmc \
              --clusterize \
              --jobs-basename $VNAME \
              $VERSION/tags.txt
done
