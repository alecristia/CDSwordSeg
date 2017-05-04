#!/bin/sh
# Wrapper to take a single cleaned up transcript and phonologize it
# Alex Cristia alecristia@gmail.com 2015-10-26
# Modified by Laia Fibla laia.fibla.reixachs@gmail.com 2016-09-28 adapted to arg spanish
# Modified by Georgia Loukatou georgialoukatou@gmail.com 2017-04-02 adapted to chintang, japanese 


#########VARIABLES
LANGUAGE=$1 #language options:  japanese, chintang 
PATH_TO_SCRIPTS=$2 # E.g. PATH_TO_SCRIPTS="CDSwordSeg/phonologization/"
RES_FOLDER=$3 #this is where we find the acqdiv corpus in preprocessed and postprocessed forms/"
####

for ORTHO in ${RES_FOLDER}/data/${LANGUAGE}/*surface.txt; do
	KEYNAME=$(basename "$ORTHO" .txt)

#echo "$ORTHO"
#echo "$LANGUAGE"
#echo "$PATH_TO_SCRIPTS"
#echo "$RES_FOLDER"

	#########
	if [ "$LANGUAGE" = "japanese" ]; then
	  echo "recognized $LANGUAGE"
tr '[:upper:]' '[:lower:]'  < "$ORTHO"  | 
	    sed 's/ $//g' | #
	  sed 's/^$//g' | #
	  sed 's/ch/C/g' | #
	  sed 's/sh/Z/g' |
	  sed 's/tt/T/g' |
	  sed 's/kk/K/g' |
	  sed 's/gg/G/g' |
	  sed 's/ss/S/g' |
	  sed 's/NA//g' |
	  sed 's/ʃ/J/g' |
	  sed 's/ŋ/H/g' |
	  sed 's/sy/W/g' |
	  sed 's/zy/Q/g' |
	  sed 's/ty/D/g' |
	  sed 's/ɽ/R/g' |
	  sed 's/ʒ/3/g' |
	  sed 's/え/X/g' |
	  sed 's/θ/V/g' |
	  sed 's/pp/P/g' |
	  sed 's/aa/A/g' |
	  sed 's/ii/I/g' |
	  sed 's/ee/E/g' |
	  sed 's/oo/O/g' |
	  sed 's/uu/U/g' |
	  sed 's/ai/3/g' |
	  sed 's/oi/4/g' |
	  sed 's/au/5/g' |
	  sed 's/ɘ/1/g' |
	  sed 's/o:/O/g' |
	  sed 's/u:/U/g' |
	  sed 's/e:/E/g' |
	  sed 's/a:/A/g' |
	  sed 's/i:/I/g' |
	  sed 's/ei/E/g' |
	  sed 's/ə/2/g' > ${RES_FOLDER}/processed/$LANGUAGE/${KEYNAME}-intoperl.tmp


	elif [ "$LANGUAGE" = "chintang" ]
		 then
		echo "recognized $LANGUAGE"
	tr '[:upper:]' '[:lower:]'  < "$ORTHO"  | 
		sed 's/ɨ/1/g' |
		sed 's/ei/2/g' |
		sed 's/ai/3/g' |
		sed 's/oi/4/g' |
		sed 's/ui/5/g' |
		sed 's/au/6/g' |
		sed 's/1i/7/g' |
		sed 's/[àãâā]/a/g' |
		sed 's/[ā]/a/g' |
		sed 's/[ũùûù]/u/g' |
		sed 's/[ôò]/o/g' |
		sed 's/[èẽ]/e/g' |
		sed 's/[ĩīĩ]/i/g' |
		sed 's/jh//g' |
		sed 's/kk/K/g' |
		sed 's/tt/T/g' | # substitute all ch by tS	
		sed 's/cc/C/g' |
		sed 's/bb/B/g' |
		sed 's/ss/S/g' |
		sed 's/nn/N/g' |
		sed 's/ñ/N/g' |
		sed 's/mm/M/g' |
		sed 's/jj/J/g' |
		sed 's/lh/L/g' | # substitute the spanish rr by 5
		sed 's/gh/G/g' | # substitue the initial r for R
		sed 's/pp/P/g' | # substitue the initial r for R
		sed 's/dh/D/g' |
		sed 's/ḍ/D/g' |
		sed 's/ch/Y/g' |
		sed 's/jh/Ζ/g' |
		sed 's/bh/V/g' | # removing h
		sed 's/kh/Q/g' |
		sed 's/th/X/g' |
		sed 's/ʔ/q/g' |
		sed 's/ṽ/w/g' |
		sed 's/ŋ/H/g' |
		sed 's/�/W/g' |
		sed 's/m̄/m/g' |
		sed 's//W/g' |
		sed 's/Ḧ/H/g' |
		sed 's/Ë/e/g' |
		sed 's/ɲ/N/g' |
		sed 's/hAA̴/hAA/g' |
		sed 's/¨//g'  |
		sed 's/Œ ñ/Z/g' |
		sed 's/Œ £/Z/g' |
		sed 's/‡ • §//g' |
		sed 's/̵//g'  |
		sed 's/̪//g'  |
		sed 's/ǃ//g'  |
		sed 's/~//g'  |
		sed 's/ʌ//g'  |
		sed 's/˜//g'  |
		sed 's/।//g'  |
		sed 's/̴̴//g'  |
		sed 's/"//g'  |
		sed 's/lUɡE//g' |
		sed 's/IɡIMA//g' |
		sed 's/ph/F/g' > ${RES_FOLDER}/processed/$LANGUAGE/${KEYNAME}-intoperl.tmp

	fi

	  echo "syllabify-corpus.pl"
	  perl $PATH_TO_SCRIPTS/scripts/new-syllabify-corpus.pl $LANGUAGE ${RES_FOLDER}/processed/$LANGUAGE/${KEYNAME}-intoperl.tmp ${RES_FOLDER}/processed/$LANGUAGE/${KEYNAME}-outofperl.tmp $PATH_TO_SCRIPTS


		echo "removing blank lines"
		LANG=C LC_CTYPE=C LC_ALL=C
		sed '/^$/d' ${RES_FOLDER}/processed/$LANGUAGE/${KEYNAME}-outofperl.tmp |
		sed '/^ $/d'  |
		sed '/^[ ]*$/d'  |
		sed 's/^ //g'  |
		sed 's/\n//g' |
		sed 's/?//g' |
		sed 's/-//g' |
		sed 's/_//g' |
		sed 's/://g' |
		sed 's/^\///g'  | #there aren't really any of these, this is just a cautionary measure
	sed 's/ / ;eword /g' |
		sed -e 's/\(.\)/\1 /g'  |
	sed 's/ ; e w o r d/ ;eword /g' |
	sed 's/\// ;esyll /g'|
	tr -s ' ' > ${RES_FOLDER}/processed/$LANGUAGE/${KEYNAME}-tmp.tmp

		mv ${RES_FOLDER}/processed/$LANGUAGE/${KEYNAME}-tmp.tmp ${RES_FOLDER}/processed/$LANGUAGE/${KEYNAME}-tags.txt

	echo "creating gold versions"

	sed 's/;esyll//g'  < ${RES_FOLDER}/processed/$LANGUAGE/${KEYNAME}-tags.txt |
		tr -d ' ' |
		sed 's/;eword/ /g' > ${RES_FOLDER}/processed/$LANGUAGE/${KEYNAME}-gold.txt

done


echo "end"

##pcregrep --color='auto' -n '[^\x00-\x7F]' $PROCESSED_FILE2
