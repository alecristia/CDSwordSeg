#!/usr/bin/env bash

# Test of the dmcmc algorithm, along with phonologization.
#
# Mathieu Bernard

ROOT=`readlink -f ../..`
PHONO=$ROOT/phonologization/scripts
ABSPATH=$ROOT/algoComp/
RESFOLDER=${ABSPATH}test/
KEYNAME=Brent_w1_1005

# clean up before testing
rm -f $RESFOLDER$KEYNAME*

# setup input file and phonologize it
ORTHO=$RESFOLDER$KEYNAME-ortholines.txt
TAGS=$RESFOLDER$KEYNAME-tags.txt
cp $PHONO/test/childes/Brent_res/w1-1005_cds/w1-1005-ortholines.txt $ORTHO
chmod -x $ORTHO

echo Phonologizing $ORTHO...
$PHONO/phonologize $ORTHO -o $TAGS

echo Creating gold version
cat   $RESFOLDER${KEYNAME}-tags.txt |
    sed 's/;esyll//g' |
    sed 's/ //g' |
    sed 's/;eword/ /g' > $RESFOLDER${KEYNAME}-gold.txt

../pipeline/dmcmc.sh $ABSPATH $KEYNAME $RESFOLDER
