#!/usr/bin/env bash

WL=${1:-./phono}

# SPECIAL STEP: Add length-matched versions of the CDS corpora - for
# now, only the lena-segmented (add human seg if results change) --
# WORD LENGTH MATCHING NOT WORKING
mkdir -p $WL/WL_CDS_LS_LineMatch

N=`wc -l "$WL/WL_ADS_LS/gold.txt" | cut -f1 -d' '`
head -n $N  $WL/WL_CDS_LS/gold.txt \
     > $WL/WL_CDS_LS_LineMatch/gold.txt

# in reality, this is unnecessary bec the n of lines doesn't change
# between gold and tags
N=`wc -l "$WL/WL_ADS_LS/tags.txt" | cut -f1 -d' '`
head -n $N  $WL/WL_CDS_LS/tags.txt \
     > $WL/WL_CDS_LS_LineMatch/tags.txt


mkdir -p $WL/WL_CDS_LS_WordMatch
tr -s ' ' < $WL/WL_ADS_LS/gold.txt |
    sed 's/ / toglue\n/g' > $WL/WL_ADS_LS/counting.tmp
N=`wc -l $WL/WL_ADS_LS/counting.tmp | cut -f1 -d' '`
tr -s ' ' < $WL/WL_CDS_LS/gold.txt |
    sed 's/ / toglue\n/g'  > $WL/WL_CDS_LS_WordMatch/counting.tmp
head -n $N $WL/WL_CDS_LS_WordMatch/counting.tmp \
     > $WL/WL_CDS_LS_WordMatch/counting_cut.tmp
awk '{if($NF~"toglue") \
     {mem=mem $0 " "} \
     else{print mem $0; mem="" }} \
     END{print mem}' \
    $WL/WL_CDS_LS_WordMatch/counting_cut.tmp |
    sed "s/ toglue//g" \
        > $WL/WL_CDS_LS_WordMatch/gold.txt

# MISSING: TAG VERSION, BUT THE ABOVE DOESN'T GIVE THE SAME N OF WORDS
# IN BOTH CORPORA
