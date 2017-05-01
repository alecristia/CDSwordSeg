#!/bin/bash

algo=${1:-dibs}
opts=${2:-""}

# the directory where we put the intermediate data and results
data=$(mktemp -d)
trap "rm -rf $data" EXIT

# the input text to segment
cat $(dirname ${BASH_SOURCE[0]})/segmentation/test/data/tags.txt | sort -R | head -30 > $data/tags.txt

# build the gold version
cat $data/tags.txt | wordseg-gold > $data/gold.txt

# segmentation at phoneme level
cat $data/tags.txt | wordseg-prep -u phoneme | wordseg-$algo $opts > $data/seg.$algo.txt

# evaluation
cat $data/seg.$algo.txt | wordseg-eval -g $data/gold.txt

# echo 'Input text'
# echo '----------'
# cat $data/tags.txt
# echo

# echo 'Gold'
# echo '----'
# cat $data/gold.txt
# echo

# echo 'segmentation'
# echo '------------'
# cat $data/seg.$algo.txt
