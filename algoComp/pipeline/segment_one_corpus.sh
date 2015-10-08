#!/usr/bin/env bash

# Script for analyzing a single corpus in the algoComp2015.1.0 project
# Alex Cristia alecristia@gmail.com 2015-08-25

# Updated by Mathieu Bernard for 'qsubization' of the pipeline

#########VARIABLES###########################
#Variables that have been passed by the user

KEYNAME=$1
RESFOLDER=$2
LANGUAGE=$3

#Variables that will not be changed probably:
ABSPATH=$(pwd)/../
#############################################

# NOTE: there are lots of annotation below, but typically you will not
# need to read beyond this line


#1. Prepare for the performances

CFGOLD="algo token_f-score token_precision token_recall
boundary_f-score boundary_precision boundary_recall"

echo $CFGOLD > ${RESFOLDER}_$KEYNAME-cfgold.txt


# 2. Run DIBS

./dibs.sh $ABSPATH $KEYNAME $RESFOLDER

# 3. Run TPs

./TPs.sh $ABSPATH $KEYNAME $RESFOLDER

# 4. Run n-grams
# NOTE!! this one doesn't yield a segmented corpus, but a list of ngrams

./ngrams.sh $ABSPATH $KEYNAME $RESFOLDER

# 5 Run AG

./AG.sh $ABSPATH $KEYNAME $RESFOLDER
