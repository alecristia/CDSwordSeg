#!/usr/bin/env bash
#
# Script for analyzing the different Childes subcorpora.
#
# Because the whole corpus is too big (requires 8575 jobs to analyze
# it, for a total need of 50285 cores), this script analyzes only one
# sample (the first sample not found in the result directory) and
# exit. This submit about 15 jobs to the cluster (requiring 90
# cores). Jobs are submited only if there is less than $max_jobs jobs
# running.
#
# This script is made to be used with cron. For exemple adding this
# line to your crontab (with the command 'crontab -e') will run the
# script each hour, at xx:10, and log the results:
#
#    10 * * * * 3_analyze.sh >> cron.log  # full paths omited
#
# Copyright (C) 2016 by Alex Cristia, Mathieu Bernard


# will be created to store results
output_dir=${1:-./results}

# input data directory must exists and have a subdir
# per subcorpora, as generated in step 2
data_dir=${2:-./data}

# the segmentation pipeline
segmenter=${3:-../../algoComp/segment.py}


# because we use call this from cron, we must load the environment (to
# have sge modules loaded, qsub, python and so on...)
[ -f $HOME/.bashrc ] && . $HOME/.bashrc


# the maximum number of jobs we want to schedule in the waiting queue
max_jobs=100

# the number of jobs submited (waiting and running)
njobs=$(qstat -xml | tr '\n' ' ' |
               sed 's#<job_list[^>]*>#\n#g' |
               sed 's#<[^>]*>##g' | grep ' ' |
               column -t | wc -l)

# exit if we have already enough jobs submited
echo $(date) - $njobs jobs running
[ $njobs -gt $max_jobs ] && exit 0

# if we can submit new jobs, look for the next text to segment
for subcorpus in $(find $data_dir -maxdepth 1 -mindepth 1 -type d -exec basename {} \;)
do
    # create the output dir if needed
    mkdir -p $output_dir/$subcorpus

    for speaker in $(find $data_dir/$subcorpus -mindepth 1 -type d -exec basename {} \;)
    do
        result_dir=$output_dir/$subcorpus/$speaker

        # if the result directory exists, we assume the jobs already
        # have been submited
        # [ -d $result_dir ] && echo "found $subcorpus $speaker" && continue
        [ -d $result_dir ] && continue

        # else we submit them and exit
        echo "Clusterizing  $subcorpus $speaker"
        input_dir=$data_dir/$subcorpus/$speaker
        version=$subcorpus.$speaker

        $segmenter \
            --output-dir $result_dir \
            --algorithms all \
            --ag-median 5 \
            --clusterize \
            --jobs-basename $version \
            --goldfile $input_dir/gold.txt \
            $input_dir/tags.txt && exit 0 || exit 1
    done
done

# if we are here we've done with childes analysis
echo "All jobs have been submited !!"
exit 0
