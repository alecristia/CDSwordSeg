#!/bin/sh
# Wrapper to take a single cleaned up transcript and phonologize it
# Alex Cristia alecristia@gmail.com 2015-10-26
# 2015-11-26 - adapted to the winnipeglena corpus in its 4 versions

#########VARIABLES
LANGUAGE="english" 
RESFOLDER="/fhgfs/bootphon/scratch/acristia/results/WinnipegLENA/"


#########
for VERSION in ${RESFOLDER}WL*; do
        KEYNAME=`echo ${VERSION#$RESFOLDER}`
        echo "$RESFOLDER$KEYNAME"
        ORTHO="$RESFOLDER${KEYNAME}/ortholines.txt"

	echo "phonologizing $ORTHO in $RESFOLDER${KEYNAME}/tags.txt"

	./scripts/phonologize $ORTHO -o $RESFOLDER${KEYNAME}/tags.txt

	echo "creating gold versions $RESFOLDER${KEYNAME}/gold.txt"

	sed 's/;esyll//g'  $RESFOLDER${KEYNAME}/tags.txt | sed 's/ //g' | sed 's/;eword/ /g' > $RESFOLDER${KEYNAME}/gold.txt
done
