#!/usr/bin/env bash
# Wrapper to take a set of single cleaned up transcript and phonologize it
# 2017-01-02

#########VARIABLES
#Variables that have been passed by the user
datafolder=$1
root=$2
#########

PHONOLOGIZE=$root/phonologization/scripts/phonologize
ALGOCOMP=$root/algoComp

# will be created to store ortholines files
ortfolder=$datafolder/ortho
mkdir -p $ortfolder
mv $datafolder/*ortholines.txt $ortfolder/

# will be created to store phonologized files
resfolder=$datafolder/phono

temp=`mktemp -d eraseme-XXXX`

for thisortho in $ortfolder/*ortholines.txt
do
	tagfilename=${thisortho/ortholines/tags}
	goldfilename=${thisortho/ortholines/gold}
        COMMAND="$PHONOLOGIZE $thisortho $tagfilename" 
        $ALGOCOMP/clusterize.sh "$COMMAND" \
                                     "-V -cwd -j y -o $thisortho.log -N $thisortho" \
                                     > $thisortho.pid
        grep "^Your job " $thisortho.pid | cut -d' ' -f3 >> $temp/pids
        echo -n "pid is "
        tail -1 $temp/pids
    	$ALGOCOMP/clusterize_waitfor.sh $temp/pids
	rm -rf $temp

    sed 's/;esyll//g' $tagfilename |
        sed 's/ //g' |
        sed 's/;eword/ /g' |
        sed 's/ $//g' | tr -s ' ' > $goldfilename

done


exit
