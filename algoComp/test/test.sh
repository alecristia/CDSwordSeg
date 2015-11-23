#!/usr/bin/env bash

<<<<<<< HEAD
# Test of the dmcmc algorithm, along with phonologization.
#
# Mathieu Bernard

ROOT=/home/mbernard/dev/CDSwordSeg
PHONO=$ROOT/phonologization/scripts

ABSPATH=$ROOT/algoComp/
KEYNAME=Brent_w1_1005
RESFOLDER=${ABSPATH}test/
=======
# Test of the dmcmc algorithm on a single input file
#
# Mathieu Bernard

ROOT=`readlink -f ../..`
PHONO=$ROOT/phonologization/scripts
CHILDES_ROOT=/fhgfs/bootphon/scratch/xcao/Alex_CDS_ADS/res_Childes_Eng-NA_cds

ABSPATH=$ROOT/algoComp/
RESFOLDER=${ABSPATH}test/
KEYNAME=Brent_w1_1005

# clean up before testing
rm -f $RESFOLDER$KEYNAME*
>>>>>>> 151ff412db042803afcb6b251b51338975415fa8

# setup input file and phonologize it
ORTHO=$RESFOLDER$KEYNAME-ortholines.txt
TAGS=$RESFOLDER$KEYNAME-tags.txt
<<<<<<< HEAD
cp $PHONO/test/childes/Brent_res/w1-1005_cds/w1-1005-ortholines.txt $ORTHO
=======
cp $CHILDES_ROOT/Brent_res/w1-1005_cds/w1-1005-ortholines.txt $ORTHO
>>>>>>> 151ff412db042803afcb6b251b51338975415fa8
chmod -x $ORTHO

echo Phonologizing $ORTHO...
$PHONO/phonologize $ORTHO -o $TAGS
<<<<<<< HEAD
echo Writed $TAGS

=======

echo Creating gold version
cat $RESFOLDER${KEYNAME}-tags.txt |
    sed 's/;esyll//g' |
    sed 's/ //g' |
    sed 's/;eword/ /g' > $RESFOLDER${KEYNAME}-gold.txt
>>>>>>> 151ff412db042803afcb6b251b51338975415fa8

../pipeline/dmcmc.sh $ABSPATH $KEYNAME $RESFOLDER
