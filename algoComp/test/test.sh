#!/usr/bin/env bash

# Test of the dmcmc algorithm on a single input file
#
# Mathieu Bernard

ROOT=`readlink -f ../..`
PHONO=$ROOT/phonologization/scripts
CHILDES_ROOT=/fhgfs/bootphon/scratch/xcao/Alex_CDS_ADS/res_Childes_Eng-NA_cds
#CHILDES_ROOT=~/data/alex_cds/childes/

ABSPATH=$ROOT/algoComp/
RESFOLDER=${ABSPATH}test/
KEYNAME=key

# # clean up before testing
# rm -f ./*.txt

# # setup input file and phonologize it
ORTHO=$RESFOLDER$KEYNAME-ortholines.txt
TAGS=$RESFOLDER$KEYNAME-tags.txt
# scp oberon:$CHILDES_ROOT/Brent_res/w1-1005_cds/w1-1005-ortholines.txt $ORTHO.at
# sed 's/@l//g' $ORTHO.at | sed 's/@w//g' > $ORTHO
# rm -r $ORTHO.at

# echo Phonologizing $ORTHO...

# $PHONO/phonologize $ORTHO -o $TAGS

# creating gold version
sed 's/;esyll//g' $TAGS |
    sed 's/ //g' |
    sed 's/;eword/ /g' |
    sed 's/ $//g' > $RESFOLDER${KEYNAME}-gold.txt

ALGO=puddle
#ALGO=dmcmc
P=../pipeline
$P/clusterize.sh "$P/$ALGO.sh $ABSPATH $KEYNAME $RESFOLDER"
