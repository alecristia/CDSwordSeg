#!/bin/sh

# Script for launching n-grams, the step 4 of segment_one_corpus.sh
# Author: Mathieu Bernard <mmathieubernardd@gmail.com>

ABSPATH=$1
RESFOLDER=$2
ALGO=$3
UNIT=$4
WINDOW=$5
SETUP=$6 # only for 'AGu' or 'AG3cf'

#UNIT is either 'syllable' or 'phoneme'

res=$RESFOLDER/$ALGO/$UNIT

# Remove word boundaries to create input:
echo cleaning tags to get the right unit representation :  $UNIT
$python ../InputPipeline.py -u $UNIT -r $res -p $ABSPATH/tags.txt

if [ $ALGO = "TPs" ]
# TP need UB at the end of utterance instead of \n
then
#sed 's/\n/UB /g' $res/input.txt > $res/input_bis.txt
sed 's/  / /g' $res/input.txt |
    sed 's/ $//g' |
    tr '\n' '?'   |
    sed 's/?/ UB /g' > $res/boundaries_marked.txt
#echo '\n' > $res/boundaries_marked.txt
$python ../algos/TPs/TPsegmentation.py $res/boundaries_marked.txt > $res/cfgold.txt

# actual algo running
elif [ $ALGO = "ngrams" ]
then
    BIN=$../algos/ngrams/mkngram.sh
    $BIN --syll $res/input.txt > $res/freq-all.txt
    head -n 10000 $res/freq-all.txt > $res/freq-top.txt


# Note: n-grams doesn't have a full eval, like the others, because
# it's not a SEGMENTATION algorithm

elif [ $ALGO == "puddle" ]
then
$python ../algos/PUDDLE/puddle_new.py -r $res -o $res/cfgold.txt -w $WINDOW


elif [ $ALGO = "dibs" ]
# DIBS requires a bit of corpus to calculate some statistics. We'll
# use 200 lines from the version with the word boundaries to this end
# (we remove syllable boundaries, which are not needed):
then
echo training $ALGO
head -200 $ABSPATH/tags.txt | sed 's/;esyll//g' > $res/clean_train.txt

echo Running $ALGO...
DIBS=../algos/DiBS/apply-dibs.py

# Actual algo running
$DIBS $res/clean_train.txt $res/input.txt \
      $res/dirty_output.txt $res/diphones_output.txt

# Clean up the output file & store it in your desired location
sed "s/.*$(printf '\t')//" $res/dirty_output.txt |
sed 's/;eword/;aword/g' > $res/output.txt

sed 's/ //g' $res/output.txt |
sed 's/;aword/ /g' > $res/cfgold.txt


elif [ $ALGO = "AGu" ]
then
# Remove spaces within words and syllable boundaries, and replace word
# tags with spaces to create gold
sed 's/;esyll//g' $ABSPATH/tags.txt |
sed 's/;eword/ /g' |
sed '/^$/d' |
tr -d ' ' > $res/input.gold

#copie the tag file in the result folder
cp $ABSPATH/tags.txt $res/tags.txt
cp $ABSPATH/gold.txt $res/gold.txt

# input in ylt 
cp $res/input.txt $res/input.ylt

# actual algo running
echo running $ALGO
GRAMMARFILE=../algos/AG/do_AG_english.sh
$GRAMMARFILE $res $ALGO $UNIT $SETUP|| exit 1

fi

echo done with $ALGO


# Do the evaluation
####STEP 1: Evaluate against the gold
$python ../scripts/evalGold.py -g $ABSPATH/gold.txt < $res/cfgold.txt \
> $res/cfgold-res.txt

####STEP 2: Extract top 10k frequency items
tr ' ' '\n' < $res/cfgold.txt |
sort | uniq -c | awk '{print $1" "$2}' | sort -n -r |
head -n 10000 > $res/freq-top.txt


