#!/usr/bin/env bash
#
# Some dmcmc runs crashed because of a (fixed) bug in
# crossevaluation. Detect and rerun them in this script.
#
# Copyright 2016 Mathieu Bernard

output_dir=./results
data_dir=./data
segmenter=../../algoComp/segment.py

failed=$(egrep 'dmcmc +$' results/results.txt | sed -e 's/dmcmc *$//' | tr ' ' '/')

for f in $failed
do
    corpus=$(echo $f | cut -f1 -d/)
    speaker=$(echo $f | cut -f2 -d/)
    echo "running dmcmc on $corpus $speaker"

    input_dir=$data_dir/$corpus/$speaker
    result_dir=$output_dir/$corpus/$speaker

    rm -rf $result_dir/dmcmc || exit 1
    $segmenter \
        --output-dir $result_dir \
        --algorithms dmcmc \
        --goldfile $input_dir/gold.txt \
        $input_dir/tags.txt || exit 1
done
