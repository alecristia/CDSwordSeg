folder="/fhgfs/bootphon/scratch/lfibla/SegCatSpa/conc_bi"
RES_FOLDER="/fhgfs/bootphon/scratch/lfibla/SegCatSpa/conc_bi/res_conc/100/"

max=`wc -l $folder/*gold.txt | grep -v "total" | awk '{print $1}' | sort -nr | head -1`

i=1
while [ $i -lt $max ]
do
  	j=$(( $i + 99))
        for thisfile in $folder/*gold.txt;
        do
          	sed -n $i,${j}p $thisfile >> ${RES_FOLDER}/gold.txt
        done
	i=$(($i + 100))
done

i=1
while [ $i -lt $max ]
do
  	j=$(( $i + 99))
        for thisfile in $folder/*tags.txt;
        do
          	sed -n $i,${j}p $thisfile >> ${RES_FOLDER}/tags.txt
        done
	i=$(($i + 100))
done

echo "done mixing lines for gold and tags"
