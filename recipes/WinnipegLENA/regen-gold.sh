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

echo $data_dir $output_dir

source activate /cm/shared/apps/python-anaconda/envs/wordseg

module load python-anaconda boost


for input_dir in $data_dir/matched/WL_*
do

# find out where to write
    version=`basename $input_dir`

    # create the output dir if needed
    mkdir -p ${output_dir}/${version}/

echo prepare both versions of database $input_dir
        cat $input_dir/tags.txt  | wordseg-prep --u phone --gold ${output_dir}/${version}/gold.txt  > ${output_dir}/${version}/prepared_p.txt
        cat $input_dir/tags.txt  | wordseg-prep --u syllable  > ${output_dir}/${version}/prepared_s.txt


done
source deactivate

exit
