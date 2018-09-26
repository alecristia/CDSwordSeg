#!/usr/bin/env bash
#
# Script for analyzing the different versions of Winnipeg corpora
#
# Copyright (C) 2016 by Alex Cristia, Mathieu Bernard

#########VARIABLES
#Variables that have been passed by the user
data_dir=$1
output_dir=$2
#########


# will be createed to store results
#output_dir=${1:-./results}

# input data directory must exists and have a 'matched' subdir
# containing the results of step 4
#data_dir=${2:-./data}


echo $data_dir $output_dir

source activate /cm/shared/apps/python-anaconda/envs/wordseg

module load python-anaconda boost

#NOTE: we rely on the full.txt generated in step 5

# Run all algos on all versions in parallel (on the cluster if available)
for input_tag in $data_dir/WL_ADS_LS/tags-13.txt $data_dir/WL_ADS_LS/tags-18.txt $data_dir/WL_CDS_HS/tags-14.txt
#$data_dir/WL_*/tags-1[0-9].txt
#tags-1[0-9].txt WL_*/tags-1[0-9].txt
do

# find out where to write
    version=`echo $input_tag | sed 's/.*WL/WL/' | sed 's/\/.*//'`
    resample=`basename $input_tag`

    # create the output dir if needed
    outfol=${output_dir}/${version}/${resample}/
    mkdir -p $outfol

echo prepare both versions of database ${output_dir}/${version}/${resample}/
#        cat $input_tag  | wordseg-prep --u phone --gold $outfol/gold.txt  > $outfol/prepared_p.txt
#        cat $input_tag  | wordseg-prep --u syllable  > $outfol/prepared_s.txt


# segment the prepared text with different fast algorithms 
  #on syll input
#	cat $outfol/prepared_s.txt | wordseg-baseline -P 1 > $outfol/segmented.baseline1.txt
#	cat $outfol/prepared_s.txt | wordseg-baseline -P 0 > $outfol/segmented.baseline0.txt
#	cat $outfol/prepared_s.txt | wordseg-tp -p forward -t relative > $outfol/segmented.tpFR.txt
#	cat $outfol/prepared_s.txt | wordseg-tp -p forward -t absolute > $outfol/segmented.tpFA.txt

  #on phone input
#	cat $outfol/prepared_p.txt | wordseg-puddle -w 2 > $outfol/segmented.puddle.txt
#        wordseg-dibs -t baseline -o $outfol/segmented.dibs_b.txt $outfol/prepared_p.txt full.txt
#        wordseg-dibs -t phrasal -o $outfol/segmented.dibs_p.txt $outfol/prepared_p.txt full.txt


echo running AGs


GRAMMAR=../../algoComp/algos/AG/grammars/Colloc0_enFestival.lt
CATEGORY=Colloc0
    echo "module load python-anaconda boost && \
          source activate /cm/shared/apps/python-anaconda/envs/wordseg && \
          cat $outfol/prepared_p.txt | wordseg-ag $GRAMMAR $CATEGORY --njobs 8 -vv > $outfol/segmented.ag.txt || exit 1" | 
	   qsub -S /bin/bash -V -cwd -j y -pe mpich 8 -N ag_$version_$resample 


#GRAMMAR=../../algoComp/algos/AG/grammars/Coll3syllfnc_enFestival.lt
#CATEGORY=Word

#    echo "module load python-anaconda boost && \
#          source activate /cm/shared/apps/python-anaconda/envs/wordseg && \
#          cat $outfol/prepared_p.txt | wordseg-ag $GRAMMAR $CATEGORY --njobs 8 -vv  \
#        | tee $outfol/segmented.ag3.txt || exit 1" \
#        | qsub -S /bin/bash -V -cwd -j y -pe mpich 8 -N ag3_$version_$resample || exit 1


while [[ `qstat | grep "acristia" | grep "tags" | wc -l` -gt 0 ]] ; do
    sleep 1
done

	for segmOut in $outfol/segmented.ag.txt ; do
		performance=`echo $segmOut | sed 's/segmented/performance/'`
                gold=`echo $segmOut | sed 's/segmented.*/gold.txt/'`
	        cat $segmOut | wordseg-eval $gold > $performance
	done

done
source deactivate

exit
