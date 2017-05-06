#!/bin/sh
# Wrapper to take a single cleaned up transcript and phonologize it
# Alex Cristia alecristia@gmail.com 2015-10-26
# Modified by Laia Fibla laia.fibla.reixachs@gmail.com 2016-09-28
# Adapted to castillan spanish and catalan using espeak

## Activate espeak ##
module load python-anaconda
source activate phonemizer
module load espeak

echo "ja estic funcionant" | phonemize -l ca # testing espeak

#########VARIABLES#################
#Variables to modify
LANGUAGE="cspanish" #language options:  cspanish (castillan spanish), catalan  -- NOTICE, IN SMALL CAPS


PATH_TO_SCRIPTS="/fhgfs/bootphon/scratch/lfibla/CDSwordSeg/phonologization"
#path to the phonologization folder - E.g. PATH_TO_SCRIPTS="/home/xcao/cao/projects/ANR_Alex/CDSwordSeg/phonologization/"

RES_FOLDER="/fhgfs/bootphon/scratch/lfibla/seg/SegCatSpa/big_corpora/RES_corpus_spa/"
#this is where we will put the processed versions of the transcripts E.g. RES_FOLDER="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/"
# NOTICE THE / AT THE END OF THE NAME

for ORTHO in ${RES_FOLDER}*ortholines.txt; do
	KEYNAME=$(basename "$ORTHO" -ortholines.txt)

	#########
	if [ "$LANGUAGE" = "catalan" ]
	   then
	  echo "recognized $LANGUAGE"

		echo "using espeak"
		phonemize -l ca $ORTHO -o phono.tmp

		echo "substituting letters"
		sed 's/ t / t/g' phono.tmp |
		sed 's/ s / s/g' |
		sed 's/^s /s/g' |
		sed 's/^t / t/g' |
		sed 's/d‍ʑiʎəm/giʎəm/g' |
		sed 's/ɣujʎəm/giʎəm/g' |
		sed 's/ d‍ʑiʎəm$/ giʎəm/g' |
		sed 's/^d‍ʑiʎəm$/giʎəm/g' |
		sed 's/ d‍ʑiʎəm / giʎəm /g' |
		sed 's/ d‍ʑi/ gi/g' |
		sed 's/^d‍ʑi/gi/g' |
		sed 's/ɣʊ/g/g' |
		sed 's/ɣw/g/g' |
		sed 's/ɣwj/gi/g' |
		sed 's/ɣu/g/g' |
		sed 's/ɣuj/gi/g' |
		sed 's/ɣ/g/g' |
		sed 's/β/b/g' |
		sed 's/ʋ/b/g' |
		sed 's/ð/d/g' |
		sed 's/^ɛs /əs /g' |
		sed 's/ɛs$/əs/g' |
		sed 's/ ɛs / əs /g' |
		sed 's/dʑ/dJ/g' |
	#	sed 's/ ets //g' |
	#	sed 's/^ets //g' |
	#	sed 's/ G / ets /g' |
	#	sed 's/^G /ets /g' |
		sed 's/ʑ/J/g' |
		sed 's/jɕʊ /Sɔ /g' |
		sed 's/jɕʊ$/Sɔ/g' |
	#	sed 's/jɕ/S/g' |
		sed 's/ kotɕə / kotSE /g' |
		sed 's/ kotɕə$/ kotSE/g' |
	#	sed 's/tɕ/tS/g' |
		sed 's/ɕ/S/g' |
		sed 's/ɲ/N/g' |
		sed 's/mp /m /g' |
		sed 's/mp$/m/g' |
		sed 's/kwi/ki/g' |
		sed 's/kwe/ke/g' |
		sed 's/kui/ki/g' |
		sed 's/kue/ke/g' |
		sed 's/ pɛrʊ / pərɔ /g' |
		sed 's/ anəm / anem /g' |
		sed 's/ɐ/a/g' |
		sed 's/ ɛʎ/ eʎ/g' |
		sed 's/^ɛʎ/eʎ/g' |
		sed 's/ ɛʎ/ eʎ/g' |
		sed 's/^ɛʎ/eʎ/g' |
		sed 's/ə/E/g' |
		sed 's/ʎ/L/g' |
		sed 's/ʊ/0/g' |
		sed 's/ɔ/O/g' |
		sed 's/ɛ/3/g' |
		sed 's/ɾr/R/g' |
		sed 's/ ɾr/ R/g' |
		sed 's/^ɾr/R/g' |
		sed 's/r/R/g' |
		sed 's/ r/ R/g' |
		sed 's/^r/R/g' |
		sed 's/rr/R/g' |
		sed 's/ɾ/r/g' |
		sed 's/ŋ/7/g' |
		sed 's/ aia/ iaia/g' |
		sed 's/ aia$/ iaia/g' |
		sed 's/ 3la / l/g' |
		sed "s/' //g" |
		sed "s/ '//g" |
		sed "s/'//g" |
		sed 's/dJi/gi/g' |
		sed 's/dJi /gi /g' |
		sed 's/dJi$/gi/g' |
		sed 's/ë/e/g' |
		sed 's/s0zaɡna/s0zana/g' |
		sed 's/ɡ/g/g' |
		sed 's/ɟ/t/g' |
		sed 's/⌈//g' |
		sed 's/ː//g' |
		sed 's/kot‍SE/kotSE/g' |
		sed 's/‍//g' |
		sed 's/j/y/g' |
		sed 's/"//g' |
		sed 's/ˌ//g' > intoperl.tmp

	  echo "syllabify-corpus.pl"
	  perl $PATH_TO_SCRIPTS/scripts/catspa-syllabify-corpus.pl catalan intoperl.tmp outofperl.tmp $PATH_TO_SCRIPTS

	elif [ "$LANGUAGE" = "cspanish" ]
		 then
		echo "recognized $LANGUAGE"
	tr '[:upper:]' '[:lower:]'  < "$ORTHO"  | #Spanish files have different encoding
		sed 's/ch/tS/g' | # substitute all ch by tS
		sed 's/v/b/g' |
		sed 's/z/8/g' |
		sed 's/ce/8e/g' |
		sed 's/ci/8i/g' |
		sed 's/C/tS/g' |
		sed 's/c/k/g' |
		sed 's/rr/R/g' | # substitute the spanish rr by 5
		sed 's/^r/R/g' | # substitue the initial r for R
		sed 's/ll/L/g' | # very mixed in spain choose between L and y
		sed 's/j/x/g' |
		sed 's/qu/kw/g' |
		sed 's/h//g' | # removing h
		sed 's/ñ/N/g' |
		sed 's/á/a/g' |
		sed 's/é/e/g' |
		sed 's/í/i/g' |
		sed 's/ó/o/g' |
		sed 's/ú/u/g' |
		sed 's/ü/u/g' |
		sed 's/pie⌉/pie/g' |
		sed 's/^pie⌉/pie/g' |
		sed 's/⌉//g' |
		sed 's/⌋//g' |
		sed 's/ë/e/g' |
		sed 's/⌈//g' |
    sed 's/ː//g' |
		sed 's/ˌ//g' |
		sed 's/"//g' > intoperl.tmp

		echo "syllabify-corpus.pl"
		perl $PATH_TO_SCRIPTS/scripts/catspa-syllabify-corpus.pl cspanish intoperl.tmp outofperl.tmp $PATH_TO_SCRIPTS

	fi

		echo "removing blank lines"
		sed '/^$/d' outofperl.tmp |
		sed '/^ $/d'  |
		sed '/^[ ]*$/d'  |
		sed 's/^ //'  |
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

echo $RES_FOLDER
echo "done phonologize"
