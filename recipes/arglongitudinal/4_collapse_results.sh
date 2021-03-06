#!/usr/bin/env bash

# Script for bringing together the results generated by the analyze
# script.
#
# Mathieu Bernard


# Must exists and contains the results (or partial results) of step 5
data_dir="/fhgfs/bootphon/scratch/aiturralde/RES_FOLDER"
for j in ${data_dir}/*DS/NS*/COMPDAT/ANALIZED*/*; do
	cd $j
	header="version matching algo \
        	token_f-score token_precision token_recall \
        	boundary_f-score boundary_precision boundary_recall"
	header=`echo $header | tr -s ' ' | tr ' ' '\t'`
	echo $header > $data_dir/results.txt


    # Populate the cfgold.txt file for each version
    echo $header > $j/cfgold.txt

	for algo in `find $j -name '*cfgold-res.txt' | sort`
	do
        	# bring together the results
        	algo_dir=`dirname $algo`
        	algo_name=`basename $j | sed 's/3sf/3/'`

        	line=`grep '[0-9]' $algo`
        	echo $corpus  $algo_name $line  |
            	     tr -s ' ' | tr ' ' '\t' >> $data_dir/cfgold.txt
	done
	sed 1d $data_dir/cfgold.txt >> $data_dir/results.txt
	echo
done

echo Writed $data_dir/results.txt

exit
