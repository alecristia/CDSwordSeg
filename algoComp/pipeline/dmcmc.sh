#!/usr/bin/env bash

# Script for launching DMCMC (algo by Phillips & Pearl - see readme there)
# Alex Cristia <alecristia@gmail.com>
# Mathieu Bernard (syllable conversion, cross evaluation)

ABSPATH=$1
KEYNAME=$2
RESFOLDER=$3

ROOT=$RESFOLDER$KEYNAME
ALGO="dmcmc"

# DMCMC parameters
a=0
b1=1
ngram=1
ver=1

# subprograms used in this script
CONVERTER="python $ABSPATH/algos/phillips-pearl2014/syllable-conversion"
CROSSEVAL="$ABSPATH/crossevaluation.py"
DPSEG="${ABSPATH}/algos/phillips-pearl2014/dpseg_files/dpseg \
     -C ${ABSPATH}/algos/phillips-pearl2014/configs/config-uni-dmcmc.txt \
     --ngram $ngram --a1 $a --b1 $b1"

# Remove word tags to create syllabified input:
sed 's/;eword//g' $ROOT-tags.txt |
    tr -d ' ' |
    sed 's/;esyll/ /g' |
    sed 's/ $//g'> $ROOT-$ALGO-syllables.txt

# Create a syllable list for this corpus
sed 's/ /\n/g' $ROOT-$ALGO-syllables.txt |
    sort | uniq |
    sed '/^$/d'  > $ROOT-$ALGO-syllables-list.txt

# Create a unicode equivalent for each syllable on that list
$CONVERTER/create-unicode-dict.py \
       $ROOT-$ALGO-syllables-list.txt \
       $ROOT-$ALGO-syllables-dict.txt

# Translate the corpus into a unicode format
$CONVERTER/convert-to-unicode.py \
       $ROOT-$ALGO-syllables.txt \
       $ROOT-$ALGO-syllables-dict.txt \
       $ROOT-$ALGO-input.txt

# ATTENTION not sure it will work as we expect - it should, since we
# are still feeding it unicode input as before, but one never knows...
output=$ROOT-$ALGO-U_DMCMC:$a.$b1.ver$ver.txt
stats=$ROOT-$ALGO-U_DMCMC:$a.$b1.ver${ver}stats.txt

$DPSEG -o $output --data-file $ROOT-$ALGO-input.txt  > $stats

echo
echo Translate output back from unicode format...
sed '/^$/d' $ROOT-$ALGO-$output > $ROOT-$ALGO-$output-seded
$CONVERTER/convert-from-unicode.py \
        $ROOT-$output-seded \
        $ROOT-$ALGO-syllables-dict.txt \
        $ROOT-${ALGO}-cfgold.txt

# NOTE writing with standard format IS possible for this algo but not
# implemented

# Do the evaluation
echo Do the evaluation...

cd ${ABSPATH}scripts
./doAllEval.text $RESFOLDER $KEYNAME $ALGO

# Final clean up TODO
#cd $RESFOLDER
#rm *.seg

echo done with $ALGO
