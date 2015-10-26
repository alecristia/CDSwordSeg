#!/bin/sh
# Wrapper to take a single cleaned up transcript and phonologize it 
# Alex Cristia alecristia@gmail.com 2015-10-26

#########VARIABLES
#Variables to modify
RESFOLDER="/fhgfs/bootphon/scratch/acristia/results/res_bernsteinads/"	#folder where all versions of the file will be stored
KEYNAME="bernsteinads" #basic name of database
ORTHO="/fhgfs/bootphon/scratch/acristia/results/res_bernsteinads/bernsteinads-ortholines.txt"   #single file to be phonologized, must exist
LANGUAGE="english" #right now, only options are qom, english -- NOTICE, IN SMALL CAPS
#########

if [ "$LANGUAGE" = "qom" ]
   then
	echo "recognized $LANGUAGE"
	tr '[:upper:]' '[:lower:]' < "$ORTHO"  | 
	sed 's/ch/C/g' | 
	sed 's/sh/S/g' | 
	sed 's/ñ/N/g' | 
	tr "'" "Q"  | 
	iconv -t ISO-8859-1 > tmp.tmp

	echo "syllabify-corpus.pl"
	perl scripts/syllabify-corpus.pl qom tmp.tmp tmp2.tmp

	echo "removing blank lines"
	sed '/^$/d' tmp2.tmp | sed '/^ $/d'  | sed 's/^\///'  > tmp.tmp
	mv tmp.tmp $RESFOLDER${KEYNAME}-tags.txt

elif [ "$LANGUAGE" = "english" ]
   then
	echo "recognized $LANGUAGE"

	echo "using festival"
	python ./scripts/phonologyze.py $ORTHO -o $RESFOLDER${KEYNAME}-tags.txt

else
	echo "Adapt the script to a new language"
	echo "I don't know $LANGUAGE"

fi


echo "creating gold versions"

sed 's/;esyll//g'  $RESFOLDER${KEYNAME}-tags.txt | sed 's/ //g' | sed 's/;eword/ /g' > $RESFOLDER${KEYNAME}-gold.txt
