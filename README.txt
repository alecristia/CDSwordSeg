Instructions for text analyses
For questions contact Alex Cristia alecristia@gmail.com

********************** PART 1 ******************
GOAL: generate a phonological version

1. Adapt the following variables, being careful to provide absolute paths. Then copy and paste these 4 lines onto a terminal window


KEYNAME="bernsteinads" #pick a nice name for your phonological corpus, because this keyname will be used for every output file!
CHAFOLDER="/fhgfs/bootphon/scratch/acristia/data/Interview/" #must exist and contain cha files - NOTICE THE / AT THE END OF THE NAME
RESFOLDER="/fhgfs/bootphon/scratch/acristia/results/res_bernsteinads/"   #will be created and loads of output files will be stored there - NOTICE THE / AT THE END OF THE NAME
LANGUAGE="english" #right now, only options are qom, english -- NOTICE, IN SMALL CAPS


2. Open and adapt if necessary chaCleanUp_human.text inside database_creation, particularly the two parts that are marked with "Attention" - this concerns data selection and clean up of common errors. 



3. Run the scripts by navigating to the folder and launching them:
cd /YOUR_ABSOLUTE_PATH_GOES_HERE/database_creation/
./chaCleanUp_human.text $KEYNAME $CHAFOLDER $RESFOLDER $LANGUAGE
./cleanCha2phono_human.text $KEYNAME $RESFOLDER $LANGUAGE

NOTES:
- YOUR_ABSOLUTE_PATH_GOES_HERE is the absolute path leading to your local copy of database_creation
- If this doesn't run at all (you get a "permission denied" error), it probably means that you haven't rendered the scripts executable. Do so by typing:
chmod +x chaCleanUp_human.text
chmod +x cleanCha2phono_human.text

- You might see an error "couldn't remove folder" or "No such file or directory" -- don't worry about that error, it's just that I make sure to remove preceding versions of the folder.


4. Normally, this will result in a folder being created, with several files inside:
The most interesting to you probably are:
-gold: the corpus in phonological representation
-includedlines: orthographic representation of all the lines in the same order that they appear in the original cha file and in all the others; good to use if trying to match them up again
-ADD-sorted: this contains the list of words that were not found in the dictionary and therefore could not be converted into phonological form. It is easy to add new words to the dictionary and it might be a good idea, particularly if you are missing words that are very frequent. See below for the instructions.

**************	ALTERNATIVE: MULTICORPORA COMPARISON	***************
GOAL: Preprocess cha files -- this we did for a project comparing across registers
The script takes one parent directory with any level of embedding (A typical directory structure would be one root folder and sub-folders containing the different corpora. The root folder could be CDS or ADS). For each transcript, it will generate a folder bearing the transcript name and it will contain all the output files relative to that transcript.
The script also genarates 2 files: one with basic info about the corpus: corpus path, filename, child's age, number of speakers, identity of speakers, number of adults. The second file will list the processed files.

1. Open "clean_corpus.sh" and change the variables as indicated. Save the file and run bash script a terminal window by typing: "bash clean_corpus.sh"

2. Alternatively, if you don't want to run the script, you can do the following:
	a) Adapt the following variables, being careful to provide absolute paths. Then copy and paste these lines onto a terminal window
PATH_TO_SCRIPTS="YOUR_ABSOLUTE_PATH_TO_SCRIPTS"	#path to chaCleanUp_human.text & cleanCha2phono_human.text - E.g. PATH_TO_SCRIPTS="/home/xcao/cao/projects/ANR_Alex/CDSwordSeg/database_creation/"
INPUT_CORPUS="YOUR_ABSOLUTE_PATH_TO_ROOT_DIRECTORY_WITH_ALL_CORPORA" #E.g. INPUT_CORPUS="/home/xcao/cao/projects/ANR_Alex/Childes_Eng-NA"
CHA_FOLDER="YOUR_ABSOLUTE_PATH_TO_WHERE_ALL_CHA_FILES_WILL_BE_STORED" #E.g. CHA_FOLDER="/home/xcao/cao/projects/ANR_Alex/INPUT_all_cha/"- NOTICE THE / AT THE END OF THE NAME
RESFOLDER="YOUR_ABSOLUTE_PATH_TO_WHERE_ALL_OUTPUT_FILES_WILL_BE_STORED"	#E.g. RES_FOLDER="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/" - NOTICE THE / AT THE END OF THE NAME
OUTPUT_FILE="YOUR_ABSOLUTE_PATH_TO_WHERE_INFO_FILE_ABOUT_CORPORA_WILL_BE_STORED" #E.g OUTPUT_FILE="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/childes_info.txt"
OUTPUT_FILE2="YOUR_ABSOLUTE_PATH_TO_LIST_OF_PROCESSED_FILES" #E.g. OUTPUT_FILE2="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/processed_files.txt"
APPEND1="whatever you would like to be appended to the corpus folder that will store all cha files" #E.g. APPEND1="_cha"
APPEND2="whatever you would like to be appended to the corpus folder that will store all output files" #E.g. APPEND2="_res"
APPEND3="whatever you would like to be appended to all output files when they have been created" #E.g. APPEND3="_cds"
LANGUAGE="english" #right now, only options are qom, english -- NOTICE, IN SMALL CAPS

	b) Open and adapt if necessary chaFileCleanUp_human.text, particularly the two parts that are marked with "Attention" - this concerns data selection and clean up of common errors.

	c) Copy and paste these lines onto a terminal window. This will run the clean-up scripts and create the output files:
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


**************	ALTERNATIVE: BUCKEYE INPUT	***************

1. Adapt the following variables, being careful to provide absolute paths. Then copy and paste these 4 lines onto a terminal window


KEYNAME="buckeye_allbreaks" #pick a nice name for your phonological corpus, because this keyname will be used for every output file!
RAWFOLDER="/Users/caofrance/Documents/databases/Buckeyebootphon/" #must exist and contain cha files - NOTICE THE / AT THE END OF THE NAME
RESFOLDER="/Users/caofrance/Documents/tests/res_buckeye_allbreaks/"   #will be created and loads of output files will be stored there - NOTICE THE / AT THE END OF THE NAME
LANGUAGE="english" #right now, only options is english -- NOTICE, IN SMALL CAPS


2. Open and adapt if necessary fromBuckeye2clean_human.text, particularly the part that is marked with "Attention" - this concerns boundary decisions.


3. Run the scripts by navigating to the folder and launching them:
cd /YOUR_ABSOLUTE_PATH_GOES_HERE/database_creation/
./fromBuckeye2clean_human.text $KEYNAME $RAWFOLDER $RESFOLDER $LANGUAGE
./cleanCha2phono_human.text $KEYNAME $RESFOLDER $LANGUAGE


**************SUBROUTINE: ADDING WORDS TO THE DICTIONARY***************
1. Before starting, check whether there is a newer version of the dictionary on our shared osf site.
Download the dict-Brent.txt from osf.io/vg4wx
Open it and check the first line

Separately, open your dict-Brent and check the first line:
database_creation/update_dictionary/data/dict-Brent.txt

If the one on the website is newer, then put it in /YOUR_ABSOLUTE_PATH_GOES_HERE/database_creation/update_dictionary/data/ (removing/replacing the older one).

2. Now open /YOUR_ABSOLUTE_PATH_GOES_HERE/database_creation/update_dictionary/data/dict-Brent.txt and update the first line with your name and date (YEAR-MONTH-DAY is ideal).

3. Open the file containing the list of words that you need to add (ADD-SORTED - see step 4 above).

4. Now starting from the top, add the words to the dictionary by copy+pasting similar words (or typing in, in which case be really careful with the format by looking at other words with a similar pronunciation). I usually stop at words that have a frequency of 1.

5. In a terminal window, navigate to the scripts directory in mother folder & run the three scripts there exactly as follows:
$ cd /YOUR_ABSOLUTE_PATH_GOES_HERE/database_creation/update_dictionary/scripts
$ ./update_dictionary.text

6. This will result in the dictionaries inside /YOUR_ABSOLUTE_PATH_GOES_HERE/database_creation/fromCHAtoSND/input being updated, so next time that you try to set up a corpus for analysis, these words will be found -- so normally you will re-do step 3 in Part 1 above.

IMPORTANT!!! Please email me your new version of the dict-Brent.txt file at alecristia@gmail.com so I can post it.

********************** PART 2 ******************
GOAL: segmenting a corpus

1. In a terminal window, navigate to the algoComp/ subfolder

2. If you didn't do it before (PART 1), adapt the following variables
and copy-paste them into a terminal 

ABSPATH="`pwd`/"
KEYNAME="bernsteinads"
RESFOLDER="/Users/caofrance/Documents/tests/res_bernsteinads/"

3. Run segmentation as follows:

Follow one the 3.1 or 3.2 alternatives

3.1. Compute it on your machine

    ./segment_one_corpus.sh $ABSPATH $KEYNAME $RESFOLDER  
#AG isn't working anymore on my mac - to be checked!
#other than that, ALL OK 2015-10-14


3.2. Compute it on the cluster

TODO These part need to be tested/reviewed

If you want to run the segmentation process on a cluster managed by
Sun Grid Engine ('qsub' command needed), provide a 4th argument to the
./segment_one_corpus.sh script. Only the absence/presence of the 4th
argument matters, not its content. See pipeline/clusterize.sh for more
details.

    ./segment_one_corpus.sh $ABSPATH $KEYNAME $RESFOLDER
#AG not run yet because checking problem in the macbook pro bootphon
#of the other algos,
#only ngrams seems to work & produce a non-empty gold -- is it a problem with python??



4. This will result in many files being added to your results directory
(specified in step 2 of this Part 2). The most interesting one
might be the one called _<YOUR KEYNAME>-cfgold.txt, which looks like
this:

algo token_f-score token_precision token_recall boundary_f-score boundary_precision boundary_recall
dibs 0.2353 0.3118 0.189 0.4861 0.6915 0.3748
tpABS 0.7743 0.7603 0.7888 0.8994 0.8806 0.919
tpREL 0.2263 0.3274 0.1729 0.5861 0.9426 0.4253
ag 0.7242 0.6866 0.766 0.8792 0.8271 0.9384


If you want to see how each algorithm segmented the corpus, you can
look at the files ending with -cfgold. (The true segmentation is in
the file ending with -gold, as explained in 6b of Part 1).

If you're interested in the highest frequency words each algorithm
found, they are in the files ending with freq-top (top 10k words).

******IMPORTANT****

If you want to take your results home, please bear in mind that
several of these files contain substantial parts of the corpus, so be
careful (DON'T take the whole folder). A fast way to clean up is, in a
terminal window (to be on the safe side, I do it on the thumb drive,
so that the originals are kept in this computer):

    cd <the mother folder of the res_folders>
    mkdir cfgold_results
    cp res_*/_*gold.txt results/
    rm res_*/*unicode*.txt
    rm res_*/*klatt*.txt
    rm res_*/*all.txt
    rm res_*/*output.txt
    rm res_*/*lines.txt
    rm res_*/*gold.txt


**** Troubleshooting:

- If you get an error:

    ## py-cky.h:1014: In inside() Error: earley parse failed, terminals
    that probably means you used a wrong letter in a dictionary entry.

    Focus on the end of the error:
    ## py-cky.h:1014: In inside() Error: earley parse failed, terminals = (s I s i l j x)

This means that one of the letters in "s I s i l j x" is wrong.
Compare them against the list of letters ("phonemes") with the ones listed in:
/YOUR_ABSOLUTE_PATH_GOES_HERE/algoComp201507/algos/AG/grammars/Colloq0_enKlatt.lt

namely:
d	e	f	g	h	i	k	l	m	n	o	p	r	@	s	t	u	C	v	D	E	w	x	G	y	z	I	J	O	R	S	T	U	W	Y	Z	^	a	b	c	|	L	M	N	X


There is no "j" in this list -- so that means there is at least one
incorrect entry with j, in this case "s I s i l j x" or rather
"sIsiljx".

A longer route: Do
$ cd /YOUR_ABSOLUTE_PATH_GOES_HERE/algoComp201507/algos/AG/input
$ tr -d '/' < input.ylt |sed '/^$/d' | sort | uniq -c | awk '{print $2" "$1}' | sort -n -r > ~/Desktop/letter-count.txt

This will generate a file called letter-count.txt on your
Desktop. Open it and paste the contents onto LibreOffice Calc

Once you find the guilty letter, go to the dictionary
/YOUR_ABSOLUTE_PATH_GOES_HERE/database_creation/update_dictionary/data/dict-Brent.txt
Do a search for it, and change it to the appropriate letter.

Finally, regenerate the dictionary following the instructions in
SUBROUTINE: ADDING WORDS TO THE DICTIONARY, step 4+

- If you get an error

    ## py-cfg.cc:256: In gibbs_estimate() Error in py-cfg::gibbs_estimate(), tprob = 0, trains[XX]

This means that one of your phrases is too long. You might need to use
a different version of adaptor grammar -- ask Alex about it.
