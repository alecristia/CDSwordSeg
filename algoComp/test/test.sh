#!/usr/bin/env bash

# Test of the dmcmc algorithm on a single input file
#
# Mathieu Bernard

ROOT=`readlink -f ../..`
# PHONO=$ROOT/phonologization/scripts
# CHILDES_ROOT=/fhgfs/bootphon/scratch/xcao/Alex_CDS_ADS/res_Childes_Eng-NA_cds

ABSPATH=$ROOT/algoComp/
RESFOLDER=${ABSPATH}test/
KEYNAME=key 

# clean up before testing
rm -f $RESFOLDER$KEYNAME-dmcmc* ${RESFOLDER}_$KEYNAME-cfgold.txt

# # setup input file and phonologize it
# ORTHO=$RESFOLDER$KEYNAME-ortholines.txt
# TAGS=$RESFOLDER$KEYNAME-tags.txt
# # scp oberon:$CHILDES_ROOT/Brent_res/w1-1005_cds/w1-1005-ortholines.txt $ORTHO
# # chmod -x $ORTHO

# echo Phonologizing $ORTHO...
# $PHONO/phonologize $ORTHO -o $TAGS

# echo Creating gold version
# sed 's/;esyll//g' $RESFOLDER$KEYNAME-tags.txt |
#     sed 's/ //g' |
#     sed 's/;eword/ /g' > $RESFOLDER$KEYNAME-gold.txt


#ALGO=puddle
ALGO=dmcmc
../pipeline/$ALGO.sh $ABSPATH $KEYNAME $RESFOLDER
