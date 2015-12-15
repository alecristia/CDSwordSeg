#!/usr/bin/env bash
# Wrapper to take a single cleaned up transcript and phonologize it
# Alex Cristia alecristia@gmail.com 2015-10-26
# 2015-11-26 - adapted to the winnipeglena corpus in its 4 versions

#########VARIABLES
ORTFOLDER=${1:-./ortho}
RESFOLDER=${2:-${ORTFOLDER/ortho/phono}}
ROOT=${3:-../..}
#########

# TODO parallelize this loop
for VERSION in ${ORTFOLDER}/WL*
do
    KEYNAME=`basename ${VERSION#$RESFOLDER}`
    ORTHO=$ORTFOLDER/$KEYNAME/ortholines.txt
    BASE=$RESFOLDER/$KEYNAME
    mkdir -p $BASE

    echo "phonologizing $ORTHO in $BASE/tags.txt"
    $ROOT/phonologization/scripts/phonologize $ORTHO $BASE/tags.txt

    echo "creating gold versions ${BASE}-gold.txt"
    sed 's/;esyll//g' $BASE/tags.txt |
        sed 's/ //g' |
        sed 's/;eword/ /g' |
        sed 's/ $//g' | tr -s ' ' > $BASE/gold.txt
done

exit
