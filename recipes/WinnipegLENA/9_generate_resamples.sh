#!/bin/sh
# Script to concatenate transcripts to generate N samples of M length in number of lines
# Alex Cristia alecristia@gmail.com 2017-11-03

###### Variables #######
nsamples=10
mlength=1000

# Adapt the following variables, being careful to provide absolute paths
#input="/fhgfs/bootphon/scratch/lfibla/SegCatSpa/RES_corpus_cat"
#output="/fhgfs/bootphon/scratch/lfibla/SegCatSpa/conc_cat"

#or just read in vars provided by user
input=$1 
output=$2

echo $input $output #just to check

for subdir in `find $input/WL_* -type d`
do
    version=`basename ${subdir#$input}`
    mkdir -p $output/$version
    ls $input/$version/*-tags.txt > $output/$version/filelist.txt
#echo $output/$version/filelist.txt
    for sample in `seq $nsamples`
    do
#echo $sample
    	thisout=$output/$version/tags-${sample}.txt
    	touch $thisout
    	sort -R  $output/$version/filelist.txt > $output/$version/filelist_${sample}.txt
    	counter=1
    	while [ `wc -l $thisout | awk '{print $1}' ` -lt $mlength ]
    	do
#wc -l $thisout
#echo $output/$version/filelist_${sample}.txt
	    chosen=`sed "${counter}q;d" $output/$version/filelist_${sample}.txt`
#echo $chosen has been chosen

	    cat $chosen >> $thisout
	    let "counter++"
#echo $counter
    	done
    	#store final list that has been concatenated
    	head -$counter $output/$version/filelist_${sample}.txt > $output/$version/filelist-${sample}.txt
	rm $output/$version/filelist_${sample}.txt
    done
done
