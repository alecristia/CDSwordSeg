#!/usr/bin/env bash
#
for j in /scratch1/users/acristia/results/WinnipegLENA_resamples/*/*/performance.ag*.txt
do
	nlines=`wc -l $j | awk '{print $1}'`
echo $nlines
if [ "$nlines" -lt 1 ]; then

echo removing $j
rm $j

else 

echo $j ok
fi
done
