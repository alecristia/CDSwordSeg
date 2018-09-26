#!/usr/bin/env bash
#
# Script for analyzing the different versions of Winnipeg corpora
#
# Copyright (C) 2016 by Alex Cristia, Mathieu Bernard

#########VARIABLES
#Variables that have been passed by the user
output_dir=$1
#########


# will be createed to store results
#output_dir=${1:-./results}

# input data directory must exists and have a 'matched' subdir
# containing the results of step 4
#data_dir=${2:-./data}

echo $output_dir

source activate /cm/shared/apps/python-anaconda/envs/wordseg

module load python-anaconda boost

#/scratch1/users/acristia/results/WinnipegLENA/WL_ADS_HS/
for segmOut in $output_dir/WL_*/*/segmented*
do

	gold="$(dirname $segmOut)/gold.txt" 
	echo $segmOut $gold
#        gold=`echo $segmOut | sed 's/segmented.*/gold.txt/'`
	performance=`echo $segmOut | sed 's/segmented/performance/'`
	cat $segmOut | wordseg-eval $gold > $performance
done
source deactivate

exit
