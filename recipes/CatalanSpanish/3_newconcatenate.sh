folder="../processed_corpora/arglongitudinal_res/Audio1_res"
max=`wc -l $folder/*/*ortholines.txt | grep -v "total" | awk '{print $1}' | sort -nr | head -1` 

i=1
while [ $i -lt $max ]  
do 
	j=$(( $i + 99)) 
	for thisfile in $folder/*/*ortholines.txt;
	do
		sed -n $i,${j}p $thisfile >> test_${i}.txt 
	done
	i=$(($i + 100)) 
done
