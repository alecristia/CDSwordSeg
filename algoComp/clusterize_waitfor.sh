#!/usr/bin/env bash
#
# This script detects if 'qsub' is installed on the machine and wait
# for a given pid list to be finished, either locally or in the
# cluster.
#
# Author: Mathieu Bernard <mmathieubernardd@gmail.com>

# file containing a list of pids
LIST=$1

# Step 1: silently detect for the 'qsub' executable
which qsub &> /dev/null

# Step 2: run the JOB accordingly
if [ $? -ne 0 ]
then
    for pid in `cat $LIST`
    do
        echo waiting for $pid...
        wait $pid
        echo
    done
else
    echo wait for all jobs terminated...
    pids=`cat  $LIST | tr '\n' ',' | sed 's/,$//'`
    echo 'exit' |
        qsub -V -cwd -j y -sync yes \
             -hold_jid $pids \
             -N wait -o /dev/null > /dev/null
fi

exit
