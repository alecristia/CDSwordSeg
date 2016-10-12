#Wrapper written by Xuan Nga Cao to clean up a large number of
#talkbank+childes corpora, one transcript at a time
# EDITED BY ALEX CRISTIA

# The script takes one parent directory with any level of embedding,
# for instance one root folder and sub-folders containing the
# different corpora, each of which contains one transcript per child
# or recording session. For the root folder, it will generate a folder
# bearing the root folder name and containing all the output files
# relative to that root and all the corpora included in it. It
# generates 2 files: one with basic info about the corpus: corpus
# path, filename, child's age, number of speakers, identity of
# speakers, number of adults. The second file will list the processed
# files.

# Adapt the following variables, being careful to provide absolute paths
PATH_TO_SCRIPTS="/Users/acristia/Documents/CDSWordSeg/database_creation"	#path to the database_creation folder - E.g. PATH_TO_SCRIPTS="/home/xcao/cao/projects/ANR_Alex/CDSwordSeg/database_creation/"

INPUT_CORPUS="/Users/acristia/Documents/test/" #where you have put the talkbank corpora to be analyzedE.g. INPUT_CORPUS="/home/xcao/cao/projects/ANR_Alex/Childes_Eng-NA"

#the following will be created
CHA_FOLDER="/Users/acristia/Documents/processed_corpora/nfrchildes2yo_cha/" #we will make a copy of all cha files that are considered and put them here E.g. CHA_FOLDER="/home/xcao/cao/projects/ANR_Alex/INPUT_all_cha/"- NOTICE THE / AT THE END OF THE NAME

RES_FOLDER="/Users/acristia/Documents/processed_corpora/nfrchildes2yo_res/"	#this is where we will put the processed versions of the transcripts E.g. RES_FOLDER="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/" - NOTICE THE / AT THE END OF THE NAME


INPUT_FILES="/Users/acristia/Documents/processed_corpora/nfrchildes2yo_info.txt" #E.g INPUT_FILES="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/childes_info.txt"
OUTPUT_FILE2="/Users/acristia/Documents/processed_corpora/nfrchildes2yo_processedFiles.txt" #E.g. OUTPUT_FILE2="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/processed_files.txt"


APPEND1="cha" #whatever you would like to be appended to the corpus folder that will store all cha files E.g. APPEND1="_cha"
APPEND2="_res" #whatever you would like to be appended to the corpus folder that will store all output files E.g. APPEND2="_res"
APPEND3="_cds" #whatever you would like to be appended to all output files when they have been created E.g. APPEND3="_cds"





mkdir -p $CHA_FOLDER	#create folder that will contain all CHA files
mkdir -p $RES_FOLDER	#create folder that will contain all output files
python $PATH_TO_SCRIPTS/scripts/extract_childes_info.py $INPUT_CORPUS $INPUT_FILES
echo "done extracting info from corpora"


for CORPUSFOLDER in $INPUT_CORPUS/*/; do	#loop through all the sub-folders (1 level down)
	cd $CORPUSFOLDER
	SUBCORPUS_IN=$CHA_FOLDER$(basename $CORPUSFOLDER)$APPEND1/
	mkdir -p $SUBCORPUS_IN	#get name of corpus and create the folder with that name+APPEND1 - E.g. "Bernstein_cha" (will contain all cha files for Bernstein corpus)
	find $CORPUSFOLDER -iname '*.cha' -type f -exec cp {} $SUBCORPUS_IN \;	#search and copy all cha files to the relevant corpus
	SUBCORPUS_OUT=$RES_FOLDER$(basename $CORPUSFOLDER)$APPEND2/
	mkdir -p $SUBCORPUS_OUT	#get name of corpus and create folder with that name+APPEND2 - E.g. "Bernstein_res" (will contain all output files for Bernstein corpus)
	for f in $SUBCORPUS_IN/*; do	#loop through all cha files

echo "finding out who's a speaker in $f"

	    IncludedParts=`tr '\015' '\n' < $f | #for each file
		iconv -f ISO-8859-1 | #convert the file to deal with multibyte e.g. accented characters
		grep "@ID" |      #take only @ID lines of the file
		sed "s/|/ /g" | # remove the pipe character and transform it in a space , g stand for "do it several times per line"
		sed "s/male//"  | #remove gender male
		sed "s/fe //" | #remove gender female
		sed "s/NS.//" | #remove socioeconomic status
		sed "s/[ ;.][0-9]*/ /g" | #remove age
		tr -d ";" | # delete ; characters in age
		tr -d "." | #delete . characters in age
		tr -s " " | #delete space
		awk '{ print $4, $5 }' | # show me only the columns that gives you an info about the person speaking cf. BRO & Brother
		grep -v 'Child\|Sister\|Brother\|Cousin\|Boy\|Girl\|Unidentified\|Sibl.+\|Target_.+\|Non_Hum.+\|Play.+' | #remove all the children and non-human participants to leave only adults
		awk '{ print $1 }' | #print out the first item, which is the 3 letter code for those adults
		tr "\n" "%" | # put them all in the same line
		sed "s/%/\\\|/g" | #add a pipe between every two
		sed "s/\\\|$//" ` #remove the pipe next to the end of line
		 
echo "including $IncludedParts"

		SUBCORPUS_OUT_LEVEL2=$SUBCORPUS_OUT$(basename "$f" .cha)$APPEND3/
		mkdir -p $SUBCORPUS_OUT_LEVEL2 #get filename and create folder with that name+APPEND3 - E.g. "alice1_cds" (will contain all output files for transcript Alice1 in the Bernstein corpus)
		cd $PATH_TO_SCRIPTS	#move to folder with the 2 scripts and run them with the correct parameters

		SELFILE=$(basename "$f" .cha)"-includedlines.txt"
		bash ./scripts/cha2sel_withinputParticipants.sh $f $SELFILE $SUBCORPUS_OUT_LEVEL2 $IncludedParts

		ORTHO=$(basename "$f" .cha)"-ortholines.txt"
		bash ./scripts/selcha2clean.sh $SELFILE $ORTHO $SUBCORPUS_OUT_LEVEL2

		echo "processed $f" >> $OUTPUT_FILE2

	done
done
cd $RES_FOLDER
find . -type d -empty -delete #remove empty folders for non-processed corpora
echo "done removing empty folders"
