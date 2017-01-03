#!/usr/bin/env bash
#
# get the WinnipegLENA trs files from a SRC directory (by default on
# oberon) and move them to DEST/trs

#########VARIABLES
#Variables that have been passed by the user
SRC=$1
DEST=$2
#########

#SRC=${1:-oberon:/fhgfs/bootphon/scratch/acristia/data/WinnipegLENA/trs}
#DEST=${2:-./data}/trs
#DEST="/fhgfs/bootphon/scratch/acristia/processed_corpora/WinnipegLENA"

# copy the files from SRC to DEST
mkdir -p $DEST/raw
mkdir -p $DEST/trs

scp $SRC/*.trs $DEST/raw || exit 1

# simplify names to remove date and FINAL
for TRS in $DEST/raw/*.trs
do
    TRS2=`basename $TRS | cut -d_ -f1-2`
    TRS2=`echo $TRS2 | sed "s/-\[[0-9]*//g" | sed "s/FINAL.*//g"`
    TRS2=$DEST/trs/$TRS2.trs
    mv $TRS $TRS2
done

rm -rf $DEST/raw
