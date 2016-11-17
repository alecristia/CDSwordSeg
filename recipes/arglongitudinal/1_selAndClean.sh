#Wrapper written by Alex Cristia to process the Audio1 (first 20 kids) from the Arg longitudinal corpus



# Adapt the following variables, being careful to provide absolute paths
PATH_TO_SCRIPTS="/fhgfs/bootphon/scratch/acristia/CDSwordSeg/database_creation"	#path to the database_creation folder - E.g. PATH_TO_SCRIPTS="/home/xcao/cao/projects/ANR_Alex/CDSwordSeg/database_creation/"


INPUT_CORPUS="/fhgfs/bootphon/scratch/acristia/lscp-ciipme-gh/transcripciones/longi_audio" #where you have put the talkbank corpora to be analyzedE.g. INPUT_CORPUS="/home/xcao/cao/projects/ANR_Alex/Childes_Eng-NA"

RES_FOLDER="/fhgfs/bootphon/scratch/acristia/processed_corpora/arglongitudinal_res/"	#this is where we will put the processed versions of the transcripts E.g. RES_FOLDER="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/" - NOTICE THE / AT THE END OF THE NAME

INPUT_FILES=`${RES_FOLDER}info.txt` #E.g INPUT_FILES="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/childes_info.txt"

OUTPUT_FILE2=`${RES_FOLDER}processedFiles.txt` #E.g. OUTPUT_FILE2="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/processed_files.txt"

mkdir -p $RES_FOLDER	#create folder that will contain all output files
python $PATH_TO_SCRIPTS/scripts/extract_childes_info.py $INPUT_CORPUS $INPUT_FILES
echo "done extracting info from corpora"


for CORPUSFOLDER in $INPUT_CORPUS/; do	#loop through all the sub-folders (1 level down)
	for f in $CORPUSFOLDER/*.cha; do	#loop through all cha files

echo "finding out who's a speaker in $f"

	    IncludedParts=`tr '\015' '\n' < $f | #for each file
		iconv -f ISO-8859-1 | #convert the file to deal with multibyte e.g. accented characters ###!!! try -t
		grep "@ID" |      #take only @ID lines of the file
		awk -F "|" '{ print $3, $8 }' | #let through only 3-letter code and role
        grep -v 'Child\|Sister\|Brother\|Cousin\|Boy\|Girl\|Unidentified\|Sibling\|Target\|Non_Hum\|Play' | #remove all the children and non-human participants to leave only adults
        awk '{ print $1 }' | #print out the first item, which is the 3 letter code for those adults
		tr "\n" "%" | # put them all in the same line
		sed "s/^/*/g" | #add an asterisk at the beginning
		sed "s/%/\\\\\|*/g" | #add a pipe between every two
		sed "s/\\\\\|.$//" ` #remove the pipe* next to the end of line & close the text call

		cd $PATH_TO_SCRIPTS	#move to folder with the 2 scripts and run them with the correct parameters

		SELFILE=$(basename "$f" .cha)"-includedlines.txt"
		bash ./scripts/cha2sel_withinputParticipants.sh $f $SELFILE $RES_FOLDER $IncludedParts

		mkdir -p ${RES_FOLDER}CDS	#create folder that will contain all output files
              grep '\[+ CHI\]' < ${RES_FOLDER}$SELFILE > ${RES_FOLDER}CDS/$SELFILE  # separa lineas de CDS.


#		mkdir -p ${RES_FOLDER}ADS	#create folder that will contain all output files
#		ADS=grep -v [+CHILD]|[+OCH] < $IncludedParts # separa lineas de ADS. #homework

#		ORTHO=$(basename "$f" .cha)"-ortholines.txt"
#		./scripts/selcha2clean.sh $SELFILE $ORTHO ${RES_FOLDER}CDS/
#		bash ./scripts/selcha2clean.sh $ADS $ORTHO $RES_FOLDER

		echo "processed $f" >> $OUTPUT_FILE2

	done
done
cd $RES_FOLDER
find . -type d -empty -delete #remove empty folders for non-processed corpora
echo "done removing empty folders"
