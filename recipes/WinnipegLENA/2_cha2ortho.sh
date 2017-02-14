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

    inclines=$RESFOLDER/${KEYNAME}/includedlines.txt
    ortho=$RESFOLDER/$KEYNAME/ortholines.txt

    touch $inclines
    for f in $CHAFOLDER/$KEYNAME/*.cha
    do
        $SCRIPTS/cha2sel.sh $f $inclines >> $RESFOLDER/log.txt
    done

    $SCRIPTS/selcha2clean.sh $inclines $ortho  >> $RESFOLDER/log.txt

    ./extraclean.sh $ortho >> $RESFOLDER/log.txt
done
