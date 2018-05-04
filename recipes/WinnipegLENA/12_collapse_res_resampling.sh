#!/usr/bin/env bash
#
# Script for bringing together the results generated in step 5.
#
# Copyright (C) 2016 by Alex Cristia, Mathieu Bernard

#########VARIABLES
#Variables that have been passed by the user
data_dir=$1
#########

# Must exists and contains the results (or partial results) of step 5
#data_dir=${1:-./results}


header="version segmentation matching resample algo \
        token_precision token_recall token_fscore \
        type_precision type_recall type_fscore \
        boundary_precision boundary_recall boundary_fscore"
header=`echo $header | tr -s ' ' | tr ' ' '\t'`
echo $header > $data_dir/results.txt

echo Inspecting $data_dir

for input_dir in $data_dir/WL_*/
do
    corpus=`basename $input_dir | sed 's/WL_//'`
    version=`echo $corpus | cut -d'_' -f 1`
    segmentation=`echo $corpus | cut -d'_' -f 2`
    matching=`echo ${corpus: -2}`
    case $matching in
        'LM' | 'WM' ) # word or line matching
        ;;
        * )
            matching='NM' # non matched
    esac

    echo -n Collapsing $version $segmentation $matching...

    # Populate the cfgold.txt file for each version
    echo $header > $input_dir/results.txt

    for algo in $input_dir/*/performance*.txt
    do
        # bring together the results
        resample=`echo $algo | sed 's/.*tag//' `
        algo_dir=`echo $algo | sed 's/.*performance.//' | sed 's/.txt//'`
        algo_name=`echo $algo_dir | sed 's/3sf/3/'` #fix for AG3sf

        line=`cat $algo | awk '{print $2}' | tr '\n' ' '`
        echo $version $segmentation $matching $resample $algo_name $line  |
            tr -s ' ' | tr ' ' '\t' >> $input_dir/results.txt
    done

    sed 1d $input_dir/results.txt >> $data_dir/results.txt
    echo
    echo Wrote $data_dir/results.txt
done

exit

