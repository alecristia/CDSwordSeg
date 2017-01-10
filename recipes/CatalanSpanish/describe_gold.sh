#!/bin/sh
# 2016-12-30

#########VARIABLES
#Variables that have been passed by the user
RESFOLDER= /fhgfs/bootphon/scratch/lfibla/SegCatSpa/RES_corpus_cat
#########


#write header of the fiel
header="doc nutt nswu nwtok nwtyp nhapax awl"
echo $header > $RESFOLDER/stats.txt


#declare useful function
function countchar()
{
    while IFS= read -r i; do printf "%s" "$i" | tr -dc "$1" | wc -m; done
}

for thisfile in $RESFOLDER/*gold.txt; do

	keyname=$(basename "$thisfile" -gold.txt)
    #utterance level descriptors
        nutt=`wc -l $thisfile | awk '{print $1}'` #number of utterances

	countchar ' ' < $thisfile > $RESFOLDER/${keyname}-uttlen.txt  #calculate a distribution of utterance lengths, used in next step and might be useful in the future

	nswu=`grep " 1$" < $RESFOLDER/${keyname}-uttlen.txt | awk '{print $1}'` #number of single word utterances

    #word level descriptors
        nwtok=`wc -w $thisfile | awk '{print $1}'` #number of word tokens

        tr ' ' '\n' < $thisfile | sort | uniq -c | awk '{print $2" "$1}' | sort -r > $RESFOLDER/${keyname}-wordfreq.txt #used in next step -- also, this can be pull up & reanalyzed later to get: frequency distribution, special vocabulary

	nwtyp=`wc -l $RESFOLDER/${keyname}-wordfreq.txt | awk '{print $1}'` #number of word types

	nhapax=`grep " 1$" $RESFOLDER/${keyname}-wordfreq.txt | wc -l | awk '{print $1}'` #number of word types with a frequency of 1 (hapax)

	sed 's/;esyll//g' < $RESFOLDER/${keyname}-tags.txt | sed 's/ ;eword/%/g' | tr '%' '\n' | sed  '/^$/d' | awk '{print NF}' | sort | uniq -c > $RESFOLDER/${keyname}-wordlen.txt #distribution of word length;  used in the next step and also might be useful in the future

	awl=`awk '{ total += $1*$2 ; nw +=$1} END {print total/nw}' < $RESFOLDER/${keyname}-wordlen.txt` #average word length in number of phonemes

	#MATTR
        x=1
	x2=$(($x+10))
	touch mattr.tmp
        while [ $x2 -lt $nutt ]
        do
          	sed -n ${x},${x2}p $thisfile > chunk.tmp
                tok=`wc -w chunk.tmp | awk '{print $1}'`
               typ=`tr ' ' '\n' < chunk.tmp | sort | uniq -c | wc -l | awk '{print $1}'`
		tt="$typ $tok"
                echo $tt >> mattr.tmp
		x=$(($x+10))
		x2=$(($x+10))

        done
	mattr=`awk '{ total += $1/$2} END {print total/NR}' < mattr.tmp`


	thisline="$thisfile $nutt $nswu $nwtok $nwtyp $nhapax $awl"

	echo $thisline >> stats.txt

rm *.tmp

done
