#Wrapper written by Xuan Nga Cao to clean up a large number of talkbank+childes corpora, one transcript at a time

# Adapt the following variables, being careful to provide absolute paths
PATH_TO_SCRIPTS="/home/xcao/cao/projects/ANR_Alex/CDSwordSeg/database_creation/"	#path to the 2 clean-up scripts: chaCleanUp_human.text & cleanCha2phono_human.text
INPUT_CORPUS="/home/xcao/cao/projects/ANR_Alex/Childes_Eng-NA"	#path to the root directory containing all the corpora
CHA_FOLDER="/home/xcao/cao/projects/ANR_Alex/INPUT_all_cha/"	#name and path to folder that will contain all CHA files - this folder will be created when running the script
RES_FOLDER="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/" #name and path to folder that will contain all output files - this folder will be created when running the script
OUTPUT_FILE="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/childes_info.csv" #path and name for file containing the basic info about the corpora"
OUTPUT_FILE2="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/processed_files.txt" #path and name for file containing list of processed file"
APPEND1="_cha"	#whatever you would like to be appended to the corpus folder that will store all cha files
APPEND2="_res"	#whatever you would like to be appended to the corpus folder that will store all output files
APPEND3="_cds"	#whatever you would like to be appended to all output files when they have been created
LANGUAGE="english"	#right now, only options are qom, english -- NOTICE, IN SMALL CAPS


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
			bash ./chaFileCleanUp_human.text $f $SUBCORPUS_OUT_LEVEL2 $LANGUAGE
			echo "processed file $f" >> $OUTPUT_FILE2
			bash ./cleanCha2phono_human.text $KEYNAME $SUBCORPUS_OUT_LEVEL2 $LANGUAGE
		fi
	done
done
cd $RES_FOLDER
find . -type d -empty -delete #remove empty folders for non-processed corpora
echo "done removing empty folders"

