#!/bin/sh
# Script to create an artificial bilingual corpus
# by concatenating two monolingual corpora (e.g. cat and spa) each 4 and each 100 lines.
# Laia Fibla and Alex Cristia laia.fibla.reixachs@gmail.com 2017-01-16

###### VARIABLES #######

raw=$1 # paths aleaddy provided by the user e.g. in the bigwrap, otherwise include them
output=$2

########################

rm cat.txt # in case you re-run this script
rm spa.txt
rm both.txt

ls ${raw}cat/*cutlines.txt > cat.txt   # extract catalan input
ls ${raw}spa/*cutlines.txt > spa.txt   # extract cspanish input
nfiles=`wc -l cat.txt| awk '{print $1}'`


for (( i=1; i<=$nfiles; i++ ))
do
#  	j=$(( $i + 1 ))
#	j=$(( $i + 1 ))
	sed -n ${i}p cat.txt >> both.txt
	sed -n ${i}p spa.txt >> both.txt
done


max=`wc -l $(cat both.txt) | grep -v "total" | awk '{print $1}' | sort -nr | head -1`

# here you mix corpus from two diferent languages each 4 and 100 lines recreating a kind of codeswithcing. If you want to created other mixtures e.g. each 20 lines, modify those numbers
for length in 4 100
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
