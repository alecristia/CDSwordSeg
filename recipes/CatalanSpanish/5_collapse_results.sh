#!/usr/bin/env bash

# Script for bringing together the results generated by the analyze
# script.
#
# Mathieu Bernard
ABSPATH="../../algoComp"
CURPATH=`pwd`

# Must exists and contains the results (or partial results) of step 5
#data_dir="/fhgfs/bootphon/scratch/lfibla/SegCatSpa/res_cat/"
data_dir=$1

header="version matching algo \
        token_f-score token_precision token_recall \
        boundary_f-score boundary_precision boundary_recall"
header=`echo $header | tr -s ' ' | tr ' ' '\t'`
echo $header > $data_dir/results.txt


for RESFOLDER in `ls -d ${data_dir}/*/*/`; do
#echo in $RESFOLDER loop
	tr -s " " < ${RESFOLDER}gold.txt | sed "/^$/d" | sed "/^ $/d" > temp.tmp
	mv temp.tmp ${RESFOLDER}gold.txt

	tr -s " " < ${RESFOLDER}cfgold.txt | sed "/^$/d" | sed "/^ $/d" > temp.tmp
	mv temp.tmp ${RESFOLDER}cfgold.txt

#wc ${RESFOLDER}*gold.txt

    cd $ABSPATH/scripts
    ./doAllEval.text $RESFOLDER
    cd $CURPATH
done

echo $data_dir
#echo doing header res
    # Populate the cfgold.txt file for each version
    echo $header > $data_dir/results.txt

    for algo in `find $data_dir -name '*cfgold-res.txt' | sort`
    do
        # bring together the results
#echo $algo_dir
        algo_dir=`dirname $algo`
        algo_name=`basename $algo_dir | sed 's/3sf/3/'`
#CORPUS NOT DEFINED!!
        line=`grep '[0-9]' $algo`
        echo $algo  $algo_name $line  |
            tr -s ' ' | tr ' ' '\t' >> $data_dir/results.txt
    done

#    sed 1d $data_dir/results.txt >> $data_dir/results.txt
#    echo


echo Writed $data_dir/results.txt

exit
