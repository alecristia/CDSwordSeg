#!/usr/bin/env bash

# Script for analyzing CDS and ADS for ELEAC corpus
# Alex Cristia alecristia@gmail.com 2016-11-??

#########VARIABLES###########################
ORIGFOLDER="/fhgfs/bootphon/scratch/aiturralde/RES_FOLDER"
PIPELINE="/fhgfs/bootphon/scratch/aiturralde/CDSwordSeg/algoComp/segment_aesp.py"
#########


# merge the subcorpora -- this is super ugly and needs to be fixed

for CORPUSFOLDER in ${ORIGFOLDER}/*DS/NS*; do
	cd $CORPUSFOLDER
	for j in $CORPUSFOLDER/[0-9]*gold.txt; do
		cat $j >> $CORPUSFOLDER/gold.txt
	done
done

for CORPUSFOLDER in ${ORIGFOLDER}/*DS/NS*; do
	cd $CORPUSFOLDER
	for j in $CORPUSFOLDER/[0-9]*tags.txt; do
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

for CORPUSFOLDER in ${ORIGFOLDER}/*DS/NS*; do
        cd $CORPUSFOLDER
	mkdir -p ANALIZEDAT #creats the folder containig the results.
        $PIPELINE --goldfile $CORPUSFOLDER/gold.txt \
                  --output-dir $CORPUSFOLDER/ANALIZEDAT \
                  --algorithms TPs dibs puddle AGu  \
                  --ag-median 5 \
                  --clusterize \
                  --jobs-basename CDS \
                  $CORPUSFOLDER/tags.txt || exit 1
#    fi
done
