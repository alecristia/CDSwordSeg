#!/usr/bin/env bash
#
# The first part of the bernstein recipe is to get a phonologized form
# of ADS and CDS data
#
# Mathieu Bernard

# Input arguments
RESFOLDER=${1:-./phono}
DATAPATH=${2:-oberon:/fhgfs/bootphon/scratch/mbernard/data/bernstein}
ROOT=${3:-../..}

SCRIPTS=$ROOT/database_creation/scripts
PHONOLOGIZE=$ROOT/phonologization/scripts/phonologize

mkdir -p $RESFOLDER

# In that data folder, ADS is already phonologized, just copy tags and
# gold in the results folder
scp -r $DATAPATH/ADS $RESFOLDER

# But CDS is in cha format, need to preprocess it
CDS=$RESFOLDER/CDS
mkdir -p $CDS

# Copy cha input
mkdir -p $CDS/cha
scp $DATAPATH/CDS/*.cha $CDS/cha

# cha to ortho
mkdir -p $CDS/ortho
inclines=$CDS/ortho/includedlines.txt
ortho=$CDS/ortho/ortholines.txt
touch $inclines
for f in $CDS/cha/*.cha
do
    $SCRIPTS/cha2sel.sh $f $inclines
done
$SCRIPTS/selcha2clean.sh $inclines $ortho

# ortho to phono
echo Phonologizing CDS

# CDS ortholines is huge (17k lines, split it in 1k lines parts and
# phonologize them in parallel)
ortholines=$CDS/ortho/ortholines.txt
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
cat ${splited/ortho/tags}* > $CDS/tags.txt
rm -rf $temp

sed 's/;esyll//g' $CDS/tags.txt |
    sed 's/ //g' |
    sed 's/;eword/ /g' |
    sed 's/ $//g' | tr -s ' ' > $CDS/gold.txt
