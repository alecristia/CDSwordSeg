#!/usr/bin/env bash
#
# Create length-matched versions of ADS/CDS corpora.
#
# This script reduce the CDS/KDS versions to fit the number of
# lines/words of the ADS version. This is done both for human and Lena
# segmented transcriptions both for gold and tags files, as generated
# in step 3.
#
# Copyright (C) 2016 by Alex Cristia, Mathieu Bernard

#########VARIABLES
#Variables that have been passed by the user
data_dir=$1
#########

# input/output data directory must exists.
#data_dir=${1:-./data}

# path to the line_matcher and word_matcher scripts
script_dir=${2:-../../database_creation/scripts}



# location of the line_matcher and word_matcher scripts
line_matcher=$script_dir/line_matcher.sh
word_matcher=$script_dir/word_matcher.sh

# must contains phonologized files as created in step 3
input_dir=$data_dir/phono

# will be created to store matched files
output_dir=$data_dir/matched

# the different versions to process
seg_version="HS LS"
cds_version="CDS"  #removed KDS, we don't care about it anymore

# for Lena or Human segmented version
for seg in $seg_version
do
    # location of the ADS gold and tags files
    ads_dir=$input_dir/WL_ADS_$seg

    # for chid/key child directed speech
    for cds in $cds_version
    do
        # create subdir storing line-match and word-match versions
        mkdir -p $output_dir/WL_${cds}_${seg}_LM
        mkdir -p $output_dir/WL_${cds}_${seg}_WM

        # process both tags and gold files
        for file in tags gold
        do
            echo "matching version $seg $cds $file"
            in=$input_dir/WL_${cds}_$seg/$file.txt

            $line_matcher $in $ads_dir/$file.txt\
                          > $output_dir/WL_${cds}_${seg}_LM/$file.txt || exit 1

            # TODO here is a little dirty fix, because word matching
            # of KDS_HS add an empty line at the end of gold file ->
            # suppress any empty line.
            $word_matcher $in $ads_dir/$file.txt | sed '/^$/d'\
                          > $output_dir/WL_${cds}_${seg}_WM/$file.txt || exit 1
        done
    done
done

# Finally copy ADS and non-matched CDS/KDS in the output dir. CDS and
# KDS dirs are suffixed with NM for Non Matched.
cp -r $input_dir/WL_ADS* $output_dir
for seg in $seg_version; do
    for cds in $cds_version; do
        cp -r $input_dir/WL_${cds}_${seg} $output_dir
    done
done

exit
