#!/usr/bin/env bash
# Script for analyzing mono and bilingual corpus with diferent mixings - M2 SegCatSpa -
# Alex Cristia alecristia@gmail.com 2016-11
# Adapted by Laia Fibla 2017-03-15 laia.fibla.reixachs@gmail.com

######### VARIABLES ###############

DATAFOLDER=$1
RESFOLDER=$2

PIPELINE="/fhgfs/bootphon/scratch/lfibla/CDSwordSeg/algoComp/segment_CatSpa.py"

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/cm/shared/apps/boost/1.62.0/stage/lib

##################################


# Run all algos in the cluster writing 'all' next to algorithms.
# To just run one single algorithm choose from 'AGc3sf', 'AGu', 'dibs', 'dmcmc', 'ngrams', 'puddle', 'TPs', 'all'

module load python-anaconda

mkdir -p ${RESFOLDER}/

for VERSION in $DATAFOLDER/*
do
    if [ -d $VERSION ]
    then

        VNAME=`basename ${VERSION#$RESFOLDER}`
        echo Clusterizing ${VNAME}
        $PIPELINE --goldfile ${VERSION}/gold.txt \
                  --output-dir ${RESFOLDER}/${VNAME} \
                  --algorithms AGc3sf \
                  --ag-median 1 \
                  --clusterize \
                  --jobs-basename s${VNAME} \
                  ${VERSION}/tags.txt || exit 1
    fi
done



# To not pass thought the cluster (just to use in emergecy case and for light algos)
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
