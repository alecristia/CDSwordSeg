#folder="/fhgfs/bootphon/scratch/lfibla/SegCatSpa/RES_corpus_cat"
#RES_FOLDER="/fhgfs/bootphon/scratch/lfibla/SegCatSpa/conc_cat/res_conc/100"
input=$1
output=$2

echo $input $output

max=`wc -l $input/*gold.txt | grep -v "total" | awk '{print $1}' | sort -nr | head -1`


for length in 2 100
do
	mkdir -p ${output}/$length/
	add=$(( $length - 1 ))

	i=1
	while [ $i -lt $max ]
	do

echo in while $i
  		j=$(( $i + $add ))
        	for thisfile in $input/*-gold.txt;
        	do
echo in for $thisfile
			thistagfile=$(basename "$thisfile" -gold.txt)
          		sed -n $i,${j}p $thisfile >> ${output}/$length/gold.txt
          		sed -n $i,${j}p $input/${thistagfile}-tags.txt >> ${output}/$length/tags.txt
	        done
	i=$(($i + $length ))
	done
done

echo "done mixing lines for gold and tags"
