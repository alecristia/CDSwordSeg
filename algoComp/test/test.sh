#!/usr/bin/env bash

# Test of the dmcmc algorithm on a single input file. Trying to find
# the segfault...
#
# Mathieu Bernard

HERE=`readlink -f .`
ROOT=`readlink -f ../..`


../pipeline/dmcmc.sh $ABSPATH $KEYNAME $RESFOLDER
