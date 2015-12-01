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

	echo "phonologizing $ORTHO in $RESFOLDER${KEYNAME}/${KEYNAME}-tags.txt"

	./scripts/phonologize $ORTHO -o $RESFOLDER${KEYNAME}/${KEYNAME}-tags.txt

	echo "creating gold versions $RESFOLDER${KEYNAME}/${KEYNAME}-gold.txt"

	sed 's/;esyll//g'  $RESFOLDER${KEYNAME}/${KEYNAME}-tags.txt | sed 's/ //g' | sed 's/;eword/ /g' > $RESFOLDER${KEYNAME}/${KEYNAME}-gold.txt

	mv $RESFOLDER${KEYNAME}/${KEYNAME}-gold.txt $RESFOLDER${KEYNAME}/${KEYNAME}-gold-full.txt
	#mv $RESFOLDER${KEYNAME}/${KEYNAME}-tags.txt $RESFOLDER${KEYNAME}/${KEYNAME}-tags-full.txt

	N=`wc -l $RESFOLDER${KEYNAME}/${KEYNAME}-gold-full.txt | cut -f1 -d' '`
	Ntest=`echo "$((N * 1 / 5))"`

	tail --lines=$Ntest $RESFOLDER${KEYNAME}/${KEYNAME}-gold-full.txt > $RESFOLDER$KEYNAME/${KEYNAME}-gold.txt
	#tail --lines=$Ntest $RESFOLDER${KEYNAME}/${KEYNAME}-gold-tags.txt > $RESFOLDER$KEYNAME/${KEYNAME}-tags.txt

done
