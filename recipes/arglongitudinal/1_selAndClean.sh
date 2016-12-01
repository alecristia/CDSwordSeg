#Wrapper written by Alex Cristia and Alvaro Iturralde to process the Audio1 (first 20 kids) from the Arg longitudinal corpus. It creates three clean corpora to work with according to the parametters :1)All Adult Speech  2)Child Directed Speech  3)Adult Directed Speech.



# Adapt the following variables, being careful to provide absolute paths
PATH_TO_SCRIPTS="/home/lscpuser/Documents/CDSwordSeg/database_creation"	#path to the database_creation folder - E.g. PATH_TO_SCRIPTS="/home/xcao/cao/projects/ANR_Alex/CDSwordSeg/database_creation/"

INPUT_CORPUS="/home/lscpuser/Documents/lscp-ciipme-gh/transcripciones/longi_audio1" #where you have put the talkbank corpora to be analyzedE.g. INPUT_CORPUS="/home/xcao/cao/projects/ANR_Alex/Childes_Eng-NA"

RES_FOLDER="/home/lscpuser/Documents/lscp-ciipme-gh/transcripciones/RES_FOLDER"	#this is where we will put the processed versions of the transcripts E.g. RES_FOLDER="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/" - NOTICE THE / AT THE END OF THE NAME


INPUT_FILES="/home/lscpuser/Documents/lscp-ciipme-gh/transcripciones/RES_FOLDER/childes_info.txt" #E.g INPUT_FILES="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/childes_info.txt"

OUTPUT_FILE2="/home/lscpuser/Documents/lscp-ciipme-gh/transcripciones/RES_FOLDER/processed_files.txt" #E.g. OUTPUT_FILE2="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/processed_files.txt"


mkdir -p $RES_FOLDER	#create folder that will contain all output files
python $PATH_TO_SCRIPTS/scripts/extract_childes_info.py $INPUT_CORPUS $INPUT_FILES
echo "done extracting info from corpora"


for f in ${INPUT_CORPUS}/*.cha; do	#loop through all cha files

echo "finding out who's a speaker in $f"

	    IncludedParts=`tr '\015' '\n' < $f | #for each file
		iconv -f ISO-8859-1 | #convert the file to deal with multibyte e.g. accented characters ###!!! try -t
		grep "@ID" |      #take only @ID lines of the file
		awk -F "|" '{ print $3, $8 }' | #let through only 3-letter code and role
        grep -v 'Child\|CHI\|Sister\|Brother\|Cousin\|Boy\|Girl\|Unidentified\|Sibling\|Target\|Non_Hum\|Play' | #remove all the children and non-human participants to leave only adults
        awk '{ print $1 }' | #print out the first item, which is the 3 letter code for those adults
		tr "\n" "%" | # put them all in the same line
		sed "s/^/*/g" | #add an asterisk at the beginning
		sed "s/%/\\\\\|*/g" | #add a pipe between every two
		sed "s/\\\\\|.$//" ` #remove the pipe* next to the end of line & close the text call

		cd $PATH_TO_SCRIPTS	#move to folder with the 2 scripts and run them with the correct parameters

		mkdir -p $RES_FOLDER/AS	#creates folder that will contain all the adult speech of the corpora.
		SELFILE=$(basename "$f" .cha)"-includedlines.txt"
		bash ./scripts/cha2sel_withinputParticipants.sh $f $SELFILE $RES_FOLDER/AS/ $IncludedParts

		mkdir -p $RES_FOLDER/CDS	#creates folder that will contain all only CDS included files
              	grep '\[+ CHI\]' < $RES_FOLDER/AS/$SELFILE > $RES_FOLDER/CDS/$SELFILE  # selects only CDSinput lines.


		mkdir -p $RES_FOLDER/ADS	#creates folder that will contain only ADS output files
		grep -v '\[+ CHI\]\|\[+ OCH\]\|\[+ utt]' < $RES_FOLDER/AS/$SELFILE > $RES_FOLDER/ADS/$SELFILE # selects ADS input lines.

		ORTHO=$(basename "$f" .cha)"-ortholines.txt"
		./scripts/selcha2clean.sh $SELFILE $ORTHO $RES_FOLDER/CDS/
		bash ./scripts/selcha2clean.sh $SELFILE $ORTHO $RES_FOLDER/ADS/
		bash ./scripts/selcha2clean.sh $SELFILE $ORTHO $RES_FOLDER/AS/

		echo "processed $f" >> $OUTPUT_FILE2

done

cd $RES_FOLDER
find . -type d -empty -delete #remove empty folders for non-processed corpora
echo "done removing empty folders"
echo "done with ${RES_FOLDER}"
