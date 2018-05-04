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

# containing the results of previous step 
#data_dir=${2:-./data}

echo $data_dir $output_dir

source activate /cm/shared/apps/python-anaconda/envs/wordseg

module load python-anaconda boost


#For dibs We prepare a version of the corpus that contains the 4 corpora (CDS/ADS x HS/LS) concatenated 
#rm full.txt
#for input_dir in $data_dir/matched/*/
#do
#        cat $input_dir/tags.txt >> full.txt
	# NOTE! >> is on purpose; we want stats to be based on both CDS and ADS, HS and LS
#done 

# Run all algos on all versions in parallel (on the cluster if available)
for input_dir in $data_dir/matched/*/
do

# find out where to write
    version=`basename $input_dir`

    # create the output dir if needed
    mkdir -p ${output_dir}/${version}/

echo prepare both versions of database
        cat $input_dir/tags.txt  | wordseg-prep --u phone --gold gold.txt  > prepared_p.txt
#        cat $input_dir/tags.txt  | wordseg-prep --u syllable  > prepared_s.txt


# segment the prepared text with different fast algorithms 
  #on syll input
#	cat prepared_s.txt | wordseg-baseline -P 1 > segmented.baseline1.txt
#	cat prepared_s.txt | wordseg-baseline -P 0 > segmented.baseline0.txt
#	cat prepared_s.txt | wordseg-tp -p forward -t relative > segmented.tpFR.txt
#	cat prepared_s.txt | wordseg-tp -p forward -t absolute > segmented.tpFA.txt

  #on phone input
#	cat prepared_p.txt | wordseg-puddle -w 2 > segmented.puddle.txt
#        wordseg-dibs -t baseline -o segmented.dibs_b.txt prepared_p.txt full.txt
#        wordseg-dibs -t phrasal -o segmented.dibs_p.txt prepared_p.txt full.txt

   #slow algos
#        cat prepared_s.txt | wordseg-dpseg --njobs 5 -vv $dmcmc_params | tee segmented.dmcmc.txt 

GRAMMAR=../../algoComp/algos/AG/grammars/Colloc0_enFestival.lt
CATEGORY=Colloc0
#BAD	cat prepared_p.txt | wordseg-ag $GRAMMAR $CATEGORY --njobs 1 > segmented.ag.txt
    echo "module load python-anaconda boost && \
          source activate /cm/shared/apps/python-anaconda/envs/wordseg && \
          cat prepared_p.txt | wordseg-ag $GRAMMAR $CATEGORY --njobs 8 -vv  \
        | tee segmented.ag.txt || exit 1" \
        | qsub -S /bin/bash -V -cwd -j y -pe mpich 8 -N ag_berns_$version || exit 1


GRAMMAR=../../algoComp/algos/AG/grammars/Coll3syllfnc_enFestival.lt
CATEGORY=Word
#BAD	cat prepared_p.txt | wordseg-ag $GRAMMAR $CATEGORY --njobs 1 > segmented.ag3sf.txt | qsub -V -cwd
    echo "module load python-anaconda boost && \
          source activate /cm/shared/apps/python-anaconda/envs/wordseg && \
          cat prepared_p.txt | wordseg-ag $GRAMMAR $CATEGORY --njobs 8 -vv  \
        | tee segmented.ag3.txt || exit 1" \
        | qsub -S /bin/bash -V -cwd -j y -pe mpich 8 -N ag3_berns_$version || exit 1


while [[ `qstat | grep "acristia" | grep "berns" | wc -l` -gt 0 ]] ; do
    sleep 1
done


	for segmOut in segmented*.txt ; do
		performance=`echo $segmOut | sed 's/segmented/performance/'`
	        cat $segmOut | wordseg-eval gold.txt > $performance
	done
	mv *ag*.txt ${output_dir}/${version}/.
#        mv  ${output_dir}/${version}/full.txt .
done
source deactivate

exit
