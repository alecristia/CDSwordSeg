#!/usr/bin/env bash

# Script for launching DMCMC (algo by Phillips & Pearl - see readme there)
# Alex Cristia <alecristia@gmail.com>
# Mathieu Bernard (syllable conversion, cross evaluation)

ABSPATH=$1
RESFOLDER=$2
ALGO="dmcmc"

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
# Remove word tags to create syllabified input:
sed 's/;eword//g' $RESFOLDER/tags.txt |
    tr -d ' ' |
    sed 's/;esyll/ /g' |
    sed 's/ $//g'> $RESFOLDER/syllables.txt

# Create a syllable list for this corpus
sed 's/ /\n/g' $RESFOLDER/syllables.txt |
    sort | uniq |
    sed '/^$/d'  > $RESFOLDER/syllables-list.txt

# Create a unicode equivalent for each syllable on that list
$CONVERTER/create-unicode-dict.py \
       $RESFOLDER/syllables-list.txt \
       $RESFOLDER/syllables-dict.txt

# Translate the corpus into a unicode format
$CONVERTER/convert-to-unicode.py \
       $RESFOLDER/syllables.txt \
       $RESFOLDER/syllables-dict.txt \
       $RESFOLDER/input.txt

NFOLDS=5
echo Creating $NFOLDS folds for cross evaluation
$CROSSEVAL fold $RESFOLDER/input.txt --nfolds $NFOLDS

# TODO parallelize this loop
for FOLD in $RESFOLDER/input-fold*.txt
do
    N=`basename $FOLD | sed 's/.*fold//' | sed 's/\.txt//'`
    echo -n Processing fold $N
    # ATTENTION not sure it will work as we expect - it should, since
    # we are still feeding it unicode input as before, but one never
    # knows...  NOTE writing with standard format IS possible for this
    # algo but not implemented
    stats=$RESFOLDER/stats.txt
    $DPSEG -o ${FOLD/input/output} --data-file $FOLD > ${FOLD/input/stats}
    sed 's/ $//g' ${FOLD/input/output} | sed '/^$/d' > seded
    mv seded ${FOLD/input/output}
    echo
done

echo Unfolding to cfgold.txt
$CROSSEVAL unfold $RESFOLDER/output-fold*.txt \
           --index $RESFOLDER/input-index.txt \
           --output $RESFOLDER/output.txt

echo Translate back output from unicode format
$CONVERTER/convert-from-unicode.py \
    $RESFOLDER/output.txt \
    $RESFOLDER/syllables-dict.txt \
    $RESFOLDER/cfgold.txt

echo Evaluating
cd $ABSPATH/scripts
./doAllEval.text $RESFOLDER

echo done with $ALGO
