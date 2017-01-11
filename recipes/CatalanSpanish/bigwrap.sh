#!/usr/bin/env bash
#
# Wrapper to run WinnipegLENA experiments 201511
# Alex Cristia <alecristia@gmail.com> 2015-11-26
# Mathieu Bernard


PROCESSED_FOLDER="/fhgfs/bootphon/scratch/lfibla/SegCatSpa/RES_corpus_spa"
CONCATENATED_FOLDER="/fhgfs/bootphon/scratch/lfibla/SegCatSpa/conc"


# Turn the cha-like files into a single clean file per type
#./2_cha2ortho.sh $PROCESSED_FOLDER  || exit 1

# Phonologize the ortholines files
#./3_ortho2phono.sh $PROCESSED_FOLDER  || exit 1

./3_laiconcatenate.sh $PROCESSED_FOLDER  $CONCATENATED_FOLDER
#input=${1:/fhgfs/bootphon/scratch/lfibla/SegCatSpa/RES_corpus}
#output=${2:/fhgfs/bootphon/scratch/lfibla/SegCatSpa/conc}

# Analyze
# ./4_analyze.sh $PROCESSED_FOLDER $RES_FOLDER

#rm $RES_FOLDER/results.txt
#rm $RES_FOLDER/WL*/results.txt
# ./5_collapse_results.sh $RES_FOLDER
