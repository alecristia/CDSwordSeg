#!/bin/sh
# This script cuts the concatenated coprus into a choosen number of parts, adapted to be used in Bernstein
# (e.g. in half for the bilingual corpus, or in 10 sub-parts to perform several analysis of variance).
# Laia Fibla laia.fibla.reixachs@gmail.com 2017-03-22

##### Variables #####

#input="/fhgfs/bootphon/scratch/lfibla/seg/SegEngSpa/Bernstein/berns_all/adapted_corpus"
#output="/fhgfs/bootphon/scratch/lfibla/seg/SegEngSpa/Bernstein/berns_all/conc_eng"

input=$1
output=$2

divide=$3 # Modify this line to divide the corpus in a specific number of sub-parts

####################
rm -r ${output}

mkdir -p ${output}
mkdir -p ${output}/all/

for f in $input/*.txt
do
  max=`wc -l $f | grep -v "total" | awk '{print $1}'`
  n=$(( $max / $divide ))
echo dividing

  i=0
  while [ $i -lt $divide ]
  do
  #rm -r ${output}/${i}/*
  mkdir -p ${output}/${i}
  echo in while $i
      ini=$(( $i * $n + 1 ))
      fin=$(( $ini + $n - 1 ))

      sed -n ${ini},${fin}p ${input}/gold.txt >> ${output}/${i}/${i}-gold.txt
      mv ${output}/${i}/${i}-gold.txt ${output}/all/
      sed -n ${ini},${fin}p ${input}/tags.txt >> ${output}/${i}/${i}-tags.txt
      mv ${output}/${i}/${i}-tags.txt ${output}/all/
      rm -r ${output}/${i}/
  i=$(($i + 1 ))
  done
done

echo $output
