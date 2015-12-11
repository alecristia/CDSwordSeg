#!/usr/bin/env bash
#Converting trs files to CHILDES-like format
#Alex Cristia alecristia@gmail.com 2015-11 comparison
#this version generates three versions of the corpus: adult directed
#only, child directed only, and directed to the key child only

#########VARIABLES

# must exist and contain trs files
TRSFOLDER=/home/mbernard/scratch/dev/CDSwordSeg/full_WL/trs

# will be created and output cha files will be stored there
CHAFOLDER=${TRSFOLDER/trs/cha}
mkdir -p $CHAFOLDER


#Step 1: generate a file that contains only sentences we want
for TRS in $TRSFOLDER/*.trs
do
    # remove path and extension part of the path
    BASE=$CHAFOLDER/`basename ${TRS/.trs/}`

    # focus on lines which contain | codes, because they may contain
    # transcriptions
    grep "|" $TRS |
        tr -d '\r' |
        # remove LENA labels
        sed 's/CRY//g' |
        sed 's/SIL//g' | # silence
        sed 's/BBL//g' | # babble
        sed 's/VOC//g' | # speech-like
        sed 's/VFX//g' | # fixed
        # remove every line that haven't been transcribed, since they
        # start with |
        tr -s ' ' | grep -v '^ |' | grep -v '^|' |
        # remove the LENA codes for interaction if any.
        # NOTE '?' added at begining to make 1st pipe optional
        sed -r 's/(\|?[BRE]C\|[0-9]*\|[0-9]*\|[0-9]*\|[A-Z/]*\|[A-Z]*\|[A-Z]*)(|.\|.\|.*\|.\|$)/ \2/g' |
        # NOTE added for debug (can be removed ?)
        tr -s ' ' | sed 's/^ //g' |
        # break down sentences coded together in the same turn with a
        # long intervening silence (.) into two separate lines
        tr '.' '\n' |
        # remove sentences that start with numbers because those are overlaps
        grep -v '^[0-9]' |
        # remove ugly characters
        sed 's/&lt;//g' |
        sed 's/&gt;//g' |
        sed "s/i'i/i/g" |
        tr -d '\r' |
        sed -r 's/([a-z])(\|)/\1 \2/g' |
        # NOTE remove words ending with ^
        sed 's/[a-zA-Z]*\^//g' |
        # remove utterances by the target child
        grep -v ' |T|' |
        # remove utterances by an uncertain child
        grep -v ' |C|' |
        # remove utterances by another child
        grep -v ' |O|' |
        # remove utterances by an uncertain person
        grep -v ' |U|' |
        # remove utterances that are initiated and cut by an overlap...
        grep -v '|I[0-9]' |
        # ...as well as their continuations
        grep -v '|C[0-9]' |
        tr -s ' ' > $BASE.clean


    # In the next phase, we create the line selections
    # VERSION 1: to analyze only the adult-directed speech
    grep -e ' |.|A' $BASE.clean > ${BASE}_ADS.txt

    # VERSION 2: to analyze only the TARGET CHILD child-directed speech
    grep -e ' |.|T' $BASE.clean > ${BASE}_CDS.txt

    # another version, just to check against Melanie's pipeline
    grep -e ' |.|T' -e ' |.|O' -e ' |.|C' $BASE.clean > ${BASE}_KDS.txt


    # create a version reflecting segments glued together by humans

    # trick to glue together the lines that are considered
    # continuations (without overlap)
    # NOTE was sed -r 's/I\|.\|/toglue/'
    sed -r 's/\|?.\|.\|I\|.\|/toglue/' $BASE.clean |
        awk '{if($NF~"toglue") \
             {mem=mem $0 " "} \
             else{print mem $0; mem="" }} \
             END{print mem}' |
        sed "s/toglue//g" |
        tr -s ' ' | sed '/^$/d' > $BASE.glued

    # VERSION 1: to analyze only the adult-directed speech - human
    # style segmentation
    grep -e ' |.|A' $BASE.glued > ${BASE}_ADS_humanseg.txt

    #VERSION 2: to analyze only the TARGET CHILD child-directed speech
    #-human style segmentation
    grep  -e ' |.|T' $BASE.glued > ${BASE}_CDS_humanseg.txt

    #another version, just to check against Melanie's pipeline
    grep  -e ' |.|T' -e ' |.|O' -e ' |.|C' $BASE.glued > ${BASE}_KDS_humanseg.txt
done


#Step 2: Fake CHILDES format lines
for TXT in $CHAFOLDER/*.txt
do
    # use CHILDES code for father (FAT) for all Male adult LENA
    # utterances
    sed '/ |M/ s/[a-z]*/\*FAT: &/' $TXT |
        # use CHILDES code for mother (MOT) for all Female adult LENA
        # utterances
        sed '/ |F/ s/[a-z]*/\*MOT: &/' |
        # add SIBLING at the beginning (same for all "other child"
        # utterances
        sed '/ |O/ s/[a-z]*/\*SIB: &/' |
        sed 's/|[A-Z][A-Z]/ /g' |
        sed 's/|./ /g' |
        # NOTE some isolated F appears after lines glueing, remove them
        sed 's/ F / /g' |
        # NOTE some hmm, hmmm are badly phonologized, replace them by hum
        sed -r 's/hmm+/hum/g' |
        # remove | and duplicated spaces
        tr -d '|' | tr -s ' ' > ${TXT/.txt/.cha}

    nl=`wc -l $TXT | cut -f1 -d' '`
    nw=`wc -w $TXT | cut -f1 -d' '`
    echo `basename $TXT` $nl $nw >> ${CHAFOLDER}/summary
done

# Put the cleaned files LENA/Human segmented CDS, ADS and KDS in
# subfolders
for DS in ADS CDS KDS
do
    mkdir -p $CHAFOLDER/WL_${DS}_LS
    for file in $CHAFOLDER/*${DS}.cha
    do
        file2=$CHAFOLDER/WL_${DS}_LS/`basename $file | cut -d_ -f1-2`.cha
        mv $file $file2
    done

    mkdir -p $CHAFOLDER/WL_${DS}_HS
    for file in $CHAFOLDER/*${DS}_humanseg.cha
    do
        file2=$CHAFOLDER/WL_${DS}_HS/`basename $file | cut -d_ -f1-2`.cha
        mv $file $file2
    done
done

# clean up
rm -f $CHAFOLDER/*.clean $CHAFOLDER/*.glued $CHAFOLDER/*.txt
