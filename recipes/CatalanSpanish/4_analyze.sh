#!/usr/bin/env bash

# Script for analyzing CDS and ADS for ELEAC corpus
# Alex Cristia alecristia@gmail.com 2016-11-??

#########VARIABLES###########################
#ORIGFOLDER="/fhgfs/bootphon/scratch/lfibla/SegCatSpa/RES_corpus"
#RESFOLDER="/fhgfs/bootphon/scratch/lfibla/SegCatSpa/conc_cat/res_conc/100"
#DATAF=$1
#RESF=$2
#LANG=$3

DATAFOLDER=$1
RESFOLDER=$2

#echo $DATAFOLDER
PIPELINE="/fhgfs/bootphon/scratch/lfibla/CDSwordSeg/algoComp/segment_CatSpa.py"
#########


 # Run all algos in the cluster, once per version
#for VERSION in $DATAFOLDER/*
#do
#    if [ -d $VERSION ]
#    then
#        VNAME=`basename ${VERSION#$RESFOLDER}`
#        echo Clusterizing $VNAME
#        $PIPELINE --goldfile $VERSION/gold.txt \
#                  --output-dir $RESFOLDER/$VNAME \
#                  --algorithms all \
#                  --ag-median 5 \
#                  --clusterize \
#                  --jobs-basename $VNAME \
#                  $VERSION/tags.txt || exit 1
#    fi
#done


for VERSION in $DATAFOLDER/*
do
    if [ -d $VERSION ]
    then

echo $PIPELINE --goldfile $VERSION/gold.txt --output-dir $RESFOLDER/$VNAME --algorithms dibs $VERSION/tags.txt || exit 1
        VNAME=`basename ${VERSION}`
        echo Clusterizing $VNAME
        $PIPELINE --goldfile $VERSION/gold.txt \
                  --output-dir $RESFOLDER/$VNAME \
                  --algorithms dibs \
#                  --ag-median 5 \
                  --clusterize=False \
#                  --jobs-basename $VERSION \
                  $VERSION/tags.txt || exit 1
    fi
done
