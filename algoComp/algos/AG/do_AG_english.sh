#!/usr/bin/env bash

#################### parsing input parameters #####################

# location of the folder that will come to hold the results
RESFOLDER=$1
[[ ! -d $RESFOLDER ]] && echo "$0 : invalid directory $RESFOLDER" && exit 1

# name of the database is $RESFOLDER$KEYNAME-tags.txt
KEYNAME=$2
INPUT=$RESFOLDER$KEYNAME-tags.txt
[[ ! -f $INPUT ]] && echo "$0 : invalid input file $INPUT" && exit 1

# name of the algorithm is either "agU" or "agc3s". This parameter
# defines :
#   GRAMMARFILE = location of the file holding the grammar
#   LEVEL = this is the level that is tested -- colloq0 is supposed to
#     be the word level; in coll0 model because it is the level at
#     which phonemes are combined; in coll3syll it is defined as
#     groups of syllables
ALGO=$3
case $ALGO in
    "agU")
        GRAMMARFILE="grammars/Colloc0_enFestival.lt"
        LEVEL="Colloc0"
        ;;
    "agc3s")
        GRAMMARFILE="grammars/Coll3syllfnc_enFestival.lt"
        LEVEL="Word"
        ;;
    *)
        echo $ALGO is not a valid algo, exiting
        exit 1
        ;;
esac

# Tune AG with normal settings by default, or specify exiplicitly
# "debug" as the 4th parameter. This parameter defines :
#    NITER = number of iterations per parse (2000 or 10)
#    NRED = number thrown out when reducing the parse (100 or 0)
SETUP=$4
if [[ "$SETUP" == "debug" ]]
then
    echo "Setup $ALGO in debug mode"
    NITER=10
    NRED=0
else
    NITER=2000
    NRED=100
fi


#################### definining local variables ###################

# location of the file containing the database in ylt format
YLTFILE=$RESFOLDER"input.ylt"

#OUTPUT files - they won't be there, not created yet, but check names
#to see if they make sense to you or you'd like them to be called
#differently

# beginning of the name for a run file, this will probably not change
# (but you can change it if you want to)
RUNFILE="run"

# beginning of the name for an output file, this will probably not
# change (but you can change it if you want to)
OUTFILE="ag-output"

# ending of the files to be used as input for the minimum bayes risk
# calculation, choose the level that interests you - here, the word
# segmentation
INMBRFILE="-${LEVEL}.seg"

# ending of the files to be used as OUTPUT for the minimum bayes risk
# calculation, choose the level that interests you - here, the word
# segmentation
OUTMBRFILE="_mbr-${LEVEL}.seg"


#### HAVE A LOOK BUT PROBABLY NOT CHANGE

# Folder containing the py cfg routines, typically this will not
# change
PYCFG="py-cfg-new/py-cfg"

# location of the folder containing the key scripts that you will edit
# (reduce_prs.py, etc.)
SCRIPTFOLDER="scripts/"

# beginning of the name for a temporary file, typically this will not
# change
TMPFILE="tmp"

## ANALYSIS Files - check that they are there

# file containing the python script to reduce the parses
REDUCEPRSFILE=$SCRIPTFOLDER"reduce_prs.py"

# file containing the python script to segment
TREESFILE=$SCRIPTFOLDER"trees-words.py"

# file containing the python script to calculate minimum bayes risk
MBRPYFILE=$SCRIPTFOLDER"mbr.py"

# file containing the python script to evaluate the segmentation
EVALPY=$SCRIPTFOLDER"eval.py"


###########################
# a) Create the parse tree files
for i in {0..7}
do
    $PYCFG -n $NITER \
           -G $RESFOLDER$RUNFILE$i.wlt \
           -A $RESFOLDER$TMPFILE$i.prs \
           -F $RESFOLDER$TMPFILE$i.trace \
           -E -r $RANDOM -d 101 -a 0.0001 -b 10000 \
           -e 1 -f 1 -g 100 -h 0.01 -R -1 -P -x 10 -u $YLTFILE -U cat \
           > $RESFOLDER$OUTFILE$i.prs $GRAMMARFILE \
           < $YLTFILE &
    pid[${i}]=$!
done

for pid in ${pid[*]}
do
    wait $pid
done

###########################
# b) Reduce the parse trees (-n = number of parses to be removed /
# br-phono*: all the parse tree files to be applied - e.g. 0 through
# 7)
python $REDUCEPRSFILE -n $NRED $RESFOLDER$OUTFILE[0-9].prs

###########################
# c) Segmentation
for i in {0..7}
do
    python $TREESFILE -c $LEVEL \
           < $RESFOLDER$OUTFILE$i-last.prs \
           > $RESFOLDER$OUTFILE$i$INMBRFILE
done

###########################
# d) Extract the most frequent segmentation in the 800 sample
# segmentations (minimum bayes risk) and to be used in the evaluation
python $MBRPYFILE $RESFOLDER$OUTFILE*$INMBRFILE  \
       > $RESFOLDER$KEYNAME-$ALGO-cfgold.txt
