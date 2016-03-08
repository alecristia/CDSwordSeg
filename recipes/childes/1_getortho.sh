#!/usr/bin/env bash
#
# get the CHILDES ortholines files from oberon

src=${1:-/fhgfs/bootphon/scratch/xcao/Alex_CDS_ADS/res_Childes_Eng-NA_cds}
dest=${2:-./data}
mkdir -p $dest

# copy of ortholines files and simplification of data directories :
# copy from $src/CORPUS_res/KEY_ads/KEY-ortholines.txt to
# $dest/CORPUS/KEY/ortholines.txt
for file in `find $src -name "*ortholines.txt" -type f`
do
    # if file is not empty (weist corpus contains empty files)
    if [ -s $file ]
    then
        # create and simplify output path from input
        output=`echo ${file/$src/} | sed -e 's/_cds//' -e 's/_res//'`
        key=`echo $output | cut -d'/' -f3`
        output=`echo $dest$output | sed "s|/$key-|/|"`

        # copy the file (create subdirs as needed) while removing
        # lines matching '‹ ›'
        mkdir -p `dirname $output`
        sed -e '/‹ ›/d' $file > $output
    fi
done
