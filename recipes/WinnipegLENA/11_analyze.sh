#!/usr/bin/env bash
#
# Script for analyzing the different versions of Winnipeg corpora
#
# Copyright (C) 2016 by Alex Cristia, Mathieu Bernard

#########VARIABLES
#Variables that have been passed by the user
data_dir=$1
output_dir=$2
#########

echo $data_dir $output_dir
# will be createed to store results
#output_dir=${1:-./results}

# input data directory must exists and have a 'matched' subdir
# containing the results of step 4
#data_dir=${2:-./data}

# the segmentation pipeline
segmenter=${3:-../../algoComp/segment.py}


# Run all algos on all versions in parallel (on the cluster if available)
for input_dir in $data_dir/WL_*
do
    version=`basename $input_dir`
#echo $version
    mkdir -p $output_dir/$version
    for input_file in $data_dir/$version/gold-*.txt
    do
    	keyname=`basename $input_file`
	tag_file=`echo $input_file | sed 's/gold/tags/'`
	echo "Clusterizing $input_file"

    	$segmenter --output-dir $output_dir/$version/$keyname \
               --algorithms dmcmc AGu AGc3sf \
               --ag-median 5 \
               --clusterize \
               --jobs-basename ${version}-$keyname \
               --goldfile $input_file \
               $tag_file || exit 1
     done
done

exit
