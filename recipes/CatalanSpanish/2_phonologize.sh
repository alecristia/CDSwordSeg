#!/bin/sh
# Wrapper to take a single cleaned up transcript and phonologize it
# Alex Cristia alecristia@gmail.com 2015-10-26
# Modified by Laia Fibla laia.fibla.reixachs@gmail.com 2016-09-28 adapted to arg spanish


#########VARIABLES
#Variables to modify
LANGUAGE="cspanish" #language options: qom, english, cspanish (castillan spanish), catalan  -- NOTICE, IN SMALL CAPS


PATH_TO_SCRIPTS="/fhgfs/bootphon/scratch/lfibla/CDSwordSeg/phonologization"
#path to the phonologization folder - E.g. PATH_TO_SCRIPTS="/home/xcao/cao/projects/ANR_Alex/CDSwordSeg/phonologization/"

RES_FOLDER="/fhgfs/bootphon/scratch/lfibla/SegCatSpa/RES_corpus/"
#this is where we will put the processed versions of the transcripts E.g. RES_FOLDER="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/"
# NOTICE THE / AT THE END OF THE NAME


for ORTHO in ${RES_FOLDER}*ortholines.txt; do
	KEYNAME=$(basename "$ORTHO" -ortholines.txt)

	#########
	if [ "$LANGUAGE" = "qom" ]
	   then
	  echo "recognized $LANGUAGE"
	  tr '[:upper:]' '[:lower:]' < "$ORTHO"  | # change uppercase letters to lowercase letters
	  tr -d '^M' |
	  sed 's/ch/C/g' |
	  sed 's/sh/S/g' |
	  sed 's/ñ/N/g' |
	  tr "'" "Q"  > intopearl.tmp

	  echo "syllabify-corpus.pl"
	  perl $PATH_TO_SCRIPTS/scripts/syllabify-corpus.pl qom intopearl.tmp outofperl.tmp $PATH_TO_SCRIPTS

	  echo "removing blank lines"
	  sed '/^$/d' outofperl.tmp |
	  sed '/^ $/d'  |
	  sed 's/^\///' |
	sed 's/ / \;eword /g' |
	sed 's/\// \;esyll /g' > tmp.tmp

	  mv tmp.tmp ${RES_FOLDER}/${KEYNAME}-tags.txt

echo "creating gold versions"

sed 's/;esyll//g'  < ${RES_FOLDER}/${KEYNAME}-tags.txt |
    sed 's/ //g' |
    sed 's/;eword/ /g' > ${RES_FOLDER}/${KEYNAME}-gold.txt


	elif [ "$LANGUAGE" = "aspanish" ]
	   then
	  echo "recognized $LANGUAGE"
tr '[:upper:]' '[:lower:]'  < "$ORTHO"  | #Spanish files have different encoding
	  sed 's/ch/C/g' | # substitute all ch by tS
	  sed 's/v/b/g' |
	  sed 's/z/O/g' |
		sed 's/ce/Oe/g' |
		sed 's/ci/Oi/g' |
	  sed 's/c/k/g' |
	  sed 's/rr/R/g' | # substitute the spanish rr by 5
	  sed 's/ r/ R/g' | # substitue the initial r for R
	  sed 's/^r/R/g' | # substitue the initial r for R
	  sed 's/ll/L/g' | # very mixed in spain choose between L and y
	  sed 's/j/x/g' |
	  sed 's/qu/k/g' |
	  sed 's/h//g' | # removing h
	  sed 's/ñ/N/g' |
	  sed 's/á/a/g' |
	  sed 's/é/e/g' |
	  sed 's/í/i/g' |
	  sed 's/ó/o/g' |
	  sed 's/ú/u/g' |
	  sed 's/ü/u/g'  > intoperl.tmp

	  echo "syllabify-corpus.pl"
	  perl $PATH_TO_SCRIPTS/scripts/syllabify-corpus.pl aspanish intoperl.tmp outofperl.tmp $PATH_TO_SCRIPTS

	  echo "removing blank lines"
	  sed '/^$/d' outofperl.tmp |
	  sed '/^ $/d'  |
	  sed 's/^\///'  |
	sed 's/ / ;eword /g' |
	  sed -e 's/\(.\)/\1 /g'  |
	sed 's/ ; e w o r d/ ;eword /g' |
	sed 's/\// ;esyll /g'|
	tr -s ' ' > tmp.tmp

	  mv tmp.tmp ${RES_FOLDER}/${KEYNAME}-tags.txt

echo "creating gold versions"

sed 's/;esyll//g'  < ${RES_FOLDER}/${KEYNAME}-tags.txt |
    sed 's/ //g' |
    sed 's/;eword/ /g' > ${RES_FOLDER}/${KEYNAME}-gold.txt

	elif [ "$LANGUAGE" = "catalan" ]
		 then
		echo "recognized $LANGUAGE"
	tr '[:upper:]' '[:lower:]'  < "$ORTHO"  | #Spanish files have different encoding
		sed 's/ch/S/g' | # substitute all ch by tS
		sed 's/chs/ks/g' |
		sed 's/v/b/g' |
		sed 's/ce/se/g' |
		sed 's/ci/si/g' |
		sed 's/ca/ka/g' |
		sed 's/co/ko/g' |
		sed 's/cu/ku/g' |
		sed 's/rr/R/g' | # substitute the spanish rr by 5
		sed 's/ r/ R/g' | # substitue the initial r for R
		sed 's/^r/R/g' | # substitue the initial r for R
		sed 's/ll/L/g' |
		sed 's/j/3/g' |
		sed 's/qu/k/g' |
		sed 's/h//g' | # removing h
		sed 's/ny/N/g' |
		sed 's/tz/dz/g' |
		sed 's/dj/d3/g' |
		sed 's/tx/tS/g' |
		sed 's/ix/S/g' |
		sed 's/á/a/g' |
		sed 's/é/e/g' |
		sed 's/í/i/g' |
		sed 's/ó/o/g' |
		sed 's/ú/u/g' |
		sed 's/ü/u/g'  > intoperl.tmp

		echo "syllabify-corpus.pl"
		perl $PATH_TO_SCRIPTS/scripts/syllabify-corpus.pl aspanish intoperl.tmp outofperl.tmp $PATH_TO_SCRIPTS

		echo "removing blank lines"
		sed '/^$/d' outofperl.tmp |
		sed '/^ $/d'  |
		sed 's/^\///'  |
	sed 's/ / ;eword /g' |
		sed -e 's/\(.\)/\1 /g'  |
	sed 's/ ; e w o r d/ ;eword /g' |
	sed 's/\// ;esyll /g'|
	tr -s ' ' > tmp.tmp

		mv tmp.tmp ${RES_FOLDER}/${KEYNAME}-tags.txt

	echo "creating gold versions"

	sed 's/;esyll//g'  < ${RES_FOLDER}/${KEYNAME}-tags.txt |
		sed 's/ //g' |
		sed 's/;eword/ /g' > ${RES_FOLDER}/${KEYNAME}-gold.txt

	elif [ "$LANGUAGE" = "english" ]
	   then
	  echo "recognized $LANGUAGE"

	  echo "using festival"
	  ./scripts/phonologize $ORTHO -o ${KEYNAME}-tags.txt

echo "creating gold versions"

sed 's/;esyll//g'  < ${RES_FOLDER}/${KEYNAME}-tags.txt |
    sed 's/ //g' |
    sed 's/;eword/ /g' > ${RES_FOLDER}/${KEYNAME}-gold.txt


	else
		echo "Adapt the script to a new language"
		echo "I don't know $LANGUAGE"

	fi

done


echo "end"
