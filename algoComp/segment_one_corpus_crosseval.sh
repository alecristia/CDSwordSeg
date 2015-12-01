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
RESFOLDER=`readlink -f ./test`/

# If the $4 argument is non-empty, jobs are started by the
# clusterize.sh script.
# CLUSTERIZE=$4
CLUSTERIZE=y

#############################################

#1. Prepare for the performances
CFGOLD="algo token_f-score token_precision token_recall \
boundary_f-score boundary_precision boundary_recall"
echo $CFGOLD > ${RESFOLDER}_$KEYNAME-cfgold.txt


$ALL_ALGOS=`ls pipeline/*.sh | cat | sed "s/pipeline\///g" | sed "s/\.sh//g"`
#2. List all algo scripts that will be launched
#ALGO_LIST=./puddle.sh
#ALGO_LIST=./dmcmc.sh
#ALGO_LIST=./dibs.sh
#ALGO_LIST=./ngrams.sh
#ALGO_LIST=./TPs.sh
#ALGO_LIST=./AGc3sf.sh
ALGO_LIST=./AGu.sh


#3. Run all algos either locally or in the cluster
for ALGO in $ALGO_LIST
do
    COMMAND="$ALGO $ABSPATH $KEYNAME $RESFOLDER"
    echo Running command: $COMMAND
    COMMAND=${ABSPATH}pipeline/$COMMAND
    
    if [ -e $CLUSTERIZE ]
    then
        $COMMAND
    else
        ../clusterize.sh "$COMMAND" "$ALGO"
    fi
done

exit
