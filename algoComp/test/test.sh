#!/usr/bin/env bash

# Test of the dmcmc algorithm on a single input file. Trying to find
# the segfault...
#
# Mathieu Bernard

ABSPATH=`readlink -f ..`
RESFOLDER=`mktemp -d ./data-XXX`
RESFOLDER=`readlink -f $RESFOLDER`
TAGSPATH=$ABSPATH/../recipes/WinnipegLENA/phono/WL_CDS_LS

echo Writing to $RESFOLDER

for file in tags gold
do
    head -100 $TAGSPATH/$file.txt | #sed 12,15d |
        sed 's/ $//g' > $RESFOLDER/$file.txt
done
echo "Input with `wc -l $RESFOLDER/gold.txt | cut -d' ' -f1` lines"

# DMCMC parameters
a=0
b1=1
ngram=1

# subprograms used in this script
CONVERTER="python $ABSPATH/algos/phillips-pearl2014/syllable-conversion"
CROSSEVAL=$ABSPATH/crossevaluation.py
DPSEG="${ABSPATH}/algos/phillips-pearl2014/dpseg_files/dpseg \
     -C ${ABSPATH}/algos/phillips-pearl2014/configs/config-uni-dmcmc.txt \
     --ngram $ngram --a1 $a --b1 $b1"

echo Converting syllables to unicode
# Create a syllable list for this corpus
sed 's/;eword//g' $RESFOLDER/tags.txt |
    tr -d ' ' |
    sed 's/;esyll/ /g' |
    sed 's/ $//g' |
    sed 's/ /\n/g' |
    sort | uniq |
    sed '/^$/d' > $RESFOLDER/syllables-list.txt

# Create a unicode equivalent for each syllable on that list
$CONVERTER/create-unicode-dict.py \
       $RESFOLDER/syllables-list.txt \
       $RESFOLDER/syllables-dict.txt

# Translate the corpus into a unicode format
$CONVERTER/convert-to-unicode.py \
       $RESFOLDER/tags.txt \
       $RESFOLDER/syllables-dict.txt \
       $RESFOLDER/input.txt

### ATTENTION adding/removing spaces between words in input has no
### effect but we remove all spaces just in case...
mv $RESFOLDER/input.txt $RESFOLDER/input-sp.txt
cat $RESFOLDER/input-sp.txt | tr -d ' ' > $RESFOLDER/input-unfixed.txt

### ATTENTION merge the 1st line with the 2nd if it contains only 1
### syllable. See bugfix.py for details.
$ABSPATH/algos/phillips-pearl2014/bugfix.py \
    $RESFOLDER/input-unfixed.txt $RESFOLDER/input.txt

FOLD=$RESFOLDER/input.txt
$DPSEG -o ${FOLD/input/output} --data-file $FOLD -d 1000 \
       > ${FOLD/input/stats} || exit 1
sed 's/ $//g' ${FOLD/input/output} | sed '/^$/d' > seded
mv seded ${FOLD/input/output}

echo Translate back output from unicode format to cfgold.txt
$CONVERTER/convert-from-unicode.py \
    $RESFOLDER/output.txt \
    $RESFOLDER/syllables-dict.txt \
    $RESFOLDER/cfgold.txt

echo Evaluating
cd $ABSPATH/scripts
./doAllEval.text $RESFOLDER

echo done with $ALGO
