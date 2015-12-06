#!/usr/bin/env bash

# Script for analyzing a single corpus in the algoComp2015.1.0 project
# Alex Cristia alecristia@gmail.com 2015-08-25
# Updated by Mathieu Bernard for 'clusterization' of the pipeline
# And again by Alex
# 2015-11-26 for winnipeglena corpus analysis

#########VARIABLES###########################
PHONFOLDER=/home/mbernard/dev/CDSwordSeg/full_WL/phono
RESFOLDER=${PHONFOLDER/phono/results}
PIPELINE=/home/mbernard/dev/CDSwordSeg/algoComp/segment.py
#########


# Run all algos in the cluster, once per version
for VERSION in ${PHONFOLDER}/WL*
do
    KEYNAME=`basename ${VERSION#$RESFOLDER}`
    $PIPELINE --goldfile $KEYNAME/gold.txt \
              --output-dir $RESFOLDER/$KEYNAME \
              --algorithms all \
              --clusterize
done

# bring together the results
grep '[0-9]' $RESFOLDER/*/*cfgold.txt > $RESFOLDER/results.txt
