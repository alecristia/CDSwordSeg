#!/bin/sh
# Code to take an alreaddy phonologized transcript (tags.txt) and adapt it to the phoneme inventory of another language
# E.g. in this case the Bernstein corpus to match the phone notation in the Spanish corpus
# Laia Fibla laia.fibla.reixachs@gmail.com 2017-05-04
# Matching phonology from English to Spanish to make language comparisons and create a bilingual corpus

######### VARIABLES #################

#ORIG_FOLDER="/fhgfs/bootphon/scratch/lfibla/seg/SegEngSpa/Bernstein/berns_all/original_corpus"
# path to the folder conating the original gold.txt and tags.txt phonologized

#RES_FOLDER="/fhgfs/bootphon/scratch/lfibla/seg/SegEngSpa/Bernstein/berns_all/adapted_corpus/"
#this is where we will put the processed versions of the transcripts
# NOTICE THE / AT THE END OF THE NAME

ORIG_FOLDER=$1
RES_FOLDER=$2

#####################################

for file in $ORIG_FOLDER/tags.txt; do

	echo "substituting phones "
	sed 's/;eword/%/g' < $file |
	sed 's/;esyll/&/g' |
	sed 's/th/8/g' |
	sed 's/ch/tS/g' |
	sed 's/sh/S/g' |
	sed 's/dh/6/g' |
	sed 's/%/;eword/g' |
	sed 's/&/;esyll/g' > ${RES_FOLDER}/tags.txt

	echo "creating gold versions"

	sed 's/;esyll//g'  < ${RES_FOLDER}/tags.txt |
		tr -d ' ' |
		sed 's/;eword/ /g' > ${RES_FOLDER}/gold.txt

done

echo $RES_FOLDER
echo "done adapting phonologization"
