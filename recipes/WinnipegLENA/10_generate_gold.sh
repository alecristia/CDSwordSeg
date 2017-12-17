#!/usr/bin/env bash
# Wrapper to take a bunch of tags and generate the golds

#########VARIABLES
#Variables that have been passed by the user
datafolder=$1
#########

for f in $datafolder/*/tags-*.txt
do
    gold=`echo $f | sed 's/tags/gold/'`
    echo "creating gold version for $f"
    sed 's/;esyll//g' $f |
        sed 's/ //g' |
        sed 's/;eword/ /g' |
        sed 's/ $//g' | tr -s ' ' > $gold
done

exit
