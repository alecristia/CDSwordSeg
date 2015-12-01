#!/usr/bin/env bash

# Script for analyzing a single corpus in the algoComp2015.1.0 project
# Alex Cristia alecristia@gmail.com 2015-08-25
# Updated by Mathieu Bernard for 'clusterization' of the pipeline
# And again by Alex
# 2015-11-26 for winnipeglena corpus analysis

#########VARIABLES###########################
ABSPATH="`pwd`/"
RESFOLDER="/fhgfs/bootphon/scratch/acristia/results/WinnipegLENA/"
#########

#1. Prepare for the performances
CFGOLD="algo token_f-score token_precision token_recall \
boundary_f-score boundary_precision boundary_recall"

#2. List all algo scripts that will be launched
ALGO_LIST="./dibs.sh"
# ./TPs.sh ./AGc3sf.sh"
# ./puddle.sh ./dmcmc.sh" #these are incremental
#./ngrams.sh this one cannot be evaluated

#3. Run all algos in the cluster, once per version
for VERSION in ${RESFOLDER}WL*; do
        KEYNAME=`echo ${VERSION#$RESFOLDER}`
#        echo "$RESFOLDER$KEYNAME"

	echo $CFGOLD > ${RESFOLDER}${KEYNAME}/_${KEYNAME}-cfgold.txt


	for ALGO in $ALGO_LIST; do
	    cd ${ABSPATH}pipeline/
   	    COMMAND="$ALGO $ABSPATH $KEYNAME $RESFOLDER$KEYNAME/ "
	    echo $COMMAND

	    ./clusterize.sh "$COMMAND"
	done

done

exit
