#!/usr/bin/env bash
#
# The first part of the bernstein recipe is to get a phonologized form
# of ADS and CDS data
#
# Mathieu Bernard

# Input arguments
PROCESSED_FOLDER=$1

PHONOLOGIZE=../../phonologization/scripts/phonologize
ALGOCOMP=../../algoComp

for resfolder in $PROCESSED_FOLDER/*/
do
	ortholines=${resfolder}ortholines.txt

    # CDS ortholines is huge (17k lines, split it in 1k lines parts
    # and phonologize them in parallel)
    echo -n Splitting $ortholines...
    temp=`mktemp -d eraseme-XXXX`
    splited=$temp/ortho-
    split -d $ortholines $splited
    echo 

echo $temp

    for ortho in $splited*
    do
        PART=`echo $ortho | sed 's/^.*-//'`
        echo -n "Phonologizing part $PART in a new job..."
        COMMAND="$PHONOLOGIZE $ortho ${ortho/ortho/tags}" #I don't understand the second variable
        JNAME=phonol-$PART
        JLOG=$temp/phonol-$PART.log
        $ALGOCOMP/clusterize.sh "$COMMAND" \
                                     "-V -cwd -j y -o $JLOG -N $JNAME" \
                                     > $ortho.pid
        grep "^Your job " $ortho.pid | cut -d' ' -f3 >> $temp/pids
        echo -n "pid is "
        tail -1 $temp/pids
    done

    $ALGOCOMP/clusterize_waitfor.sh $temp/pids
    cat ${splited/ortho/tags}* > $resfolder/tags.txt
    rm -rf $temp


    sed 's/;esyll//g' $resfolder/tags.txt |
        sed 's/ //g' |
        sed 's/;eword/ /g' |
        sed 's/ $//g' | tr -s ' ' > $resfolder/gold.txt
done

exit 0
