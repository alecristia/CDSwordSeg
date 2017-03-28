#!/bin/sh
# This file cuts the concatenated coprus into a choosen number of parts
# (e.g. in half for the bilingual corpus or in 10 sub-parts to perform several analysis of variance).
# Laia Fibla laia.fibla.reixachs@gmail.com 2017-03-22

##### Variables #####

input="/fhgfs/bootphon/scratch/lfibla/seg/SegCatSpa/conc_spa"
output="/fhgfs/bootphon/scratch/lfibla/seg/SegCatSpa/conc_spa_10"

#input=$1
#output=$2

#divide=2 # Modify this line to divide the corpus in a specific number of sub-parts


for f in $input/*/tags.txt
do
thistagfile=$(basename "$s" -gold.txt)
  mkdir -p ${output} 
  max= wc -l $f
  n=$(( $max / 10 ))
echo dividing
#  head -$n $input/*/tags.txt > ${input}/${thistagfile}-cutlines.txt

  #add=$(( $divide - 1 ))

  i=1
  while [ $i -lt $n ]
  do

  #echo in while $i
    #	j=$(( $i + $add ))

      sed -n $i,${n}p $thistagfile >> ${output}/*[0-10]/gold.txt
      sed -n $i,${n}p $thistagfile >> ${output}/*[0-10]/tags.txt
  done

  echo "creating gold versions"

  sed 's/;esyll//g'  < ${output}/*[0-10]/tags.txt |
    tr -d ' ' |
    sed 's/;eword/ /g' > ${output}/*[0-10]/gold.txt
done

echo $output
echo "done"
