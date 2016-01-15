#!/usr/bin/env bash

#########VARIABLES###########################
RESFOLDER=${1:-./results}
PHONFOLDER=${2:-./data}
PIPELINE=${3:-../../algoComp/segment.py}
#########

mkdir -p $RESFOLDER

tags=$PHONFOLDER/tags.txt
gold=$PHONFOLDER/gold.txt

$PIPELINE --goldfile $gold \
          --output-dir $RESFOLDER \
          --algorithms all \
          --clusterize \
          --jobs-basename childes \
          $tags
