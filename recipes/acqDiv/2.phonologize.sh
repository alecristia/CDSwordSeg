#!/bin/sh
# Wrapper to take a single cleaned up transcript and phonologize it
# Alex Cristia alecristia@gmail.com 2015-10-26
# Modified by Laia Fibla laia.fibla.reixachs@gmail.com 2016-09-28 adapted to arg spanish
# Modified by Georgia Loukatou georgialoukatou@gmail.com 2017-04-02 adapted to chintang, japanese 


#########VARIABLES
#Variables to modify
LANGUAGE=$1 #language options:  cspanish (castillan spanish), catalan  -- NOTICE, IN SMALL CAPS


PATH_TO_SCRIPTS=$2
#"/Users/bootphonproject/Desktop/segmentation/scripts/"
#path to the phonologization folder - E.g. PATH_TO_SCRIPTS="/home/xcao/cao/projects/ANR_Alex/CDSwordSeg/phonologization/"

RES_FOLDER=$3
#"/Users/bootphonproject/Desktop/segmentation/results/japanese"
#this is where we will put the processed versions of the transcripts E.g. RES_FOLDER="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/"
# NOTICE THE / AT THE END OF THE NAME

LC_ALL=C

for ORTHO in ${RES_FOLDER}/*clean_corpus.txt; do
	KEYNAME=$(basename "$ORTHO" .txt)

	#########
	if [ "$LANGUAGE" = "japanese" ]
	   then
	  echo "recognized $LANGUAGE"
tr '[:upper:]' '[:lower:]'  < "$ORTHO"  | #Spanish files have different encoding
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
	  sed 's/ə/2/g' > intoperl.tmp

	  echo "syllabify-corpus.pl"
	  perl $PATH_TO_SCRIPTS/syllabify-corpus.pl japanese intoperl.tmp outofperl.tmp $PATH_TO_SCRIPTS


	elif [ "$LANGUAGE" = "chintang" ]
		 then
		echo "recognized $LANGUAGE"
	tr '[:upper:]' '[:lower:]'  < "$ORTHO"  | #Spanish files have different encoding
		sed 's/ɨ/1/g' |
		sed 's/ei/2/g' |
		sed 's/ai/3/g' |
		sed 's/oi/4/g' |
		sed 's/ui/5/g' |
		sed 's/au/6/g' |
		sed 's/1i/7/g' |
		sed 's/[àãâā]/A/g' |
		sed 's/[ā]/A/g' |
		sed 's/[ũùûù]/U/g' |
		sed 's/[ôò]/O/g' |
		sed 's/[èẽ]/E/g' |
		sed 's/[ĩīĩ]/I/g' |
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
		sed 's/m̄/m/' |
		sed 's//W/' |
		sed 's/Ḧ/H/' |
		sed 's/Ë/E/' |
		sed 's/ɲ/N/' |
		sed 's/hAA̴/hAA/' |
		sed 's/¨//'  |
		sed 's/Œ ñ/Z/' |
		sed 's/Œ £/Z/' |
		sed 's/‡ • §//' |
		sed 's/̵//'  |
		sed 's/̪//'  |
		sed 's/ǃ//'  |
		sed 's/~//'  |
		sed 's/ʌ//'  |
		sed 's/˜//'  |
		sed 's/।//'  |
		sed 's/̴̴//'  |
		sed 's/"//'  |
		sed 's/lUɡE//' |
		sed 's/IɡIMA//' |
		sed 's/ph/F/g' > intoperl.tmp

		echo "syllabify-corpus.pl"
		perl $PATH_TO_SCRIPTS/syllabify-corpus.pl chintang intoperl.tmp outofperl.tmp $PATH_TO_SCRIPTS

	fi

		echo "removing blank lines"
		LANG=C LC_CTYPE=C LC_ALL=C
		sed '/^$/d' outofperl.tmp |
		sed '/^ $/d'  |
		sed '/^[ ]*$/d'  |
		sed 's/^ //'  |
		sed 's/\n//' |
		sed 's/^\///'  | #there aren't really any of these, this is just a cautionary measure
	sed 's/ / ;eword /g' |
		sed -e 's/\(.\)/\1 /g'  |
	sed 's/ ; e w o r d/ ;eword /g' |
	sed 's/\// ;esyll /g'|
	tr -s ' ' > tmp.tmp

		mv tmp.tmp ${RES_FOLDER}/${KEYNAME}-tags.txt

	echo "creating gold versions"

	sed 's/;esyll//g'  < ${RES_FOLDER}/${KEYNAME}-tags.txt |
		tr -d ' ' |
		sed 's/;eword/ /g' > ${RES_FOLDER}/${KEYNAME}-gold.txt

done


echo "end"

##pcregrep --color='auto' -n '[^\x00-\x7F]' $PROCESSED_FILE2