#!/usr/bin/env bash
# get the WinnipegLENA trs files from oberon

HOST=oberon
SRC=/fhgfs/bootphon/scratch/acristia/data/WinnipegLENA/trs
DEST=/home/mbernard/dev/CDSwordSeg/full_WL/trs

# copy the files from SRC to DEST
mkdir -p $DEST
scp $HOST:$SRC/*.trs $DEST

# simplify names to remove date and FINAL
for TRS in $DEST/*.trs
do
    TRS2=$DEST/`basename $TRS | cut -d_ -f1`.trs
    mv $TRS $TRS2
done
