#folder="/fhgfs/bootphon/scratch/lfibla/SegCatSpa/RES_corpus_cat"
#RES_FOLDER="/fhgfs/bootphon/scratch/lfibla/SegCatSpa/conc_cat/res_conc/100"
raw=$1
output=$2

rm cat.txt
rm spa.txt
rm both.txt

ls ${raw}cat/*cutlines.txt > cat.txt
ls ${raw}spa/*cutlines.txt > spa.txt
nfiles=`wc -l cat.txt| awk '{print $1}'`


for (( i=1; i<=$nfiles; i++ ))
do
#  	j=$(( $i + 1 ))
#	j=$(( $i + 1 ))
	sed -n ${i}p cat.txt >> both.txt
	sed -n ${i}p spa.txt >> both.txt
done


max=`wc -l $(cat both.txt) | grep -v "total" | awk '{print $1}' | sort -nr | head -1`


for length in 2 100
do
	mkdir -p ${output}/$length/
	add=$(( $length - 1 ))

	i=1
	while [ $i -lt $max ]
	do

#echo in while $i
  		j=$(( $i + $add ))
        	for thisfile in $(cat both.txt)
        	do
#echo in for $thisfile
			 thisdir=$(dirname "$thisfile" )
			thistagfile=$(basename "$thisfile" -cutlines.txt)
          		sed -n $i,${j}p $thisfile >> ${output}/$length/gold.txt
          		sed -n $i,${j}p $thisdir/${thistagfile}-tags.txt >> ${output}/$length/tags.txt
	        done
	i=$(($i + $length ))
	done
	echo "creating gold versions"

  sed 's/;esyll//g'  < ${output}/$length/tags.txt |
    tr -d ' ' |
    sed 's/;eword/ /g' > ${output}/$length/gold.txt
done

echo $output
echo "done mixing lines for gold and tags for bilingual"
