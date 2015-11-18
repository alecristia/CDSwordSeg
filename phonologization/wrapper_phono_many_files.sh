#!/bin/sh
# Wrapper to take a single cleaned up transcript and phonologize it
# Alex Cristia alecristia@gmail.com 2015-10-26

#########VARIABLES
#Variables to modify
RES_FOLDER="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/" - NOTICE THE / AT THE END OF THE NAME
OUTPUT_FILE2="YOUR_ABSOLUTE_PATH_TO_LIST_OF_PROCESSED_FILES" #E.g. OUTPUT_FILE2="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/processed_files.txt"
#########

for… #NOT finished -- what we should do here is read in one file at a time and add the phono and gold in there
	echo "using festival"
	./scripts/phonologize $ORTHO -o $RESFOLDER${KEYNAME}-tags.txt

echo "creating gold versions"

sed 's/;esyll//g'  $RESFOLDER${KEYNAME}-tags.txt | sed 's/ //g' | sed 's/;eword/ /g' > $RESFOLDER${KEYNAME}-gold.txt

fi
