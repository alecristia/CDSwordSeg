#!/usr/bin/env bash
#
# Wrapper to clean up a whole corpus and store it as a single
# transcript.
#
# Adapted to compile the 4 versions of the Winnipeg LENA corpus that
# move on to further analyses Namely: WL_ADS/CDS_HS/LS
# i.e. WinnipegLENA_Register_Segmentation (Human=based or LENA-based)
#
# Alex Cristia alecristia@gmail.com 2015-11-26
# 2017-11-01 changed to keep input files separate in the output


#########VARIABLES
#Variables that have been passed by the user
DATAFOLDER=$1
#########

#DATAFOLDER=${1:-./data}
SCRIPTS=${2:-../../database_creation/scripts}

# must exist and contain cha files
CHAFOLDER=$DATAFOLDER/cha

# will be created and output ortholines will be stored there
RESFOLDER=$DATAFOLDER/ortho
mkdir -p $RESFOLDER

# for ADS, CDS 
for VERSION in ${CHAFOLDER}/WL*
do
    KEYNAME=`echo ${VERSION#$CHAFOLDER}`
    mkdir -p $RESFOLDER/$KEYNAME

    for f in $CHAFOLDER/$KEYNAME/*.cha
    do
	g=${f##*/}
	keyf=${g%.*}
#echo $keyf
#echo ${RESFOLDER}/$KEYNAME/${keyf}-inclines.txt
        $SCRIPTS/cha2sel.sh $f ${RESFOLDER}/$KEYNAME/${keyf}-inclines.txt >> $RESFOLDER/log.txt
        $SCRIPTS/selcha2clean.sh ${RESFOLDER}/$KEYNAME/${keyf}-inclines.txt ${RESFOLDER}/$KEYNAME/${keyf}-ortholines.txt >> $RESFOLDER/log.txt
	./extraclean.sh ${RESFOLDER}/$KEYNAME/${keyf}-ortholines.txt >> $RESFOLDER/log.txt
    done

done
