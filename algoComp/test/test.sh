#!/usr/bin/env bash

# Test of the dmcmc algorithm, along with phonologization.
#
# Mathieu Bernard

ROOT=`readlink -f ../..`
PHONO=$ROOT/phonologization/scripts

ABSPATH=$ROOT/algoComp/
KEYNAME=Brent_w1_1005
RESFOLDER=${ABSPATH}test/

# setup input file and phonologize it
# ORTHO=$RESFOLDER$KEYNAME-ortholines.txt
# TAGS=$RESFOLDER$KEYNAME-tags.txt
# cp $PHONO/test/childes/Brent_res/w1-1005_cds/w1-1005-ortholines.txt $ORTHO
# chmod -x $ORTHO

# echo Phonologizing $ORTHO...
# $PHONO/phonologize $ORTHO -o $TAGS
# echo Writed $TAGS


../pipeline/dmcmc.sh $ABSPATH $KEYNAME $RESFOLDER
