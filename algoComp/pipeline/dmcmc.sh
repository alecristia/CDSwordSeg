#!/usr/bin/env bash

# Script for launching DMCMC (algo by Phillips & Pearl - see readme there)
# Alex Cristia <alecristia@gmail.com>
# Mathieu Bernard (syllable conversion, cross evaluation)

ABSPATH=$1
RESFOLDER=$2
ALGO="dmcmc"

# prefix of the tools for syllable <-> unicode convertion
CONVERTER="python $ABSPATH/algos/phillips-pearl2014/syllable-conversion"

# cross evaluation executable
CROSSEVAL=$ABSPATH/crossevaluation.py

# dpseg executable with unigram DMCMC parameters
DPSEG="${ABSPATH}/algos/phillips-pearl2014/dpseg_files/dpseg \
     -C ${ABSPATH}/algos/phillips-pearl2014/configs/config-uni-dmcmc.txt \
     --ngram 1 --a1 0 --b1 1"

echo Converting syllables to unicode
# Create a syllable list for this corpus
sed 's/;eword//g' $RESFOLDER/tags.txt |
    tr -d ' ' |
    sed 's/;esyll/ /g' |
    sed 's/ $//g' |
    sed 's/ /\n/g' |
    sort | uniq |
    sed '/^$/d'  > $RESFOLDER/syllables-list.txt

# Create a unicode equivalent for each syllable on that list
$CONVERTER/create-unicode-dict.py \
       $RESFOLDER/syllables-list.txt \
       $RESFOLDER/syllables-dict.txt

# Translate the corpus in unicode
$CONVERTER/convert-to-unicode.py \
       $RESFOLDER/tags.txt \
       $RESFOLDER/syllables-dict.txt \
       $RESFOLDER/input.txt

### ATTENTION adding/removing spaces between words in input seems to
### have no effect but we remove all spaces just in case...
mv $RESFOLDER/input.txt $RESFOLDER/input-sp.txt
cat $RESFOLDER/input-sp.txt | tr -d ' ' > $RESFOLDER/input.txt

NFOLDS=5
echo Creating $NFOLDS folds for cross evaluation
$CROSSEVAL fold $RESFOLDER/input.txt --nfolds $NFOLDS

# TODO parallelize this loop
for FOLD in $RESFOLDER/input-fold*.txt
do
    N=`basename $FOLD | sed 's/.*fold//' | sed 's/\.txt//'`
    echo -n Processing fold $N

    # input, log and output files for the current fold
    input=$FOLD
    log=${input/input/log}
    output=${FOLD/input/output}

    # intermediate pre and post processing files
    input_raw=${input/input/input_raw}
    output_raw=${output/output/output_raw}

    ### ATTENTION merge the 1st line with the 2nd if it contains only 1
    ### syllable. See bugfix.py for details. TODO replace python by bash
    $ABSPATH/algos/phillips-pearl2014/bugfix.py $input $input_raw
    $DPSEG -o $output_raw --data-file $input_raw > $log && echo
    sed -e 's/ $//g' -e '/^$/d' $output_raw  > $output
done

echo Unfolding to $RESFOLDER/cfgold.txt
$CROSSEVAL unfold $RESFOLDER/output-fold*.txt \
           --index $RESFOLDER/input-index.txt \
           --output $RESFOLDER/output.txt

$CONVERTER/convert-from-unicode.py \
    $RESFOLDER/output.txt \
    $RESFOLDER/syllables-dict.txt \
    $RESFOLDER/cfgold.txt

echo Evaluating
cd $ABSPATH/scripts
./doAllEval.text $RESFOLDER

echo done with $ALGO
