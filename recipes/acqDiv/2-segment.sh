#!/usr/bin/env bash

# Script for analyzing crossling varied corpora
# Alex Cristia alecristia@gmail.com 2017-04

#########VARIABLES###########################
LANGUAGE=$1
PIPELINE=$2
ACQDIV_FOLDER=$3
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

for THISGOLD in $ACQDIV_FOLDER/processed/$LANGUAGE/$LANGUAGE*-gold.txt; do
THISTAG="${THISGOLD/gold/tags}"
echo "$THISGOLD"
echo "$THISTAG"

	
        $PIPELINE --goldfile ${THISGOLD} \
                  --output-dir ${ACQDIV_FOLDER}/results/${LANGUAGE} \
                  --algorithms  dibs \
#                  --ag-median 5 \
#                  --clusterize \
#		  --jobs-basename ${ACQDIV_FOLDER}/${LANGUAGE} \
                  ${THISTAG} 
#|| exit 1
done
