#!/usr/bin/env bash
# Wrapper to take a single cleaned up transcript and phonologize it
# 2015-11-26 - adapted to the winnipeglena corpus in its 4 versions

#########VARIABLES
#Variables that have been passed by the user
datafolder=$1
#########
#datafolder=`readlink -f ${1:-./data}`
root=`readlink -f ${2:-../..}` #Hmmm


phonologize=$root/phonologization/scripts/phonologize
clusterize=$root/algoComp

# must exist and contain ortholines files
ortfolder=$datafolder/ortho

# will be created to store phonologized files
resfolder=$datafolder/phono
mkdir -p $resfolder

# to store intermediate files
temp=`mktemp -d $resfolder/eraseme-XXXX`

# create command for each corpus version
list_cmd=$temp/cmd
list_opt=$temp/opt
rm -rf $list_cmd $list_opt
for subdir in `find $ortfolder/WL_* -type d`
do
    version=`basename ${subdir#$resfolder}`
    name=phonol-$version
    mkdir -p $resfolder/$version

    echo "$phonologize $subdir/ortholines.txt $resfolder/$version/tags.txt" >> $list_cmd
    echo "-V -cwd -j y -o $temp/$name.log -N $name" >> $list_opt
done

# run them in parallel
$clusterize/clusterize_list.sh $list_cmd $list_opt
rm -rf $temp

# TODO remove this loop and generate gold within the phonolgize step
for subdir in `find $ortfolder/WL_* -type d`
do
    version=`basename ${subdir#$resfolder}`

    echo "creating gold versions for $version"
    sed 's/;esyll//g' $resfolder/$version/tags.txt |
        sed 's/ //g' |
        sed 's/;eword/ /g' |
        sed 's/ $//g' | tr -s ' ' > $resfolder/$version/gold.txt
done

exit
