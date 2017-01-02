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

cat $INPUT_FILE | while read line; do
  OUT_GROUP=`echo $line | awk -F "," '{ print $1}'`
  CHAFILE=`echo $line | awk -F "," '{ print $2}'`
  SELFILE=`echo $line | awk -F "," '{ print $2}'`

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

		SELFILE=$(basename "$f" .cha)"-includedlines.txt"
		./${ROOT}database_creation/scripts/cha2sel_withinputParticipants.sh $INPUT_FOLDER$CHAFILE $SELFILE $PROCESSED_FOLDER$OUT_GROUP $IncludedParts


done 


		cd $PATH_TO_SCRIPTS	#move to folder with the 2 scripts and run them with the correct parameters


		mkdir -p $PROCESSED_FOLDER/CDS	#creates folder that will contain all only CDS included files
              	grep '\[+ CHI\]' < $PROCESSED_FOLDER/AS/$SELFILE > $PROCESSED_FOLDER/CDS/$SELFILE  # selects only CDSinput lines.


		mkdir -p $PROCESSED_FOLDER/ADS	#creates folder that will contain only ADS output files
		grep -v '\[+ CHI\]\|\[+ OCH\]\|\[+ utt]' < $PROCESSED_FOLDER/AS/$SELFILE > $PROCESSED_FOLDER/ADS/$SELFILE # selects ADS input lines.

		ORTHO=$(basename "$f" .cha)"-ortholines.txt"
		./scripts/selcha2clean.sh $SELFILE $ORTHO $PROCESSED_FOLDER/CDS/
		bash ./scripts/selcha2clean.sh $SELFILE $ORTHO $PROCESSED_FOLDER/ADS/
		bash ./scripts/selcha2clean.sh $SELFILE $ORTHO $PROCESSED_FOLDER/AS/

		echo "processed $f" >> $OUTPUT_FILE2

		

done

cd $PROCESSED_FOLDER
find . -type d -empty -delete #remove empty folders for non-processed corpora
echo "done removing empty folders"
for j in $PROCESSED_FOLDER/*S; do	#divinding corpus into SESfolders.
	cd $j
	mkdir -p NSB
	mkdir -p NSM
	mv *-nsb-1audio-*lines.txt NSB
	mv *-nsm-1audio-*lines.txt NSM
done
echo "done with ${PROCESSED_FOLDER}"
