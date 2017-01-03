#!/usr/bin/env bash

# Script for analyzing CDS and ADS for ELEAC corpus
# Alex Cristia alecristia@gmail.com 2016-11-??

#########VARIABLES###########################
ORIGFOLDER="/fhgfs/bootphon/scratch/aiturralde/RES_FOLDER"
PIPELINE="/fhgfs/bootphon/scratch/aiturralde/CDSwordSeg/algoComp/segment_aesp.py"
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
for THISFOLDER in $ORIGFOLDER/*DS/NS*/COMPDAT; do
	
        $PIPELINE --goldfile $THISFOLDER/gold.txt \
                  --output-dir $THISFOLDER/ANALIZEDAT \
                  --algorithms TPs dibs \
                  --ag-median 5 \
                  --clusterize \
		  --jobs-basename $THISFOLDER \
                  $THISFOLDER/tags.txt || exit 1
done
