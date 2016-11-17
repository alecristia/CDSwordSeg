#!/usr/bin/env bash

# Script for analyzing CDS and ADS for ELEAC corpus
# Alex Cristia alecristia@gmail.com 2016-11-??

#########VARIABLES###########################
DATAFOLDER="/fhgfs/bootphon/scratch/acristia/Documents/processed_corpora/arglongitudinal_res/"
RESFOLDER=${2:-./results}
PIPELINE=${3:-../../algoComp/segment.py}
#########


# create all the versions of the corpus we need



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
