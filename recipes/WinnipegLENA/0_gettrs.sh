#!/usr/bin/env bash
# get the WinnipegLENA trs files from oberon

SRC=oberon:/fhgfs/bootphon/scratch/acristia/data/WinnipegLENA/trs
DEST=${1:-./trs}

# copy the files from SRC to DEST
mkdir -p $DEST/raw
scp $SRC/*.trs $DEST/raw

# simplify names to remove date and FINAL
for TRS in $DEST/raw/*.trs
do
    TRS2=`basename $TRS | cut -d_ -f1-2`
    TRS2=`echo $TRS2 | sed "s/-\[[0-9]*//g" | sed "s/FINAL.*//g"`
    TRS2=$DEST/$TRS2.trs
    mv $TRS $TRS2
done

rm -rf $DEST/raw
