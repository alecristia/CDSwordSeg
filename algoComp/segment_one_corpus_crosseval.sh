#!/usr/bin/env bash

# Script for analyzing a single corpus in the algoComp2015.1.0 project
# Alex Cristia alecristia@gmail.com 2015-08-25

# Updated by Mathieu Bernard for 'clusterization' of the pipeline
# And again by Alex

#########VARIABLES###########################
#Variables that have been passed by the user

# ABSPATH=$1
# KEYNAME=$2
# RESFOLDER=$3
ABSPATH=`readlink -f .`/
KEYNAME=key
RESFOLDER=`readlink -f ./test`/results/
mkdir -p $RESFOLDER

# If the $4 argument is non-empty, jobs are started by the
# clusterize.sh script.
#CLUSTERIZE=$4
CLUSTERIZE=yes

#############################################

#1. Prepare for the performances
CFGOLD="algo token_f-score token_precision token_recall \
boundary_f-score boundary_precision boundary_recall"
echo $CFGOLD > ${RESFOLDER}base-cfgold.txt
cp ${RESFOLDER}base-cfgold.txt ${RESFOLDER}_$KEYNAME-cfgold.txt

ALL_ALGOS=`ls pipeline/*.sh | sed "s/pipeline\///g" | sed "s/\.sh//g"`

#2. List all algo scripts that will be launched
ALGO_LIST=AGu
#ALGO_LIST=AGc3sf
#ALGO_LIST="AGu AGc3sf"
#ALGO_LIST=puddle
#ALGO_LIST=dmcmc
#ALGO_LIST=dibs
#ALGO_LIST=ngrams
#ALGO_LIST=TPs
#ALGO_LIST=$ALL_ALGOS

#3. Run all algos either locally or in the cluster
for ALGO in $ALGO_LIST
do
    mkdir -p $RESFOLDER$ALGO
    cp $RESFOLDER$KEYNAME-tags.txt $RESFOLDER$ALGO/$KEYNAME-tags.txt
    cp $RESFOLDER$KEYNAME-gold.txt $RESFOLDER$ALGO/$KEYNAME-gold.txt
    cp ${RESFOLDER}base-cfgold.txt $RESFOLDER$ALGO/_$KEYNAME-cfgold.txt

    COMMAND="$ALGO.sh $ABSPATH $KEYNAME $RESFOLDER$ALGO/"
    echo Running command: $COMMAND
    COMMAND=${ABSPATH}pipeline/$COMMAND

    if [ -e $CLUSTERIZE ]
    then
        # do not clusterize
        $COMMAND
    else
        ./clusterize.sh "$COMMAND" "$ALGO"
    fi

    # collapse the results in root
    sed 1d $RESFOLDER$ALGO/_$KEYNAME-cfgold.txt \
        >> ${RESFOLDER}_$KEYNAME-cfgold.txt
done

rm -f ${RESFOLDER}base-cfgold.txt
