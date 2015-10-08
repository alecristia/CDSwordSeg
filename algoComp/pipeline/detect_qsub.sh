#!/usr/bin/env bash

# This script detects if 'qsub' is installed on the machine and launch
# a given job according to that. If 'qsub' is not detected, launch the
# job in a regular way, else schedule the job on the cluster and wait
# it is terminated.
#
# Example:
#
# ./detect_qsub.sh ls        # This run ls either on local host or the cluster
# ./detect_qsub.sh "ls -la"  # Note the quotes for commands including spaces

# Author: Mathieu Bernard <mmathieubernardd@gmail.com>

# Step 0: parse input arguments
JOB=$1

# Step 1: detect for the 'qsub' executable
which qsub

if [ $? -ne 0 ]; then
    echo qsub not detected, running the job regularly

    $JOB

else
    echo Found qsub... scheduling job

    echo $JOB | qsub -V -cwd
fi
