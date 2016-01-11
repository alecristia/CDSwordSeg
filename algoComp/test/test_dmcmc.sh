#!/usr/bin/env bash

bugfix=`readlink -f ../algos/phillips-pearl2014/bugfix.py`

# step 1: test bugfix.py on dummy input
# cat > tags <<EOF
# a
# b
# cd
# d
# EOF
# cp tags gold
# $bugfix tags gold tags2 gold2 -l 0 2
# cat tags2

# step 2: test bugfix on bernstein input
# bernstein_dir=/fhgfs/bootphon/scratch/mbernard/dev/CDSwordSeg/recipes/bernstein/test_dmcmc/ADS/dmcmc
# tags=$bernstein_dir/input.txt
# gold=$bernstein_dir/gold.txt
# cp $tags tags
# cp $gold gold
# $bugfix tags gold -t tags2 -g gold2 -l 0 258 3256
