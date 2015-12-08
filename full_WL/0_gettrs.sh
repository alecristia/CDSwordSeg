#!/usr/bin/env bash
# get the WinnipegLENA trs files from oberon

HOST=oberon
SRC=/fhgfs/bootphon/scratch/acristia/data/WinnipegLENA/trs
DEST=/home/mbernard/scratch/dev/CDSwordSeg/full_WL/trs

# copy the files from SRC to DEST
mkdir -p $DEST/raw
scp $HOST:$SRC/*.trs $DEST/raw

# simplify names to remove date and FINAL
for TRS in $DEST/raw/*.trs
do
    TRS2=`basename $TRS | cut -d_ -f1-2`
    TRS2=`echo $TRS2 | sed "s/-\[[0-9]*//g" | sed "s/FINAL.*//g"`
    TRS2=$DEST/$TRS2.trs
    mv $TRS $TRS2
done

rm -rf $DEST/raw
