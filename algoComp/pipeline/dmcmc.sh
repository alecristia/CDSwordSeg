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

# Translate the corpus into a unicode format
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

    ### ATTENTION merge the 1st line with the 2nd if it contains only 1
    ### syllable. See bugfix.py for details.
    mv $FOLD ${FOLD/input/unfixed}
    $ABSPATH/algos/phillips-pearl2014/bugfix.py \
        ${FOLD}/input/unfixed} $FOLD

    # ATTENTION not sure it will work as we expect - it should, since
    # we are still feeding it unicode input as before, but one never
    # knows...  NOTE writing with standard format IS possible for this
    # algo but not implemented
    $DPSEG -o ${FOLD/input/output} --data-file $FOLD > ${FOLD/input/stats}
    sed 's/ $//g' ${FOLD/input/output} | sed '/^$/d' > seded
    mv seded ${FOLD/input/output}
    echo
done

echo Unfolding to output.txt
$CROSSEVAL unfold $RESFOLDER/output-fold*.txt \
           --index $RESFOLDER/input-index.txt \
           --output $RESFOLDER/output.txt

echo Translate back output from unicode format to cfgold.txt
$CONVERTER/convert-from-unicode.py \
    $RESFOLDER/output.txt \
    $RESFOLDER/syllables-dict.txt \
    $RESFOLDER/cfgold.txt

echo Evaluating
cd $ABSPATH/scripts
./doAllEval.text $RESFOLDER

echo done with $ALGO
