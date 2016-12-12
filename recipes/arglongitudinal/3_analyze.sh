#!/usr/bin/env bash

# Script for analyzing CDS and ADS for ELEAC corpus
# Alex Cristia alecristia@gmail.com 2016-11-??

#########VARIABLES###########################
ORIGFOLDER="/home/lscpuser/Documents/RES_FOLDER"
RESFOLDER="/home/lscpuser/Documents/RES_FOLDER/"
PIPELINE="/home/lscpuser/Documents/CDSwordSeg/algoComp/segment_aesp.py"
#########


# merge the subcorpora -- this is super ugly and needs to be fixed

for CORPUSFOLDER in ${ORIGFOLDER}/*DS; do
	cd $CORPUSFOLDER
	for j in $CORPUSFOLDER/*gold.txt; do
		cat $j >> $CORPUSFOLDER/gold.txt
	done
done

for CORPUSFOLDER in ${ORIGFOLDER}/*DS; do
	cd $CORPUSFOLDER
	for j in $CORPUSFOLDER/*tags.txt; do
		cat $j >> $CORPUSFOLDER/tags.txt
	done
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

for CORPUSFOLDER in ${ORIGFOLDER}/*DS; do
        cd $CORPUSFOLDER
        $PIPELINE --goldfile $CORPUSFOLDER/gold.txt \
                  --output-dir $CORPUSFOLDER \
                  --algorithms TPs dibs puddle AGu  \
                  --ag-median 5 \
                  --clusterize \
                  --jobs-basename CDS \
                  $CORPUSFOLDER/tags.txt || exit 1
#    fi
done
