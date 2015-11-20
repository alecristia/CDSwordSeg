#!/usr/bin/env bash

# Script for launching DMCMC (algo by Phillips & Pearl - see readme there)
# Alex Cristia <alecristia@gmail.com>


ABSPATH=$1
KEYNAME=$2
RESFOLDER=$3

ALGO="dmcmc"

# Navigate to the folder
cd ${ABSPATH}algos/phillips-pearl2014

# Remove word tags to create syllabified input:
sed 's/;eword//g'  $RESFOLDER$KEYNAME-tags.txt | tr -d ' ' | sed 's/;esyll/ /g' > $RESFOLDER$KEYNAME-syl.txt

# Create a syllable list for this corpus
sed 's/ /\n/g'  $RESFOLDER$KEYNAME-syl.txt | sort |  uniq > ${RESFOLDER}$KEYNAME-sylList.txt

# Create a unicode equivalent for each syllable on that list
#NOT DONE: wouldn't it be easier to do it in bash??
perl syllable-conversion/create-unicode-dict-flexible.pl ${RESFOLDER}$KEYNAME-sylList.txt  ${RESFOLDER}$KEYNAME-sylList-unicode.txt

# Translate the corpus into a unicode format
#NOT DONE: wouldn't it be easier to do it in bash??
perl syllable-conversion/convert-to-unicode-flexible.pl $RESFOLDER$KEYNAME-syl.txt ${RESFOLDER}$KEYNAME-sylList-unicode.txt $RESFOLDER$KEYNAME-syl-unicode.txt

# Split training and test 
#NOTE: set up for a single run -- might need to revise if multirun
N=`wc -l $RESFOLDER$KEYNAME-syl-unicode.txt | cut -f1 -d' '`
Ntrain=`echo "$((N * 4 / 5))"`
Nbegtest=`echo "$((Ntrain + 1))"`

sed -n 1,${Ntrain}p  $RESFOLDER$KEYNAME-syl-unicode.txt > $RESFOLDER$KEYNAME-syl-unicode-train.txt
sed -n $Nbegtest,${N}p $RESFOLDER$KEYNAME-syl-unicode.txt > $RESFOLDER$KEYNAME-syl-unicode-test.txt


# actual algo running

$a = 0;
$b1 = 1;
$ngram = 1;


#ATTENTION this section was written in perl
#NOT DONE: needs to be translated into bash
	# also, not sure it will work as we expect - it should, since we are still feeding it unicode input as before, but one never knows...
	# plus need to decide question of how many runs and how to combine across, right now it's set up for a single run
#DMCMC
#for($i=1;$i<=5;$i++){
i=1
print "DMCMC\t$i\n";
$output = 'U_DMCMC:' . $a . '.' . $b1 . '.ver' . $i . '.txt';
$stats = 'U_DMCMC:' . $a . '.' . $b1 . '.ver' . $i .'stats.txt';
#$train = 'train-uni-9mos-clean' . $i . '.txt';
$train = $RESFOLDER$KEYNAME-syl-unicode-train.txt;
$test = 'test-uni-9mos-clean' . $i . '.txt';
$train = $RESFOLDER$KEYNAME-syl-unicode-test.txt;
system("./../dpseg_files/dpseg -C ../configs/config-uni-dmcmc.txt -o ../output_clean/english/$output --data-file ../corpora_clean/$train  --ngram $ngram --a1 $a --b1 $b1 > ../output_clean/english/$stats"); #--eval-file ../corpora_clean/$test
#}

# Translate output back from unicode format
perl syllable-conversion/convert-from-unicode-flexible.pl ../output_clean/english/$output $RESFOLDER$KEYNAME-${ALGO}-cfgold.txt


# NOTE; writing with standard format IS possible for this algo but not implemented


# Do the evaluation
cd ${ABSPATH}scripts
./doAllEval.text $RESFOLDER $KEYNAME $ALGO

# Final clean up
#cd $RESFOLDER
#rm *.seg


echo "done with dmcmc"
