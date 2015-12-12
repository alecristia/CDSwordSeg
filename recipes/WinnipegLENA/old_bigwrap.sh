# Wrapper to run WinnipegLENA experiments 201511
# Alex Cristia <alecristia@gmail.com> 2015-11-26

#move to the location of the CDSWordSeg analysis suite
cd /fhgfs/bootphon/scratch/acristia/CDSwordSeg

# Step 1: Create the databases
cd database_creation

# 1.1 Turn the trs files into cha-like format
#FYI:
#TRSFOLDER="/fhgfs/bootphon/scratch/acristia/data/WinnipegLENA/trs/" #must exist and contain trs files
#CHAFOLDER="/fhgfs/bootphon/scratch/acristia/data/WinnipegLENA/cha/" #will be created and output cha files will be stored there

./trs2cha_201511.text

# 1.2 Turn the cha-like files into a single clean file per type
./wrapper_oneFilePerCorpus_201511.sh


# Step 2: Phonologize
cd ../phonologization

./wrapper_oneFilePerCorpus_201511.sh

# SPECIAL STEP: Add length-matched versions of the CDS corpora - for now, only the lena-segmented (add human seg if results change) -- WORD LENGTH MATCHING NOT WORKING

mkdir "/fhgfs/bootphon/scratch/acristia/results/WinnipegLENA/WL_CDS_LS_LineMatch/"

N=`wc -l "/fhgfs/bootphon/scratch/acristia/results/WinnipegLENA/WL_ADS_LS/WL_ADS_LS-gold.txt" | cut -f1 -d' '`
head -n $N  "/fhgfs/bootphon/scratch/acristia/results/WinnipegLENA/WL_CDS_LS/WL_CDS_LS-gold.txt" > "/fhgfs/bootphon/scratch/acristia/results/WinnipegLENA/WL_CDS_LS_LineMatch/WL_CDS_LS_LineMatch-gold.txt"

N=`wc -l "/fhgfs/bootphon/scratch/acristia/results/WinnipegLENA/WL_ADS_LS/WL_ADS_LS-tags.txt" | cut -f1 -d' '`  #in reality, this is unnecessary bec the n of lines doesn't change between gold and tags
head -n $N  "/fhgfs/bootphon/scratch/acristia/results/WinnipegLENA/WL_CDS_LS/WL_CDS_LS-tags.txt" > "/fhgfs/bootphon/scratch/acristia/results/WinnipegLENA/WL_CDS_LS_LineMatch/WL_CDS_LS_LineMatch-tags.txt"


mkdir "/fhgfs/bootphon/scratch/acristia/results/WinnipegLENA/WL_CDS_LS_WordMatch/"
tr -s ' ' < "/fhgfs/bootphon/scratch/acristia/results/WinnipegLENA/WL_ADS_LS/WL_ADS_LS-gold.txt" | sed 's/ / toglue\n/g' > "/fhgfs/bootphon/scratch/acristia/results/WinnipegLENA/WL_ADS_LS/counting.tmp"
N=`wc -l "/fhgfs/bootphon/scratch/acristia/results/WinnipegLENA/WL_ADS_LS/counting.tmp" | cut -f1 -d' '`
tr -s ' ' <  "/fhgfs/bootphon/scratch/acristia/results/WinnipegLENA/WL_CDS_LS/WL_CDS_LS-gold.txt" | sed 's/ / toglue\n/g'  > "/fhgfs/bootphon/scratch/acristia/results/WinnipegLENA/WL_CDS_LS_WordMatch/counting.tmp"
head -n $N  "/fhgfs/bootphon/scratch/acristia/results/WinnipegLENA/WL_CDS_LS_WordMatch/counting.tmp" > "/fhgfs/bootphon/scratch/acristia/results/WinnipegLENA/WL_CDS_LS_WordMatch/counting_cut.tmp"
awk '{if($NF~"toglue"){mem=mem $0 " "}else{print mem $0; mem="" }}END{print mem}' "/fhgfs/bootphon/scratch/acristia/results/WinnipegLENA/WL_CDS_LS_WordMatch/counting_cut.tmp" | sed "s/ toglue//g" > "/fhgfs/bootphon/scratch/acristia/results/WinnipegLENA/WL_CDS_LS_WordMatch/WL_ADS_LS_WordMatch-gold.txt"


# MISSING: TAG VERSION, BUT THE ABOVE DOESN'T GIVE THE SAME N OF WORDS IN BOTH CORPORA

#Step 3: Analyze
cd ../algoComp
./segment_one_corpus_201511.sh


#step 4: bring together the results
RESFOLDER="/fhgfs/bootphon/scratch/acristia/results/WinnipegLENA/"
grep '[0-9]' $RESFOLDER*/_*cfgold.txt > ${RESFOLDER}_results.txt
