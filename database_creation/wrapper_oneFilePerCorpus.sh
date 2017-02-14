#!/bin/sh
# Wrapper to clean up a whole corpus and store it as a single transcript
# Alex Cristia alecristia@gmail.com 2015-10-26

#########VARIABLES
#Variables to modify
KEYNAME="buckeye_phono" #pick a nice name for your phonological corpus, because this keyname will be used for every output file!
CHAFOLDER="/fhgfs/bootphon/data/derived_data/BUCKEYE_revised_bootphon/" #must exist and contain cha files - NOTICE THE / AT THE END OF THE NAME
RESFOLDER="/fhgfs/bootphon/scratch/elarsen/CDSwordSeg/recipes/buckeye/" #will be created and loads of output files will be stored there - NOTICE THE / AT THE END OF THE NAME


#oberon versions
#CHAFOLDER="/fhgfs/bootphon/scratch/acristia/data/Interview/" #must exist and contain cha files - NOTICE THE / AT THE END OF THE NAME
#RESFOLDER="/fhgfs/bootphon/scratch/acristia/results/201510_bernsteinads/"   #will be created and loads of output files will be stored there - NOTICE THE / AT THE END OF THE NAME

#########

mkdir $RESFOLDER

inclines="$RESFOLDER${KEYNAME}-includedlines.txt"
ortho="$RESFOLDER${KEYNAME}-ortholines.txt"

touch $inclines

for f in ${CHAFOLDER}*/*/*.cha #modification 5 nov 2016
   do
#	echo "$f"

	bash ./scripts/cha2sel.sh $f $inclines

done

  bash ./scripts/selcha2clean.sh $inclines $ortho

echo "done"
