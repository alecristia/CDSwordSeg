#!/usr/bin/env bash
# Script for analyzing CDS and ADS for ELEAC corpus
# Alex Cristia alecristia@gmail.com 2016-11-??
# Laia Fibla 2017-03-15

#########VARIABLES###########################
DATAFOLDER=$1
RESFOLDER=$2

PIPELINE="/fhgfs/bootphon/scratch/lfibla/CDSwordSeg/algoComp/segment_CatSpa.py"
#########


# Run all algos in the cluster writing 'all' next to algorithms. 
# To just run one single algorithm choose from 'AGc3sf', 'AGu', 'dibs', 'dmcmc', 'ngrams', 'puddle', 'TPs', 'all'

mkdir -p ${RESFOLDER}/

for VERSION in $DATAFOLDER/*
do
    if [ -d $VERSION ]
    then

        VNAME=`basename ${VERSION#$RESFOLDER}`
        echo Clusterizing ${VNAME}
        $PIPELINE --goldfile ${VERSION}/gold.txt \
                  --output-dir ${RESFOLDER}/${VNAME} \
                  --algorithms dmcmc \
                  --ag-median 5 \
                  --clusterize \
                  --jobs-basename s${VNAME} \
                  ${VERSION}/tags.txt || exit 1
    fi
done



# To not pass thought the cluster
#echo $PIPELINE --goldfile $VERSION/gold.txt --output-dir $RESFOLDER/$VNAME --algorithms TPs $VERSION/tags.txt || exit 1

#        VNAME=`basename ${VERSION}`
#        echo Clusterizing $VNAME
#        $PIPELINE $VERSION/tags.txt \
#                  --goldfile $VERSION/gold.txt \
#                  --output-dir $RESFOLDER/$VNAME \
#                  --algorithms TPs dibs \
#                   --clusterize=False \
#                   --jobs-basename $VERSION \
#                  --ag-median 5 \
#            || exit 1
#    fi
#done
