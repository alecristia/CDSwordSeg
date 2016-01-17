#!/usr/bin/env bash
#
# Take two input files $1 and $2 and, with n1 and n2 the number of
# lines in $1 and $2 respectively, output the 'min(n2, n1)' first
# lines of $1 on stdout.
#
# Copyright (C) 2016 by Alex Cristia, Mathieu Bernard

n1=`wc -l $1 | cut -f1 -d' '`
n2=`wc -l $2 | cut -f1 -d' '`
n=$(($n2<$n1?$n2:$n1))

head -n $n $1 || exit 1
