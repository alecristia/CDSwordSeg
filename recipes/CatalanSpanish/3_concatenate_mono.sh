#!/bin/sh
# Script to concatenate each two and each 100 lines. To be used for monolingual cat and monolingual spa
# Laia Fibla and Alex Cristia laia.fibla.reixachs@gmail.com 2017-01-10

###### Variables #######

# Adapt the following variables, being careful to provide absolute paths

#input="/fhgfs/bootphon/scratch/lfibla/SegCatSpa/RES_corpus_cat"
#output="/fhgfs/bootphon/scratch/lfibla/SegCatSpa/conc_cat"

input=$1
output=$2

echo $input $output

for s in $input/*gold.txt
do
thistagfile=$(basename "$s" -gold.txt)
        max=`wc -l $s | grep -v "total" | awk '{print $1}'`
        n=$(( ($max / 100)*100 ))
echo cutting
        head -$n $s > ${input}/${thistagfile}-cutlines.txt
        head -$n ${input}/${thistagfile}-tags.txt > ${input}/${thistagfile}-cutlines.txt
done

max=`wc -l $input/*cutlines.txt | grep -v "total" | awk '{print $1}' | sort -nr | head -1`

for length in 4 100
do
  rm -r ${output}/$length/
  mkdir -p ${output}/$length/
  add=$(( $length - 1 ))

  i=1
  while [ $i -lt $max ]
  do
    j=$(( $i + $add ))
    for thisfile in $input/*cutlines.txt
    do
      thistagfile=$(basename "$thisfile" -cutlines.txt)
      sed -n $i,${j}p $input/${thistagfile}-cutlines.txt >> ${output}/$length/tags.txt
    done
  i=$(($i + $length ))
  done
  echo "creating gold versions"

  sed 's/;esyll//g'  < ${output}/$length/tags.txt |
    tr -d ' ' |
    sed 's/;eword/ /g' > ${output}/$length/gold.txt
done

echo "done mixing lines for gold and tags"
