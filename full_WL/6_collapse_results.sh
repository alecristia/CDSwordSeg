#!/usr/bin/env bash

# Script for bringing together the results generated by the analyze
# script.
#
# Mathieu Bernard

#########VARIABLES###########################
RESFOLDER=${1:-/home/mbernard/scratch/dev/CDSwordSeg/full_WL/results/all}
#########

HEADER="version algo token_f-score token_precision token_recall \
        boundary_f-score boundary_precision boundary_recall"
HEADER=`echo $HEADER | tr -s ' ' | tr ' ' '\t'`
echo $HEADER > $RESFOLDER/results.txt

for VERSION in ${RESFOLDER}/WL_*
do
    VNAME=`basename $VERSION | sed 's/WL_//'`

    # Populate the cfgold.txt file for each version
    echo $HEADER > $VERSION/cfgold.txt

    for ALGO in `find $VERSION -name '*cfgold-res.txt' | sort`
    do
        # bring together the results
        ADIR=`dirname $ALGO`
        ANAME=`basename $ADIR`
        LINE=`grep '[0-9]' $ALGO`
        echo $VNAME $ANAME $LINE |
            tr -s ' ' | tr ' ' '\t' >> $VERSION/cfgold.txt
    done

    sed 1d $VERSION/cfgold.txt >> $RESFOLDER/results.txt
done
