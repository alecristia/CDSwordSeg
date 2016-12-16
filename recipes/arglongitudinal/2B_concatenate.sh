ORIGFOLDER="/fhgfs/bootphon/scratch/aiturralde/RES_FOLDER"

# merge the subcorpora -- this is super ugly and needs to be fixed

for CORPUSFOLD in ${ORIGFOLDER}/*DS/NS*; do	
	cd $CORPUSFOLD
	mkdir -p COMPDAT

	for j in ${CORPUSFOLD}/[01]*-gold.txt; do
        	cat $j >> COMPDAT/gold.txt
	done


	for j in ${CORPUSFOLD}/[01]*-tags.txt; do
        	cat $j >> COMPDAT/tags.txt
	done
done

