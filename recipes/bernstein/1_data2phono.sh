#!/usr/bin/env bash
#
# The first part of the bernstein recipe is to get a phonologized form
# of ADS and CDS data
#
# Mathieu Bernard

# Input arguments
RESFOLDER=${1:-./data}
DATAPATH=${2:-oberon:/fhgfs/bootphon/scratch/acristia/data}
ROOT=${3:-../..}

SCRIPTS=$ROOT/database_creation/scripts
PHONOLOGIZE=$ROOT/phonologization/scripts/phonologize

mkdir -p $RESFOLDER

# in the data folder, both ADS and CDS are in cha format, we need to
# preprocess them
for corpus in ADS CDS
do
    resfolder=$RESFOLDER/$corpus
    mkdir -p $resfolder

    echo Copy cha input for $corpus
    mkdir -p $resfolder/cha
    scp $DATAPATH/Bernstein_$corpus/*.cha $resfolder/cha

    echo Converting cha files to ortholines
    mkdir -p $resfolder/ortho
    inclines=$resfolder/ortho/includedlines.txt
    ortho=$resfolder/ortho/ortholines.txt
    touch $inclines
    for f in $resfolder/cha/*.cha
    do
        $SCRIPTS/cha2sel.sh $f $inclines
    done
    $SCRIPTS/selcha2clean.sh $inclines $ortho

    # ortho to phono
    echo Phonologizing $corpus
    mkdir -p $resfolder/phono

    # CDS ortholines is huge (17k lines, split it in 1k lines parts
    # and phonologize them in parallel)
    ortholines=$resfolder/ortho/ortholines.txt
    echo -n Splitting $ortholines...
    temp=`mktemp -d ./eraseme-XXXX`
    splited=$temp/ortho-
    split -d $ortholines $splited
    echo

    for ortho in $splited*
    do
        PART=`echo $ortho | sed 's/^.*-//'`
        echo -n "Phonologizing part $PART in a new job..."
        COMMAND="$PHONOLOGIZE $ortho ${ortho/ortho/tags}"
        JNAME=phonol-$PART
        JLOG=$temp/phonol-$PART.log
        $ROOT/algoComp/clusterize.sh "$COMMAND" \
                                     "-V -cwd -j y -o $JLOG -N $JNAME" \
                                     > $ortho.pid
        grep "^Your job " $ortho.pid | cut -d' ' -f3 >> $temp/pids
        echo -n "pid is "
        tail -1 $temp/pids
    done

    $ROOT/algoComp/clusterize_waitfor.sh $temp/pids
    cat ${splited/ortho/tags}* > $resfolder/phono/tags.txt
    rm -rf $temp

    sed 's/;esyll//g' $resfolder/phono/tags.txt |
        sed 's/ //g' |
        sed 's/;eword/ /g' |
        sed 's/ $//g' | tr -s ' ' > $resfolder/phono/gold.txt
done

exit 0
