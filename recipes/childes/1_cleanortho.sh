#!/usr/bin/env bash
# clean up the childes ortholines before phonologization

input=${1:-./data/ortholines.txt}
output=${input/.txt/-clean.txt}

# remove a line which is '‹ ›'
sed -e '/‹ ›/d' $input > $output
