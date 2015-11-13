#!/bin/sh

#################### definining parameters ###################
#### DO ADAPT THESE VARIABLES
ABSPTH=""		#Absolute path of the large folder in which we are working, where you have placed all your key subfolders
#/Users/caofrance/Documents/Dropbox/ANR_MechELex/algos/AG/

#Folders - check that they are there
RESFOLDER=$1		#location of the folder that will come to hold the results, this will almost certainly change
DBFOLDER=$1		#location of the folder containing the database, this will almost certainly change


#INPUT Files - check that they are there
YLTFILE=$DBFOLDER"input.ylt"	#location of the file containing the database in ylt format, this will almost certainly change
GOLDFILE=$DBFOLDER"input.gold"	#location of the file containing the database in gold format, this will almost certainly change
GRAMMARFILE="grammars/Colloq0_enFestival.lt" 		#location of the file holding the grammar, this will almost certainly change

#OUTPUT files - they won't be there, not created yet, but check names to see if they make sense to you or you'd like them to be called differently
RUNFILE="run"			#beginning of the name for a run file, this will probably not change (but you can change it if you want to)
OUTFILE="ag-output"		#beginning of the name for an output file, this will probably not change (but you can change it if you want to)

LEVEL="Colloc0"

INMBRFILE="-${LEVEL}.seg"		#ending of the files to be used as input for the minimum bayes risk calculation, choose the level that interests you - here, the word segmentation
OUTMBRFILE="_mbr-${LEVEL}.seg"	#ending of the files to be used as OUTPUT for the minimum bayes risk calculation, choose the level that interests you - here, the word segmentation

EVALFILE="eval_word.txt"	#name of the file that will hold the evaluation results

#### HAVE A LOOK BUT PROBABLY NOT CHANGE

PYCFG="py-cfg-new/py-cfg"	#Folder containing the py cfg routines, typically this will not change
SCRIPTFOLDER="scripts/"				#location of the folder containing the key scripts that you will edit (reduce_prs.py, etc.)

TMPFILE="tmp"			#beginning of the name for a temporary file, typically this will not change

#ANALYSIS Files - check that they are there
REDUCEPRSFILE=$SCRIPTFOLDER"reduce_prs.py"	#file containing the python script to reduce the parses
TREESFILE=$SCRIPTFOLDER"trees-words.py"	#file containing the python script to segment
MBRPYFILE=$SCRIPTFOLDER"mbr.py"		#file containing the python script to calculate minimum bayes risk
EVALPY=$SCRIPTFOLDER"eval.py"		#file containing the python script to evaluate the segmentation

NITER=10	#Number of iterations per parse, normally 2000 (except for debugging-10)
NRED=0		#number thrown out when reducing the parse, normally 100 (except for debugging-0)

###########################
# a) Create the parse tree files

for i in {0..7}; do 
	$ABSPTH$PYCFG -n $NITER -G $ABSPTH$RESFOLDER$RUNFILE$i.wlt -A $ABSPTH$RESFOLDER$TMPFILE$i.prs -F $ABSPTH$RESFOLDER$TMPFILE$i.trace -E -r $RANDOM -d 101 -a 0.0001 -b 10000 -e 1 -f 1 -g 100 -h 0.01 -R -1 -P -x 10 -u $ABSPTH$YLTFILE -U cat > $ABSPTH$RESFOLDER$OUTFILE$i.prs $ABSPTH$GRAMMARFILE < $ABSPTH$YLTFILE &
	pid[${i}]=$!
done

for pid in ${pid[*]}; do
	wait $pid
done



###########################
# b) Reduce the parse trees
python $ABSPTH$REDUCEPRSFILE -n $NRED $ABSPTH$RESFOLDER$OUTFILE[0-9].prs 	# (-n  = number of parses to be removed / br-phono*: all the parse tree files to be applied - e.g. 0 through 7)


###########################
# c) Segmentation

for i in {0..7}; do python $ABSPTH$TREESFILE -c $LEVEL < $ABSPTH$RESFOLDER$OUTFILE$i-last.prs > $ABSPTH$RESFOLDER$OUTFILE$i$INMBRFILE; done

###########################
# d) Extract the most frequent segmentation in the 800 sample segmentations (minimum bayes risk) and to be used in the evaluation

python $ABSPTH$MBRPYFILE $ABSPTH$RESFOLDER$OUTFILE*$INMBRFILE > $ABSPTH$RESFOLDER$OUTMBRFILE


###########################
# e1) Evaluation of the segmentation - individual

python $ABSPTH$EVALPY -g $ABSPTH$GOLDFILE < $ABSPTH$RESFOLDER$OUTMBRFILE > $ABSPTH$RESFOLDER$EVALFILE

