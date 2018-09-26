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


# will be createed to store results
#output_dir=${1:-./results}

# input data directory must exists and have a 'matched' subdir
# containing the results of step 4
#data_dir=${2:-./data}

# the segmentation pipeline
segmenter=${3:-../../algoComp/segment.py}

echo $data_dir $output_dir

source activate /cm/shared/apps/python-anaconda/envs/wordseg

# Run all algos on all versions in parallel (on the cluster if available)
for input_dir in $data_dir/matched/WL_*
do
    version=`basename $input_dir`

        echo "cat $input_dir/tags.txt  | wordseg-stats  > $input_dir/stats.txt"
        cat $input_dir/tags.txt  | wordseg-stats  > $input_dir/stats.txt
done
source deactivate

exit
