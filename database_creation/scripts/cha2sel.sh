#!/bin/sh
# SELECTING speakers from cha files in prep to generating a phono format
# IMPORTANT!! Includes data selection
# Alex Cristia alecristia@gmail.com 2015-10-26

#########VARIABLES
#Variables that have been passed by the user
CHAFILE=$1
SELFILE=$2
#########


echo "selecting speakers from $CHAFILE"


#********** A T T E N T I O N ***************#
#Modify this section to select the lines you want, for example here, we exclude speech by children and non-humans

	iconv -f ISO-8859-1 "$CHAFILE" |
	 grep '^*' |  
grep -v 'SI.\|BR.\|CHI\|TO.\|ENV\|BOY\|NON' |   #leave this line uncommented to get rid of all child speakers
grep 'MOT' |   #leave this line uncommented to focus only on mother's speech
	iconv -t ISO-8859-1 >> $SELFILE

#*******************************************#


