#!/usr/bin/env bash
#2017-01-02


#########VARIABLES
#Variables that have been passed by the user
INPUT_FOLDER=$1
INPUT_FILE=$2
PROCESSED_FOLDER=$3
OUTPUT_FILE=$4
ROOT=$5
#########


mkdir -p $PROCESSED_FOLDER	#create folder that will contain all output files


# this first loop goes through the csv line by line and cleans+ortho's each file noted there, already grouping files within the folders that will create large corpora
cat $INPUT_FILE | while read line; do
  OUT_GROUP=`echo $line | awk -F "," '{ print $1}'`
  CHAFILE=`echo $line | awk -F "," '{ print $2}'`
  SELFILE=`echo $line | awk -F "," '{ print $3}'`"-inc.txt"
  ORTHO=`echo $line | awk -F "," '{ print $3}'`"-ort.txt"

echo "finding out who's a speaker in $INPUT_FOLDER$CHAFILE"

	    IncludedParts=`tr '\015' '\n' < $INPUT_FOLDER$CHAFILE | #for each file
		grep "@ID" |      #take only @ID lines of the file
		awk -F "|" '{ print $3, $8 }' | #let through only 3-letter code and role
        grep -v 'Child\|CHI\|Sister\|Brother\|Cousin\|Boy\|Girl\|Unidentified\|Sibling\|Target\|Non_Hum\|Play' | #remove all the children and non-human participants to leave only adults
        awk '{ print $1 }' | #print out the first item, which is the 3 letter code for those adults
		tr "\n" "%" | # put them all in the same line
		sed "s/^/*/g" | #add an asterisk at the beginning
		sed "s/%/\\\\\|*/g" | #add a pipe between every two
		sed "s/\\\\\|.$//" ` #remove the pipe* next to the end of line & close the text call

		./${ROOT}database_creation/scripts/cha2sel_withinputParticipants.sh $INPUT_FOLDER$CHAFILE $SELFILE $PROCESSED_FOLDER$OUT_GROUP $IncludedParts

		./${ROOT}scripts/selcha2clean.sh $PROCESSED_FOLDER$OUT_GROUP$SELFILE $PROCESSED_FOLDER$OUT_GROUP$ORTHO 
		./${ROOT}scripts/extraclean.sh $PROCESSED_FOLDER$OUT_GROUP$ORTHO 

done 


#This second loop goes through the large corpora folders (e.g. Bates20) and create the ortholines that collapse across several children, carefully storing the average age of the megachild included for use during analyses


#for thisfolder in $PROCESSED_FOLDER/*; do
	
#done
