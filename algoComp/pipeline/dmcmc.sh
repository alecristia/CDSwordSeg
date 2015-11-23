#!/usr/bin/env bash

# Script for launching DMCMC (algo by Phillips & Pearl - see readme there)
# Alex Cristia <alecristia@gmail.com>

ABSPATH=$1
KEYNAME=$2
RESFOLDER=$3

ROOT=$RESFOLDER$KEYNAME
ALGO="dmcmc"

# ATTENTION
# Must be python3: unicode support is far more better than in python2
PYTHON=python3

# Navigate to the folder
cd ${ABSPATH}algos/phillips-pearl2014

# Remove word tags to create syllabified input:
cat $ROOT-tags.txt |
    sed 's/;eword//g' |
    tr -d ' ' |
    sed 's/;esyll/ /g' > $ROOT-syl.txt

# Create a syllable list for this corpus
cat  $ROOT-syl.txt |
    sed 's/ /\n/g' |
    sort | uniq |
    sed '/^$/d'  > $ROOT-sylList.txt

# Create a unicode equivalent for each syllable on that list
echo Creating syllables to unicode dictionary...
$PYTHON syllable-conversion/create-unicode-dict.py \
     $ROOT-sylList.txt \
     $ROOT-sylDict.txt
#echo Writed $ROOT-sylDict.txt

# Translate the corpus into a unicode format
echo Converting syllables to unicode...
$PYTHON syllable-conversion/convert-to-unicode.py \
     $ROOT-syl.txt \
     $ROOT-sylDict.txt \
     $ROOT-syl-unicode.txt
#echo Writed $ROOT-syl-unicode.txt

#NOTE: set up for a single run -- might need to revise if multirun
echo Spliting train and test...
N=`wc -l $ROOT-syl-unicode.txt | cut -f1 -d' '`
Ntrain=`echo "$((N * 4 / 5))"`
Nbegtest=`echo "$((Ntrain + 1))"`

sed -n 1,${Ntrain}p  $ROOT-syl-unicode.txt \
    > $ROOT-syl-unicode-train.txt
sed -n $Nbegtest,${N}p $ROOT-syl-unicode.txt \
    > $ROOT-syl-unicode-test.txt

# running DMCMC algo
echo -n Running $ALGO
a=0
b1=1
ngram=1
ver=1

# ATTENTION not sure it will work as we expect - it should, since we
# are still feeding it unicode input as before, but one never knows...

DPSEG=./dpseg_files/dpseg
output=U_DMCMC:$a.$b1.ver$ver.txt
stats=U_DMCMC:$a.$b1.ver${ver}stats.txt
train=syl-unicode-train.txt
test=syl-unicode-test.txt

$DPSEG \
    -C ./configs/config-uni-dmcmc.txt \
    -o $ROOT-$output \
    --data-file $ROOT-$train \
    --ngram $ngram --a1 $a --b1 $b1 \
    > $ROOT-$stats #--eval-file $ROOT-$test

echo Translate output back from unicode format...
cat $ROOT-$output | sed '/^$/d' > $ROOT-$output-seded
$PYTHON syllable-conversion/convert-from-unicode.py \
        $ROOT-$output-seded \
        $ROOT-sylDict.txt \
        $ROOT-${ALGO}-cfgold.txt

# NOTE writing with standard format IS possible for this algo but not
# implemented

echo Do the evaluation...
cd ${ABSPATH}scripts
./doAllEval.text $RESFOLDER $KEYNAME $ALGO

# Final clean up
#cd $RESFOLDER
#rm *.seg

echo done with $ALGO
