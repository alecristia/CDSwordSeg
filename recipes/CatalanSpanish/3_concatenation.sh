#!/bin/bash

# First steps to write the concatenation script
# This script is suposed to take several lines from several .cha files and combine them in a single file
# Use: Create an artificial bilingual corpus, create artcificial monolingual spanish and monolingual catalan for better comparison

# Include information of lines and words create a .txt with that information and the paths to each file (separate script)
# Tanke that information and use it here.

#PATH_TO_SCRIPTS="/fhgfs/bootphon/scratch/lfibla/CDSwordSeg/recipes/CatalanSpanish"	#path to the database_creation folder - E.g. PATH_TO_SCRIPTS="/home/xcao/cao/projects/ANR_Alex/CDSwordSeg/database_creation/"

ORIGFOLDER="/fhgfs/bootphon/scratch/lfibla/SegCatSpa/conc_spa"

RES_FOLDER="/fhgfs/bootphon/scratch/lfibla/SegCatSpa/conc/res_conc"	#this is where we will put the processed versions of the transcripts E.g. RES_FOLDER="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/" - NOTICE THE / AT THE END OF THE NAME

#KEYNAME="xcorpus" # chose a name for your corpus
#GOLD=$(basename "${RES_FOLDER}"*.cha)"-gold.txt"

for f in ${ORIGFOLDER}/*gold.txt; do                               # loop thought all files
    cut -f 2000 $f | # cut the fist and the second line of each file and past them in the output
    grep -v "^$" >> ${RES_FOLDER}/gold.txt
done

for f in ${ORIGFOLDER}/*tags.txt; do
    cut -f 2000 $f |
    grep -v "^$" >> ${RES_FOLDER}/tags.txt
done

echo "done mixing lines" #>> ConcatenatedFiles.txt

#done

################

#cd $RES_FOLDER
#find . -type d -empty -delete #remove empty folders for non-processed corpora
#echo "done removing empty folders"
#echo "done with ${RES_FOLDER}"

#############

# sed 'NUMq;d' file ex: sed '10q;d' file to print the 10th line of file.
