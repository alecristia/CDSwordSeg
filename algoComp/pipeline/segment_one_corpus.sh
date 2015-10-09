#!/usr/bin/env bash

# Script for analyzing a single corpus in the algoComp2015.1.0 project
# Alex Cristia alecristia@gmail.com 2015-08-25

# Updated by Mathieu Bernard for 'clusterization' of the pipeline

#########VARIABLES###########################
#Variables that have been passed by the user

KEYNAME=$1
RESFOLDER=$2
LANGUAGE=$3

# If the $4 argument is non-empty, jobs are started by the
# clusterize.sh script.
CLUSTERIZE=$4

#Variables that will not be changed probably:
ABSPATH=$(pwd)/../
#############################################

#1. Prepare for the performances
CFGOLD="algo token_f-score token_precision token_recall
boundary_f-score boundary_precision boundary_recall"

echo $CFGOLD > ${RESFOLDER}_$KEYNAME-cfgold.txt


#2. List all algo scripts that will be launched
ALGO_LIST="./dibs.sh ./TPs.sh ./ngrams.sh ./AG.sh"


#3. Run all algos either locally or in the cluster
for ALGO in $ALGO_LIST
do
    COMMAND="$ALGO $ABSPATH $KEYNAME $RESFOLDER"
    echo Running command: $COMMAND

    if [ -n $CLUSTERIZE ]
    then
        ./clusterize.sh "$COMMAND"
    else
        $COMMAND
    fi
done

exit
