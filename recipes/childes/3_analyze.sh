#!/usr/bin/env bash
#
# Script for analyzing the different Childes subcorpora
#
# Copyright (C) 2016 by Alex Cristia, Mathieu Bernard


# will be createed to store results
output_dir=${1:-./results}

# input data directory must exists and have a subdir
# per subcorpora, as generated in step 2
data_dir=${2:-./data}

# the segmentation pipeline
segmenter=${3:-../../algoComp/segment.py}

# Run all algos on all speakers for all subcorpora in parallel (on the
# cluster if available)
for subcorpus in $(find . -maxdepth 2 -mindepth 2 -type d -exec basename {} \;)
do
    # create the output dir if needed
    mkdir -p $output_dir/$subcorpus

    for speaker in $(find $data_dir/$subcorpus -mindepth 1 -type d -exec basename {} \;)
    do
        echo "Clusterizing  $subcorpus $speaker"

        input_dir=$data_dir/$subcorpus/$speaker
        result_dir=$output_dir/$subcorpus/$speaker
        version=$subcorpus.$speaker
        #echo $input_dir $result_dir $version

        $segmenter --output-dir $result_dir \
                   --algorithms all \
                   --ag-median 5 \
                   --clusterize \
                   --jobs-basename $version \
                   --goldfile $input_dir/gold.txt \
                   $input_dir/tags.txt || exit 1
        exit
    done
    exit
done
exit
