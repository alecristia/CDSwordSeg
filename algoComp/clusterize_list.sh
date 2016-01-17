#!/usr/bin/env bash
#
# This script detects if 'qsub' is installed on the machine and launch
# a given list of jobs accordingly. If 'qsub' is not detected, launch
# the jobs in a regular way, else schedule the job on the cluster.
#
# Eat a file containing one job command per line. Optionally eat a
# second file containing qsub options, one job per line.
#
# Copyright (C) 2016 by Mathieu Bernard


# silently detect for the 'qsub' executable
which qsub &> /dev/null

# run the jobs accordingly
if [ $? -ne 0 ]
then
    echo "qsub not detected on `hostname`"

    # the number of cores available
    ncores=`grep processor < /proc/cpuinfo | wc -l`

    while read job
    do
        $job &

        # from http://prll.sourceforge.net/shell_parallel.html
        while [[ $(jobs -p | wc -l) -ge $ncores ]] ; do sleep 0.33; done
    done < $1
  wait

else
    # TODO need to test this
    echo "scheduling jobs to the cluster"

    count=0
    njobs=`wc -l $1 | cut -f1 -d' '`
    while [[ $njobs -gt $count ]]
    do
        let count+=1
        job=`sed ${count}!d $1`
        if [ -z $2 ]
        then
            opt="-V -cwd -j y"
        else
            opt=`sed ${count}!d $2`
        fi
        echo $job | qsub $opt
    done
fi

exit
