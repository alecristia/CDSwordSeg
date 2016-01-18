#!/usr/bin/env bash
#
# Script for analyzing the different versions of Winnipeg corpora
#
# Copyright (C) 2016 by Alex Cristia, Mathieu Bernard


# will be createed to store results
output_dir=${1:-./results}

# input data directory must exists and have a 'matched' subdir
# containing the results of step 4
data_dir=${2:-./data}

# the segmentation pipeline
segmenter=${3:-../../algoComp/segment.py}


# create the output dir if needed
mkdir -p $output_dir

# Run all algos on all versions in parallel (on the cluster if available)
for input_dir in $data_dir/matched/WL_*
do
    version=`basename $input_dir`

    echo "Clusterizing version $version"
    $PIPELINE --output-dir $output_dir/$version \
              --algorithms all \
              --clusterize \
              --jobs-basename $version \
              --goldfile $input_dir/gold.txt \
              $input_dir/tags.txt || exit 1
done

exit
