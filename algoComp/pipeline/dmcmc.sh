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
sed 's/;eword//g' $ROOT-tags.txt | tr -d ' ' | sed 's/;esyll/ /g' > $ROOT-syl.txt

# Create a syllable list for this corpus
sed 's/ /\n/g' $ROOT-syl.txt |
    sort | uniq | sed '/^$/d'  > $ROOT-sylList.txt

exit

# Create a unicode equivalent for each syllable on that list
echo Creating syllables to unicode dictionary
$PYTHON syllable-conversion/create-unicode-dict.py \
     $ROOT-sylList.txt \
     $ROOT-sylList-unicode.txt

# Translate the corpus into a unicode format
echo Converting syllables to unicode
$PYTHON syllable-conversion/convert-to-unicode.py \
     $ROOT-syl.txt \
     $ROOT-sylList-unicode.txt \
     $ROOT-syl-unicode.txt

# Split training and test
#NOTE: set up for a single run -- might need to revise if multirun
N=`wc -l $ROOT-syl-unicode.txt | cut -f1 -d' '`
Ntrain=`echo "$((N * 4 / 5))"`
Nbegtest=`echo "$((Ntrain + 1))"`

sed -n 1,${Ntrain}p  $ROOT-syl-unicode.txt \
    > $ROOT-syl-unicode-train.txt
sed -n $Nbegtest,${N}p $ROOT-syl-unicode.txt \
    > $ROOT-syl-unicode-test.txt

# running DMCMC algo
echo running $ALGO
a=0
b1=1
ngram=1

# ATTENTION not sure it will work as we expect - it should, since we
# are still feeding it unicode input as before, but one never knows...

output=U_DMCMC_$a_$b1.txt
stats=U_DMCMC_$a_$b1_stats.txt
train=$ROOT-syl-unicode-train.txt
test=$ROOT-syl-unicode-test.txt
./../dpseg_files/dpseg \
    -C ../configs/config-uni-dmcmc.txt \
    -o ../output_clean/english/$output \
    --data-file ../corpora_clean/$train \
    --ngram $ngram --a1 $a --b1 $b1 \
    > ../output_clean/english/$stats #--eval-file ../corpora_clean/$test

# Translate output back from unicode format
# TODO
$PYTHON syllable-conversion/convert-from-unicode.py \
     ../output_clean/english/$output \
     $ROOT-${ALGO}-cfgold.txt

# NOTE writing with standard format IS possible for this algo but not
# implemented

# Do the evaluation
cd ${ABSPATH}scripts
./doAllEval.text $RESFOLDER $KEYNAME $ALGO

# Final clean up TODO
#cd $RESFOLDER
#rm *.seg

echo done with $ALGO
