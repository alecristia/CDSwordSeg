folder="/fhgfs/bootphon/scratch/lfibla/SegCatSpa/conc_cat"
RES_FOLDER="/fhgfs/bootphon/scratch/lfibla/SegCatSpa/conc_cat/res_conc"

max=`wc -l $folder/*gold.txt | grep -v "total" | awk '{print $1}' | sort -nr | head -1`

i=1
while [ $i -lt $max ]
do
  	j=$(( $i + 99))
        for thisfile in $folder/*gold.txt;
        do
          	sed -n $i,${j}p $thisfile |
		sed 's/^ //' >> ${RES_FOLDER}/100_gold.txt
        done
	i=$(($i + 100))
echo "done gold"
done

i=1
while [ $i -lt $max ]
do
  	j=$(( $i + 99))
        for thisfile in $folder/*tags.txt;
        do
          	sed -n $i,${j}p $thisfile |
		sed 's/^ //' >> ${RES_FOLDER}/100_tags.txt
        done
	i=$(($i + 100))
echo "done tags"
done
