#!/usr/bin/env bash
#
# Take two input files $1 and $2 and, with n1 and n2 the number of
# words in $1 and $2 respectively, output the 'min(n2, n1)' first
# words of $1 on stdout, while respecting line breaks.
#
# The word separator is ';eword' if present in 1st line of $1. Else
# the word separator is ' '.
#
# Copyright (C) 2016 by Alex Cristia, Mathieu Bernard

# guess the word separator
if [[ `head -n 1 $1` == *";eword"* ]]; then
    sep=";eword"

    # count words in files
    n1=`grep -o "$sep" < $1 | wc -l`
    n2=`grep -o "$sep" < $2 | wc -l`
    n=$(($n2<$n1?$n2:$n1))

    # print $n words of $1
    count=0
    while read line; do
        for word in $line; do
            out="$out $word"
            if [[ $word == $sep ]]; then
                let count+=1
                [[ $count -ge $n ]] && echo $out && exit
            fi
        done
        echo $out
        out=
    done < $1
else # the word separator is ' '
    # count words in files
    n1=`wc -w $1 | cut -f1 -d' '`
    n2=`wc -w $2 | cut -f1 -d' '`
    n=$(($n2<$n1?$n2:$n1))

    # print $n words of $1
    count=0
    while read line; do
        for word in $line; do
            let count+=1
            [[ $count -gt $n ]] && echo $out && exit
            out="$out $word"
        done
        echo $out
        out=
    done < $1
fi
