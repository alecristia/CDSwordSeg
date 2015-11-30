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

# subprograms used in this script
CONVERTER="python $ABSPATH/algos/phillips-pearl2014/syllable-conversion"
CROSSEVAL="$ABSPATH/crossevaluation.py"
DPSEG="${ABSPATH}/algos/phillips-pearl2014/dpseg_files/dpseg \
     -C ${ABSPATH}/algos/phillips-pearl2014/configs/config-uni-dmcmc.txt \
     --ngram $ngram --a1 $a --b1 $b1"

echo Converting syllables to unicode
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

NFOLDS=5
echo Creating $NFOLDS folds for cross evaluation
$CROSSEVAL fold $ROOT-$ALGO-input.txt --nfolds $NFOLDS

for FOLD in $ROOT-$ALGO-input-fold*.txt
do
    N=`basename $FOLD | sed 's/.*fold//' | sed 's/\.txt//'`
    echo -n Processing fold $N
    # ATTENTION not sure it will work as we expect - it should, since
    # we are still feeding it unicode input as before, but one never
    # knows...  NOTE writing with standard format IS possible for this
    # algo but not implemented
    stats=$ROOT-$ALGO-stats.txt
    $DPSEG -o ${FOLD/input/output} --data-file $FOLD > ${FOLD/input/stats}
    sed 's/ $//g' ${FOLD/input/output} | sed '/^$/d' > seded
    mv seded ${FOLD/input/output}
    echo
done

echo Unfolding to $KEYNAME-$ALGO-cfgold.txt
$CROSSEVAL unfold $ROOT-$ALGO-output-fold*.txt \
           --index $ROOT-$ALGO-input-index.txt \
           --output $ROOT-$ALGO-output.txt

echo Translate back output from unicode format
$CONVERTER/convert-from-unicode.py \
    $ROOT-$ALGO-output.txt \
    $ROOT-$ALGO-syllables-dict.txt \
    $ROOT-$ALGO-cfgold.txt

echo Evaluating
cd ${ABSPATH}scripts
./doAllEval.text $RESFOLDER $KEYNAME $ALGO

# local clean up
#cd $RESFOLDER
#rm *.seg

echo done with $ALGO
