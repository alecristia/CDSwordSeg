#!/bin/bash

childes=/fhgfs/bootphon/scratch/mbernard/dev/CDSwordSeg/recipes/childes

[ ! -d $childes ] && { echo "error: not found $childes"; exit 1; }

script=$childes/3_analyze.sh
results=$childes/results
data=$childes/data
segment=$(readlink -f $childes/../../algoComp/segment.py)

$script $results $data $segment >> $childes/cron.log || exit 1

exit 0
