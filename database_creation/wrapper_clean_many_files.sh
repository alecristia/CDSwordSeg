#Wrapper written by Xuan Nga Cao to clean up a large number of talkbank+childes corpora, one transcript at a time

# The script takes one parent directory with any level of embedding, for instance one root folder and sub-folders containing the different corpora, each of which contains one transcript per child or recording session. For the root folder, it will generate a folder bearing the root folder name and containing all the output files relative to that root and all the corpora included in it. It generates 2 files: one with basic info about the corpus: corpus path, filename, child's age, number of speakers, identity of speakers, number of adults. The second file will list the processed files.

# Adapt the following variables, being careful to provide absolute paths
PATH_TO_SCRIPTS="YOUR_ABSOLUTE_PATH_TO_SCRIPTS"	#path to chaCleanUp_human.text & cleanCha2phono_human.text - E.g. PATH_TO_SCRIPTS="/home/xcao/cao/projects/ANR_Alex/CDSwordSeg/database_creation/"
INPUT_CORPUS="YOUR_ABSOLUTE_PATH_TO_ROOT_DIRECTORY_WITH_ALL_CORPORA" #E.g. INPUT_CORPUS="/home/xcao/cao/projects/ANR_Alex/Childes_Eng-NA"
CHA_FOLDER="YOUR_ABSOLUTE_PATH_TO_WHERE_ALL_CHA_FILES_WILL_BE_STORED" #E.g. CHA_FOLDER="/home/xcao/cao/projects/ANR_Alex/INPUT_all_cha/"- NOTICE THE / AT THE END OF THE NAME
RESFOLDER="YOUR_ABSOLUTE_PATH_TO_WHERE_ALL_OUTPUT_FILES_WILL_BE_STORED"	#E.g. RES_FOLDER="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/" - NOTICE THE / AT THE END OF THE NAME
OUTPUT_FILE="YOUR_ABSOLUTE_PATH_TO_WHERE_INFO_FILE_ABOUT_CORPORA_WILL_BE_STORED" #E.g OUTPUT_FILE="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/childes_info.txt"
OUTPUT_FILE2="YOUR_ABSOLUTE_PATH_TO_LIST_OF_PROCESSED_FILES" #E.g. OUTPUT_FILE2="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/processed_files.txt"
APPEND1="whatever you would like to be appended to the corpus folder that will store all cha files" #E.g. APPEND1="_cha"
APPEND2="whatever you would like to be appended to the corpus folder that will store all output files" #E.g. APPEND2="_res"
APPEND3="whatever you would like to be appended to all output files when they have been created" #E.g. APPEND3="_cds"
LANGUAGE="english"   #CURRENT options qom, english -- notice small caps



#This part of the script does not need to be modified

mkdir -p $CHA_FOLDER	#create folder that will contain all CHA files
mkdir -p $RES_FOLDER	#create folder that will contain all output files
python $PATH_TO_SCRIPTS/otherScripts/extract_childes_info.py $INPUT_CORPUS $OUTPUT_FILE
echo "done extracting info from corpora"
for CORPUSFOLDER in $INPUT_CORPUS/*/; do	#loop through all the sub-folders (1 level down)
	cd $CORPUSFOLDER
	SUBCORPUS_IN=$CHA_FOLDER$(basename $CORPUSFOLDER)$APPEND1/	
	mkdir -p $SUBCORPUS_IN	#get name of corpus and create the folder with that name+APPEND1 - E.g. "Bernstein_cha" (will contain all cha files for Bernstein corpus)
	find $CORPUSFOLDER -iname '*.cha' -type f -exec cp {} $SUBCORPUS_IN \;	#search and copy all cha files to the relevant corpus
	SUBCORPUS_OUT=$RES_FOLDER$(basename $CORPUSFOLDER)$APPEND2/	
	mkdir -p $SUBCORPUS_OUT	#get name of corpus and create folder with that name+APPEND2 - E.g. "Bernstein_res" (will contain all output files for Bernstein corpus)
	for f in $SUBCORPUS_IN/*; do	#loop through all cha files
		#Notice there is a subselection - only docs with 1 adult are processed
		NADULTS=`grep "@ID" < $f | grep -v -i 'Sibl.+\|Broth.+\|Sist.+\|Target_.+\|Child\|To.+\|Environ.+\|Cousin\|Non_Hum.+\|Play.+' | wc -l`
		if [ $NADULTS == 1 ];  then
			SUBCORPUS_OUT_LEVEL2=$SUBCORPUS_OUT$(basename "$f" .cha)$APPEND3/
			mkdir -p $SUBCORPUS_OUT_LEVEL2 #get filename and create folder with that name+APPEND3 - E.g. "alice1_cds" (will contain all output files for transcript Alice1 in the Bernstein corpus)
			KEYNAME=$(basename "$f" .cha)
			cd $PATH_TO_SCRIPTS	#move to folder with the 2 scripts and run them with the correct parameters
			SELFILE=$(basename "$CHAFILE" .cha)"-includedlines.txt"

			bash ./ancillaryScripts/cha2sel.sh $f $SELFILE 

			ORTHO=$(basename "$CHAFILE" .cha)"-ortholines.txt"

			bash ./ancillaryScripts/selcha2clean.sh $SELFILE $ORTHO 
			echo "processed file $f" >> $OUTPUT_FILE2
		fi
	done
done
cd $RES_FOLDER
find . -type d -empty -delete #remove empty folders for non-processed corpora
echo "done removing empty folders"


