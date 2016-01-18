#!/usr/bin/env bash
#
# Script for bringing together the results generated in step 5.
#
# Copyright (C) 2016 by Alex Cristia, Mathieu Bernard


# Must exists an dcontains the results (works also on partial results)
# of step 5
data_dir=${1:-./results}


header="version algo token_f-score token_precision token_recall \
        boundary_f-score boundary_precision boundary_recall"
header=`echo $header | tr -s ' ' | tr ' ' '\t'`
echo $header > $data_dir/results.txt

for input_dir in $data_dir/WL_*
do
    version=`basename $input_dir | sed 's/WL_//'`

    # Populate the cfgold.txt file for each version
    echo $header > $input_dir/cfgold.txt

    for algo in `find $input_dir -name '*cfgold-res.txt' | sort`
    do
        # bring together the results
        algo_dir=`dirname $algo`
        algo_name=`basename $algo_dir`

        line=`grep '[0-9]' $algo`
        echo $version $algo_name $line |
            tr -s ' ' | tr ' ' '\t' >> $input_dir/cfgold.txt
    done

    sed 1d $input_dir/cfgold.txt >> $data_dir/results.txt
done

exit
