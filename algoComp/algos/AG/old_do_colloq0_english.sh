#!/usr/bin/env bash

#################### definining parameters ###################

# location of the file holding the grammar
GRAMMARFILE="grammars/Colloq0_enFestival.lt"

##### Passed by user

# location of the folder that will come to hold the results
RESFOLDER=$1

# name of the database
KEYNAME=$2


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

# this is the level that is tested -- colloq0 is supposed to be the
# word level; in coll0 model because it is the level at which phonemes
# are combined; in coll3syll it is defined as groups of syllables
LEVEL="Colloq0"

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

# number of iterations per parse, normally 2000 (except for
# debugging-10)
NITER=10

# number thrown out when reducing the parse, normally 100 (except for
# debugging-0)
NRED=0


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
python $MBRPYFILE $RESFOLDER$OUTFILE*$INMBRFILE \
       > $RESFOLDER${KEYNAME}-agU-cfgold.txt
