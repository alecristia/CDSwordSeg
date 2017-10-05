#!/bin/sh
# Wrapper written by Alex Cristia to process the orthograpically transcived corpora in .cha
# Modified by Laia Fibla 2017-02-15

###### Variables #######

# Adapt the following variables, being careful to provide absolute paths
# Here all paths are previously specified in the bigwrap.sh

PATH_TO_SCRIPTS=$1
#path to the database_creation folder e.g. PATH_TO_SCRIPTS="/fhgfs/bootphon/scratch/lfibla/CDSwordSeg/database_creation"
INPUT_CORPUS=$2
#where you have put the talkbank corpora to be analyzed e.g. INPUT_CORPUS="/fhgfs/bootphon/scratch/lfibla/seg/SegCatSpa/corpus_database/cat_big"
RES_FOLDER=$3
#this is where we will put the processed versions of the transcripts e.g. RES_FOLDER="/fhgfs/bootphon/scratch/lfibla/seg/SegCatSpa/big_corpora/RES_corpus_cat"

########################

INPUT_FILES="${RES_FOLDER}info.txt" # e.g. INPUT_FILES="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/childes_info.txt"

OUTPUT_FILE2="${RES_FOLDER}processedFiles.txt" #e.g. OUTPUT_FILE2="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/processed_files.txt"

mkdir -p $RES_FOLDER	#create folder that will contain all output files
python ${PATH_TO_SCRIPTS}/scripts/extract_childes_info.py $INPUT_CORPUS $INPUT_FILES
echo "done extracting info from corpora"


for f in ${INPUT_CORPUS}/*.cha; do	#loop through all cha files

echo "finding out who's a speaker in $f"

	    IncludedParts=`tr '\015' '\n' < $f | #for each file
		iconv -f ISO-8859-1 | #convert the file to deal with multibyte e.g. accented characters ###!!! try -t
		grep "@ID" |      #take only @ID lines of the file
		awk -F "|" '{ print $3, $8 }' | #let through only 3-letter code and role
        grep -v 'Child\|Sister\|Brother\|Cousin\|Boy\|Girl\|Unidentified\|Sibling\|Target\|Nurse\|Investigator\|Experimentator\|Non_Hum\|Play' | #remove all the children and non-human participants to leave only adults
        awk '{ print $1 }' | #print out the first item, which is the 3 letter code for those adults
		tr "\n" "%" | # put them all in the same line
		sed "s/^/*/g" | #add an asterisk at the beginning
		sed "s/%/\\\\\|*/g" | #add a pipe between every two
		sed "s/\\\\\|.$//" ` #remove the pipe* next to the end of line & close the text call

		SELFILE=$(basename "$f" .cha)"-includedlines.txt"
		bash ${PATH_TO_SCRIPTS}/scripts/cha2sel_withinputParticipants.sh $f ${RES_FOLDER}/${SELFILE} $IncludedParts

 		ORTHO=$(basename "$f" .cha)"-ortholines.txt"
		bash ${PATH_TO_SCRIPTS}/scripts/selcha2clean.sh ${RES_FOLDER}/${SELFILE} ${RES_FOLDER}/$ORTHO

		echo "processed $f" >> $OUTPUT_FILE2
done

echo "done creating included and ortholines"

cd $RES_FOLDER
find . -type d -empty -delete #remove empty folders for non-processed corpora
echo "done removing empty folders"

echo "files in ${RES_FOLDER}"
