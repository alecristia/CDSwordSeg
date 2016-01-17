#!/usr/bin/env bash
#
# This script detects if 'qsub' is installed on the machine and launch
# a given job according to that. If 'qsub' is not detected, launch the
# job in a regular way, else schedule the job on the cluster
#
# Example:
#
# ./clusterize.sh ls        # This run ls either on local host or the cluster
# ./clusterize.sh "ls -la"  # Note the quotes for commands including spaces
#
# Copyright 2015 Mathieu Bernard <mmathieubernardd@gmail.com>

# Step 0: parse input arguments
JOB=$1
JOBNAME=`echo $JOB | cut -d' ' -f1`
JOBNAME=`basename $JOBNAME`

# options being passed to qsub
OPT=${2:-"-V -cwd -j y -N $JOBNAME"}

# Step 1: silently detect for the 'qsub' executable
which qsub &> /dev/null

# Step 2: run the JOB accordingly
if [ $? -ne 0 ]
then
    # TODO missing & at the end but seems to not work very well...
    $JOB &
    echo "Your job $! (\"$JOBNAME\") running on `hostname`"
else
    # run the job on the cluster
    echo "$JOB" | qsub $OPT
fi

exit
