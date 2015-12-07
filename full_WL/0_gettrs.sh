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
    TRS2=$DEST/`basename $TRS | cut -d_ -f1-2`.trs
    sed '/^>.*>$/d' $TRS | sed '/^$/d' > $TRS2
done
