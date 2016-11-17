#!/usr/bin/env bash

# Script for analyzing CDS and ADS for ELEAC corpus
# Alex Cristia alecristia@gmail.com 2016-11-??

#########VARIABLES###########################
DATAFOLDER="/fhgfs/bootphon/scratch/acristia/Documents/processed_corpora/arglongitudinal_res/CDS"
RESFOLDER="/fhgfs/bootphon/scratch/acristia/Documents/processed_corpora/arglongitudinal_res/CDS"
PIPELINE="/fhgfs/bootphon/scratch/acristia/CDSwordSeg/algoComp/segment.py"
#########


# merge the subcorpora -- this is super ugly and needs to be fixed
mkdir -p ${DATAFOLDER}/parts
cp ${DATAFOLDER}/*txt ${DATAFOLDER}/parts/

for j in ${DATAFOLDER}/parts/*gold.txt; do
	cat $j >> ${DATAFOLDER}/gold.txt
done

for j in ${DATAFOLDER}/parts/*tags.txt; do
	cat $j >> ${DATAFOLDER}/tags.txt
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

        $PIPELINE --goldfile gold.txt \
                  --output-dir $RESFOLDER \
                  --algorithms dibs \
                  --ag-median 5 \
                  --clusterize \
                  --jobs-basename CDS \
                  tags.txt || exit 1
#    fi
#done
