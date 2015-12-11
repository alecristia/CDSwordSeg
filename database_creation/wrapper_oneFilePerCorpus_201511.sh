#!/bin/sh
# Wrapper to clean up a whole corpus and store it as a single transcript
# Alex Cristia alecristia@gmail.com 2015-11-26
# Adapted to compile the 4 versions of the Winnipeg LENA corpus that move on to further analyses
#	Namely: WL_ADS/CDS_HS/LS
#	i.e. WinnipegLENA_Register_Segmentation (Human=based or LENA-based)

#########VARIABLES
CHAFOLDER="/fhgfs/bootphon/scratch/acristia/data/WinnipegLENA/cha/"
RESFOLDER="/fhgfs/bootphon/scratch/acristia/results/WinnipegLENA/"


#########
for VERSION in ${CHAFOLDER}WL*; do
	KEYNAME=`echo ${VERSION#$CHAFOLDER}`
	mkdir "$RESFOLDER$KEYNAME"
	echo "$RESFOLDER$KEYNAME"
	inclines="$RESFOLDER${KEYNAME}/includedlines.txt"
	ortho="$RESFOLDER${KEYNAME}/ortholines.txt"

	touch $inclines

	for f in ${CHAFOLDER}$KEYNAME/*.cha; do
		#echo "$f"

		bash ./scripts/cha2sel.sh $f $inclines
	done

	bash ./scripts/selcha2clean.sh $inclines $ortho

done
