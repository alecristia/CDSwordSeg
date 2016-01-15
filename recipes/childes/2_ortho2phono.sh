#!/usr/bin/env bash

#########VARIABLES
ORTFILE=${1:-./data/ortholines-clean.txt}
RESFOLDER=${2:-./data}
ROOT=${3:-../..}
#########

PHONOLOGIZE=$ROOT/phonologization/scripts/phonologize

mkdir -p $RESFOLDER

echo "phonologizing $ORTFILE in $RESFOLDER/tags.txt"

# ortholines is huge (260k lines, split it in 1k lines parts and
# phonologize them in parallel)
ortholines=$ORTFILE
echo -n Splitting $ortholines...
temp=`mktemp -d ./eraseme-XXXX`
splited=$temp/ortho-
split -a 4 -d $ortholines $splited
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

# concat the 1k lines parts into one big output file
$ROOT/algoComp/clusterize_waitfor.sh $temp/pids
cat ${splited/ortho/tags}* > $RESFOLDER/tags.txt
rm -rf $temp

echo "creating gold versions $RESFOLDER/gold.txt"
sed 's/;esyll//g' $RESFOLDER/tags.txt |
    sed 's/ //g' |
    sed 's/;eword/ /g' |
    sed 's/ $//g' | tr -s ' ' > $RESFOLDER/gold.txt

exit
