#!/bin/sh
# WRAPPER for chaCleanUp to run selected talkBank corpora, document by document
# IMPORTANT!! Includes data selection
# Alex Cristia alecristia@gmail.com 2015-08-25
#NOT automatized!!! 

#########VARIABLES
#Variables that have been passed by the user
CDS="/Users/acristia/Documents/databases/Providence/"
ADS1="/Users/acristia/Documents/databases/CMU/"
ADS2="/Users/acristia/Documents/databases/SCoSe/"
RESFOLDER="/Users/acristia/Documents/tests/res_multicor/"
LANGUAGE="english"
 

#Do the CDS, notice there is a subselection - only docs where there are no adults other than mot

for CHILD in $CDS*
   do
    #echo "$CHILD"

    for DOC in $CHILD/*.cha
       do
        #echo "$DOC"
        #grep "@ID" < $DOC | sed 's/^.*|||[^$]//' | sed 's/|||$//' | sort | uniq -c > ppntcnt.tmp
        #grep "@ID" < $DOC | sed 's/^.*dence|//' | sed 's/|.*$//'  >> participants.txt
        NADULTS=`grep "@ID" < $DOC | grep -v 'SI.\|BR.\|CHI\|TO.\|ENV\|BOY\|NON' | wc -l`
        #echo "$NADULTS"
        if [ $NADULTS == 1 ];  then
            tmp=`echo "$CHILD" | tr -d '/'`
            KEYNAME=`echo "$DOC" | tr -d '/' | sed s/"$tmp"// | sed 's/\.cha//'`
            AGE=`grep '@ID' < "$DOC" | grep 'CHI' | sed 's/^.*CHI|//' | sed 's/|.*$//' | sed 's/;/_/' | sed 's/\./_/'`
            KEYNAME=`echo "$KEYNAME"_"$AGE"`
            ./chaFileCleanUp_human.text $KEYNAME $DOC $RESFOLDER $LANGUAGE
		./cleanCha2phono_human.text $KEYNAME $RESFOLDER $LANGUAGE
#NB: For some reason I fail to understand, the preceding line will not run if I use the same number of spaces found in the previous line (it's probably something to do with the preceding command not being "closed", because if I comment the cleanup line out, the cha2phono line works; and if I leave the cleanup line uncommented and start the cha2phono at the beginning of the line, or as here after tabs, then it also works. What a mystery!
        fi

    done
done


for CHILD in $ADS1*
   do
    for DOC in $CHILD/*.cha
       do
            tmp=`echo "$CHILD" | tr -d '/'`
            KEYNAME=`echo "$DOC" | tr -d '/' | sed s/"$tmp"// | sed 's/\.cha//'`
            KEYNAME=`echo "$KEYNAME"_"CMU"`
            ./chaFileCleanUp_human.text $KEYNAME $DOC $RESFOLDER $LANGUAGE
./cleanCha2phono_human.text $KEYNAME $RESFOLDER $LANGUAGE

    done
done

for DOC in $ADS2*
   do
            tmp=`echo "$ADS2" | tr -d '/'`
            KEYNAME=`echo "$DOC" | tr -d '/' | sed s/"$tmp"// | sed 's/\.cha//'`
            KEYNAME=`echo "$KEYNAME"_"SCS"`
            ./chaFileCleanUp_human.text $KEYNAME $DOC $RESFOLDER $LANGUAGE
./cleanCha2phono_human.text $KEYNAME $RESFOLDER $LANGUAGE
done



