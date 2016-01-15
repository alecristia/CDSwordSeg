#!/usr/bin/env bash
# get the CHILDES ortholines files from oberon

SRC=/fhgfs/bootphon/scratch/xcao/Alex_CDS_ADS/res_Childes_Eng-NA_cds
DEST=${1:-./data/ortholines.txt}
SUFFIX=-ortholines.txt

mkdir -p `dirname $DEST`

files=`find $SRC -name "*$SUFFIX" -type f`
nfiles=`echo $files | wc -w`
echo "$0 : There is $nfiles ortholines files in childes"

rm -f $DEST
for ortho in $files
do
    echo "Copying `basename $ortho $SUFFIX`"
    cat $ortho >> $DEST
done

nlines=`wc -l $DEST | cut -d' ' -f1`
echo "Writed $nlines lines in $DEST"
