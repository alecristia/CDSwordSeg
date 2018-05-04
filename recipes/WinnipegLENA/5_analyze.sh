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


#For dibs We prepare a version of the corpus that contains the 4 corpora (CDS/ADS x HS/LS) concatenated 
#rm full.txt
#for input_dir in $data_dir/matched/WL_*
#do
#        cat $input_dir/tags.txt >> full.txt
	# NOTE! >> is on purpose; we want stats to be based on both CDS and ADS, HS and LS
#done 

# Run all algos on all versions in parallel (on the cluster if available)
for input_dir in $data_dir/matched/WL_* 
#WL_CDS_HS
do

# find out where to write
    version=`basename $input_dir`

    # create the output dir if needed
    mkdir -p ${output_dir}/${version}/

echo prepare both versions of database $input_dir
        cat $input_dir/tags.txt  | wordseg-prep --u phone --gold ${output_dir}/${version}/gold.txt  > ${output_dir}/${version}/prepared_p.txt
#        cat $input_dir/tags.txt  | wordseg-prep --u syllable  > ${output_dir}/${version}/prepared_s.txt


# segment the prepared text with different fast algorithms 
  #on syll input
#	cat ${output_dir}/${version}/prepared_s.txt | wordseg-baseline -P 1 > ${output_dir}/${version}/segmented.baseline1.txt
#	cat ${output_dir}/${version}/prepared_s.txt | wordseg-baseline -P 0 > ${output_dir}/${version}/segmented.baseline0.txt
#	cat ${output_dir}/${version}/prepared_s.txt | wordseg-tp -p forward -t relative > ${output_dir}/${version}/segmented.tpFR.txt
#	cat ${output_dir}/${version}/prepared_s.txt | wordseg-tp -p forward -t absolute > ${output_dir}/${version}/segmented.tpFA.txt

  #on phone input
#	cat ${output_dir}/${version}/prepared_p.txt | wordseg-puddle -w 2 > ${output_dir}/${version}/segmented.puddle.txt
#        wordseg-dibs -t baseline -o ${output_dir}/${version}/segmented.dibs_b.txt ${output_dir}/${version}/prepared_p.txt full.txt
#        wordseg-dibs -t phrasal -o ${output_dir}/${version}/segmented.dibs_p.txt ${output_dir}/${version}/prepared_p.txt full.txt

   #slow algos

GRAMMAR=../../algoComp/algos/AG/grammars/Colloc0_enFestival.lt
CATEGORY=Colloc0
echo $GRAMMAR $CATEGORY

    echo "module load python-anaconda boost && \
          source activate /cm/shared/apps/python-anaconda/envs/wordseg && \
          cat ${output_dir}/${version}/prepared_p.txt | wordseg-ag $GRAMMAR $CATEGORY --njobs 8 -vv  \
        | tee ${output_dir}/${version}/segmented.ag.txt || exit 1" \
        | qsub -S /bin/bash -V -cwd -j y -pe mpich 8 -N wl_ag_$version || exit 1

#GRAMMAR=../../algoComp/algos/AG/grammars/Coll3syllfnc_enFestival.lt
#CATEGORY=Word
#echo $GRAMMAR $CATEGORY
#    echo "module load python-anaconda boost && \
#          source activate /cm/shared/apps/python-anaconda/envs/wordseg && \
#          cat ${output_dir}/${version}/prepared_p.txt | wordseg-ag $GRAMMAR $CATEGORY --njobs 8 -vv  \
#        | tee ${output_dir}/${version}/segmented.ag3.txt || exit 1" \
#        | qsub -S /bin/bash -V -cwd -j y -pe mpich 8 -N wl_ag3_$version || exit 1

while [[ `qstat | grep "acristia" | grep "wl_" | wc -l` -gt 0 ]] ; do
    sleep 1
done

	for segmOut in ${output_dir}/${version}/segmented*.txt ; do
		performance=`echo $segmOut | sed 's/segmented/performance/'`
	        cat $segmOut | wordseg-eval ${output_dir}/${version}/gold.txt > $performance
	done
done
source deactivate

exit
