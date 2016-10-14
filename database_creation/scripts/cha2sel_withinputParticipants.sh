#!/usr/bin/env bash
# SELECTING speakers from cha files in prep to generating a phono format
# IMPORTANT!! Includes data selection
# Alex Cristia alecristia@gmail.com 2015-10-26

#########VARIABLES
#Variables that have been passed by the user
CHAFILE=$1
SELFILE=$2
RESFOLDER=$3
INCPARTS=$4
#########


echo "selecting $INCPARTS from $CHAFILE"



tr '\015' '\n' < "$CHAFILE"  |
   grep '^*'   |
   grep "${INCPARTS}" > $RESFOLDER$SELFILE


#iconv -t ISO-8859-1 ||

#    
 #  grep "$INCPARTS"
