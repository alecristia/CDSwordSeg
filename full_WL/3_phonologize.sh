#!/usr/bin/env bash
# Wrapper to take a single cleaned up transcript and phonologize it
# Alex Cristia alecristia@gmail.com 2015-10-26
# 2015-11-26 - adapted to the winnipeglena corpus in its 4 versions

#########VARIABLES
LANGUAGE="english"
ORTFOLDER=/home/mbernard/dev/CDSwordSeg/full_WL/ortho
RESFOLDER=${ORTFOLDER/ortho/phono}
#########

for VERSION in ${ORTFOLDER}/WL*
do
    KEYNAME=`basename ${VERSION#$RESFOLDER}`
    ORTHO=$ORTFOLDER/$KEYNAME/ortholines.txt
    BASE=$RESFOLDER/$KEYNAME
    mkdir -p $BASE

    echo "phonologizing $ORTHO in $BASE/tags.txt"
    ../phonologization/scripts/phonologize $ORTHO -o $BASE/tags.txt
    #sed -i -e 's/  / /g' -e '/^ ?$/d' $BASE/tags.txt

    echo "creating gold versions ${BASE}-gold.txt"
    sed 's/;esyll//g' $BASE/tags.txt |
        sed 's/ //g' |
        sed 's/;eword/ /g' |
        sed 's/ $//g' > $BASE/gold.txt

    mv $BASE/gold.txt $BASE/gold-full.txt
    # mv $BASE/tags.txt $BASE/tags-full.txt

    N=`wc -l $BASE/gold-full.txt | cut -f1 -d' '`
    Ntest=`echo "$((N * 1 / 5))"`

    tail --lines=$Ntest $BASE/gold-full.txt > $BASE/gold.txt
    # tail --lines=$Ntest $BASE/gold-tags.txt > $BASE/tags.txt
done
