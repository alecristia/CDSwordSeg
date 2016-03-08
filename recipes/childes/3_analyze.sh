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

# Because the whole corpus is too big (requires more than 10k jobs to
# analyze it), this script analyzes only one sample (the first sample
# not found in the result directory) and exit. This submit about 15
# jobs to the cluster. You must rerun the script for each sample.
for subcorpus in $(find . -maxdepth 2 -mindepth 2 -type d -exec basename {} \;)
do
    # create the output dir if needed
    mkdir -p $output_dir/$subcorpus

    for speaker in $(find $data_dir/$subcorpus -mindepth 1 -type d -exec basename {} \;)
    do
        result_dir=$output_dir/$subcorpus/$speaker
        [ -d $result_dir ] && echo "found $subcorpus $speaker" && continue

        echo "Clusterizing  $subcorpus $speaker"
        input_dir=$data_dir/$subcorpus/$speaker
        version=$subcorpus.$speaker

        $segmenter --output-dir $result_dir \
                   --algorithms all \
                   --ag-median 5 \
                   --clusterize \
                   --jobs-basename $version \
                   --goldfile $input_dir/gold.txt \
                   $input_dir/tags.txt && exit 0 || exit 1
    done
done
exit
