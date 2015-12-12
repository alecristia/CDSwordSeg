#!/usr/bin/env bash
# Wrapper to clean up a whole corpus and store it as a single transcript
# Alex Cristia alecristia@gmail.com 2015-11-26
# Adapted to compile the 4 versions of the Winnipeg LENA corpus that
# move on to further analyses
#    Namely: WL_ADS/CDS_HS/LS
#    i.e. WinnipegLENA_Register_Segmentation (Human=based or LENA-based)

#########VARIABLES
<<<<<<< HEAD:recipes/WinnipegLENA/2_cha2ortho.sh
CHAFOLDER=${1:-/home/mbernard/scratch/dev/CDSwordSeg/full_WL/cha}
RESFOLDER=${2:-${CHAFOLDER/cha/ortho}}
=======
CHAFOLDER=${1:-./cha}
RESFOLDER=${CHAFOLDER/cha/ortho}
>>>>>>> c2871d74ac2a138f0b310bc60748a8b4fbc58d14:full_WL/2_cha2ortho.sh

#########
mkdir -p $RESFOLDER

for VERSION in ${CHAFOLDER}/WL*
do
    KEYNAME=`echo ${VERSION#$CHAFOLDER}`
    mkdir -p $RESFOLDER/$KEYNAME

    inclines=$RESFOLDER/${KEYNAME}/includedlines.txt
    ortho=$RESFOLDER/$KEYNAME/ortholines.txt

    touch $inclines
    for f in $CHAFOLDER/$KEYNAME/*.cha
    do
        ../database_creation/scripts/cha2sel.sh $f $inclines >> $RESFOLDER/log.txt
    done

    ../database_creation/scripts/selcha2clean.sh $inclines $ortho >> $RESFOLDER/log.txt
done
