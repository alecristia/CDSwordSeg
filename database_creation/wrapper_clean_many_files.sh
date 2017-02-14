#Wrapper written by Xuan Nga Cao to clean up a large number of
#talkbank+childes corpora, one transcript at a time

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
PATH_TO_SCRIPTS="/home/lscpuser/Documents/CDSwordSeg/database_creation"	#path to the database_creation folder - E.g. PATH_TO_SCRIPTS="/home/xcao/cao/projects/ANR_Alex/CDSwordSeg/database_creation/"

INPUT_CORPUS="/home/lscpuser/Documents/lscp-ciipme-gh/transcripciones" #where you have put the talkbank corpora to be analyzedE.g. INPUT_CORPUS="/home/xcao/cao/projects/ANR_Alex/Childes_Eng-NA"

#the following will be created
CHA_FOLDER="/home/lscpuser/Documents/lscp-ciipme-gh/transcripciones/" #we will make a copy of all cha files that are considered and put them here E.g. CHA_FOLDER="/home/xcao/cao/projects/ANR_Alex/INPUT_all_cha/"- NOTICE THE / AT THE END OF THE NAME

RES_FOLDER="/home/lscpuser/Documents/lscp-ciipme-gh/transcripciones/"	#this is where we will put the processed versions of the transcripts E.g. RES_FOLDER="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/" - NOTICE THE / AT THE END OF THE NAME


INPUT_FILES="/home/lscpuser/Documents/lscp-ciipme-gh/transcripciones/childes_info.txt" #E.g INPUT_FILES="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/childes_info.txt"
OUTPUT_FILE2="/home/lscpuser/Documents/lscp-ciipme-gh/transcripciones/processed_files;txt" #E.g. OUTPUT_FILE2="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/processed_files.txt"


APPEND1="_cha" #E.g. APPEND1="_cha"
APPEND2="_res" #E.g. APPEND2="_res"
APPEND3="_cds" #E.g. APPEND3="_cds"



#This part of the script does not need to be modified

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
		#Notice there is a subselection - only docs with 1 adult are processed
		NADULTS=`grep "@ID" < $f | grep -v -i 'Sibl.+\|Broth.+\|Sist.+\|Target_.+\|Child\|To.+\|Environ.+\|Cousin\|Non_Hum.+\|Play.+' | wc -l`
		if [ $NADULTS == 1 ];  then
			if [ $NADULTS == 1 ];  then
			SUBCORPUS_OUT_LEVEL2=$SUBCORPUS_OUT$(basename "$f" .cha)$APPEND3/
			mkdir -p $SUBCORPUS_OUT_LEVEL2 #get filename and create folder with that name+APPEND3 - E.g. "alice1_cds" (will contain all output files for transcript Alice1 in the Bernstein corpus)
			cd $PATH_TO_SCRIPTS	#move to folder with the 2 scripts and run them with the correct parameters

			SELFILE=$(basename "$f" .cha)"-includedlines.txt"
			bash ./scripts/cha2sel.sh $f $SELFILE $SUBCORPUS_OUT_LEVEL2

			ORTHO=$(basename "$f" .cha)"-ortholines.txt"
			bash ./scripts/selcha2clean.sh $SELFILE $ORTHO $SUBCORPUS_OUT_LEVEL2

			echo "processed $f" >> $OUTPUT_FILE2
		fi
	fi
done

cd $RES_FOLDER
find . -type d -empty -delete #remove empty folders for non-processed corpora
echo "done removing empty folders"
done
