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
	sed 's/jh/1/g' |
	sed 's/th/8/g' |
	sed 's/ch/T/g' |
	sed 's/sh/S/g' |
	sed 's/dh/9/g' |
	sed 's/sh/S/g' |
	sed 's/zh/Z/g' |
	sed 's/uh/U/g' |
	sed 's/ih/I/g' |
	sed 's/aa/A/g' |
	sed 's/ae/E/g' |
	sed 's/ah/V/g' |
	sed 's/ao/O/g' |
	sed 's/ax/2/g' |
	sed 's/eh/3/g' |
	sed 's/er/4/g' |
	sed 's/hh/h/g' |
	sed 's/ng/7/g' |
	sed 's/y/j/g' |
	sed 's/%/;eword/g' |
	sed 's/&/;esyll/g' > ${RES_FOLDER}/tags.txt

	echo "creating gold versions"

	sed 's/;esyll//g'  < ${RES_FOLDER}/tags.txt |
		tr -d ' ' |
		sed 's/;eword/ /g' > ${RES_FOLDER}/gold.txt

done

echo $RES_FOLDER
echo "done adapting phonologization"
