#!/usr/bin/env bash

# Script for analyzing a single corpus in the algoComp2015.1.0 project
# Alex Cristia alecristia@gmail.com 2015-08-25
# Updated by Mathieu Bernard for 'clusterization' of the pipeline
# And again by Alex
# 2015-11-26 for winnipeglena corpus analysis

#########VARIABLES###########################
PIPELINE=~/dev/lscp/CDSwordSeg/algoComp/segment.py
RESFOLDER=${1:-${PHONFOLDER/phono/results\/test_segment}}
PHONFOLDER=${2:-./phono}
#########

mkdir -p $RESFOLDER

# Run all algos in the cluster, once per version
#for VERSION in ${PHONFOLDER}/WL_ADS_*S
for VERSION in ${PHONFOLDER}/WL_*
do
    VNAME=`basename ${VERSION#$RESFOLDER}`
    echo Clusterizing $VNAME
    $PIPELINE --goldfile $VERSION/gold.txt \
              --output-dir $RESFOLDER/$VNAME \
              --algorithms TPs \
              --clusterize \
              --jobs-basename $VNAME \
              $VERSION/tags.txt
done
