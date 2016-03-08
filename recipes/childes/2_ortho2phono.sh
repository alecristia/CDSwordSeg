#!/usr/bin/env bash
#
# phonologize ortholines files from the childes database : convert
# each ortholines.txt in the data folder in tags.txt and gold.txt

#input directory where to look for ortholines
src=${1:-./data}

# root directory of the CDSwordSeg project
root=${3:-../..}

# phonologization script
phonologize=$root/phonologization/scripts/phonologize



# we need a temporary directory (to store pids)
temp=`mktemp -d ./eraseme-XXXX`

echo "phonologizing ortholines files in parallel..."
for file in `find $src -name ortholines.txt -type f`
do
    key=`basename $(dirname $file)`
    name=`basename $(dirname $(dirname $file))`_$key

    tags=${file/ortholines/tags}
    # echo -n "Phonologizing $name in a new job..."
    command="$phonologize $file $tags"
    jname=phonol-$name
    jlog=$temp/phonol-$name.log
    $root/algoComp/clusterize.sh "$command" \
                                 " -V -cwd -j y -o $jlog -N $jname" \
                                 > $temp/$name.pid
    grep "^Your job " $temp/$name.pid | cut -d' ' -f3 >> $temp/pids
    #echo -n " pid is "
    #    tail -1 $temp/pids
done

$root/algoComp/clusterize_waitfor.sh $temp/pids
rm -rf $temp

echo -n "creating gold files..."
for file in `find $src -name tags.txt -type f`
do
    sed 's/;esyll//g' $file |
        sed 's/ //g' |
        sed 's/;eword/ /g' |
        sed 's/ $//g' | tr -s ' ' > ${file/tags/gold}
done

echo " done"

exit
