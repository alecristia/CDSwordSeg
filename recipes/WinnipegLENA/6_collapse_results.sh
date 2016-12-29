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


header="version segmentation matching algo \
        token_f-score token_precision token_recall \
        boundary_f-score boundary_precision boundary_recall"
header=`echo $header | tr -s ' ' | tr ' ' '\t'`
echo $header > $data_dir/results.txt

for input_dir in $data_dir/WL_*
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

    for algo in `find $input_dir -name '*cfgold-res.txt' | sort`
    do
        # bring together the results
        algo_dir=`dirname $algo`
        algo_name=`basename $algo_dir | sed 's/3sf/3/'`

        line=`grep '[0-9]' $algo`
        echo $version $segmentation $matching $algo_name $line  |
            tr -s ' ' | tr ' ' '\t' >> $input_dir/results.txt
    done

    sed 1d $input_dir/results.txt >> $data_dir/results.txt
    echo
    echo Writed $data_dir/results.txt
done

exit
