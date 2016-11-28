#!/bin/bash

# First steps to write the concatenation script
# This script is suposed to take several lines from several .cha files and combine them in a single file
# Use: Create an artificial bilingual corpus, create artcificial monolingual spanish and monolingual catalan for better comparison

PATH_TO_SCRIPTS="/Users/Laia/Documents/CDSwordSeg/recipes/concatenation"	#path to the database_creation folder - E.g. PATH_TO_SCRIPTS="/home/xcao/cao/projects/ANR_Alex/CDSwordSeg/database_creation/"

RES_FOLDER="/Users/Laia/Documents/processed_corpora/RES_castcorpus/CDS/"	#this is where we will put the processed versions of the transcripts E.g. RES_FOLDER="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/" - NOTICE THE / AT THE END OF THE NAME

#GOLD=$(basename "${RES_FOLDER}"*.cha)"-gold.txt"

for f in ${RES_FOLDER}/*gold.txt; do         # loop thought all files
	KEYNAME=$(basename "$ORTHO" -ortholines.txt)

while IFS='' read -r line || [[ -n "$line" ]]; do
    echo "Text read from file: $line"
    mv tmp.tmp ${KEYNAME}-gold.txt
done < "$1"


done

cd $RES_FOLDER
find . -type d -empty -delete #remove empty folders for non-processed corpora
echo "done removing empty folders"
echo "done with ${RES_FOLDER}"

#############


{RES_FOLDER}/${KEYNAME}-gold.txt

head and pipe with tail will be slow for a huge file. I would suggest sed like this:

sed 'NUMq;d' file
Where NUM is the number of the line you want to print; so, for example, sed '10q;d' file to print the 10th line of file.
