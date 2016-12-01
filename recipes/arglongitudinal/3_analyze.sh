#!/usr/bin/env bash

# Script for analyzing CDS and ADS for ELEAC corpus
# Alex Cristia alecristia@gmail.com 2016-11-??

#########VARIABLES###########################
ORIGFOLDER="/fhgfs/bootphon/scratch/acristia/processed_corpora/arglongitudinal/CDS/"
RESFOLDER="/fhgfs/bootphon/scratch/acristia/processed_corpora/arglongitudinal/CDS_ALL"
PIPELINE="/fhgfs/bootphon/scratch/acristia/CDSwordSeg/algoComp/segment_aesp.py"
#########


# merge the subcorpora -- this is super ugly and needs to be fixed

for j in ${ORIGFOLDER}/[0-9]*gold.txt; do
	cat $j >> ${ORIGFOLDER}/gold.txt
done

for j in ${ORIGFOLDER}/[0-9]*tags.txt; do
	cat $j >> ${ORIGFOLDER}/tags.txt
done


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

        $PIPELINE --goldfile $ORIGFOLDER/gold.txt \
                  --output-dir $RESFOLDER \
                  --algorithms all  \
                  --ag-median 5 \
                  --clusterize \
                  --jobs-basename CDS \
                  $ORIGFOLDER/tags.txt || exit 1
#    fi
#done
