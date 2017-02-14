#!/usr/bin/env bash
#
# Create length-matched versions of ADS/CDS corpora.
#
# This script reduce the CDS versions to fit the number of lines/words
# of the ADS version. This is done both both for gold and tags files,
# as generated in the previous step.
#
# Copyright (C) 2016 by Alex Cristia, Mathieu Bernard

# input/output data directory must exists.
#data_dir=${1:-./data}
data_dir=$1

# path to the line_matcher and word_matcher scripts
script_dir=../../database_creation/scripts
line_matcher=$script_dir/line_matcher.sh
word_matcher=$script_dir/word_matcher.sh

# must contains phonologized files as created in previous step 
# location of the C/ADS gold and tags files
input_dir=$data_dir/CDS
ads_dir=$data_dir/ADS

# will be created to store matched files
output_dir=$data_dir/matched


# create subdir storing line-match and word-match versions
mkdir -p $output_dir/CDS_LM
mkdir -p $output_dir/CDS_WM

# process both tags and gold files
for file in tags gold
do
    echo "matching CDS $file"
    in=$input_dir/$file.txt

    $line_matcher $in $ads_dir/$file.txt \
                  > $output_dir/CDS_LM/$file.txt || exit 1

    # TODO here is a little dirty fix, because word matching
    # of KDS_HS add an empty line at the end of gold file ->
    # suppress any empty line.
    $word_matcher $in $ads_dir/$file.txt \
        | sed '/^$/d' > $output_dir/CDS_WM/$file.txt || exit 1
done

# Finally copy ADS and non-matched CDS in the output dir. CDS dir is
# suffixed with NM for Non Matched.
cp -r $data_dir/ADS $output_dir/ADS_NM
cp -r $data_dir/CDS $output_dir/CDS_NM

exit
