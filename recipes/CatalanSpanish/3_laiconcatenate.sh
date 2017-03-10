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
echo everything ok
        #head -$n $s > ${s}-cutlines.txt
        head -$n $s > ${thistagfile}-cutlines.txt
        head -$n ${input}/${thistagfile}-tags.txt > ${input}/${thistagfile}-cutlines.txt
echo multiples of 100
done

max=`wc -l $input/*cutlines.txt | grep -v "total" | awk '{print $1}' | sort -nr | head -1`

for length in 2 100
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
      sed -n $i,${j}p $thisfile >> ${output}/$length/gold.txt
      sed -n $i,${j}p $input/${thistagfile}-cutlines.txt >> ${output}/$length/tags.txt
    done
  i=$(($i + $length ))
  done
done

echo "done mixing lines for gold and tags"
