#!/bin/sh
# cleaning up selected lines from cha files in prep to generating a phono format
# Alex Cristia alecristia@gmail.com 2015-10-26

#########VARIABLES
#Variables that have been passed by the user
SELFILE=$1
ORTHO=$2
RESFOLDER=$3
#PATH_TO_SCRIPTS=$4
#########

echo "Cleaning $SELFILE"


#replacements to clean up punctuation, etc. -- usually ok regardless of the corpus

iconv -f ISO-8859-1 "$RESFOLDER$SELFILE" |
sed 's/^....:.//g' |
sed "s/\_/ /g" |
sed '/^0(.*) .$/d' |
sed  's/.*$//g' |
tr -d '\"' |
tr -d '\"' |
tr -d '\/' |
sed 's/\+/ /g' |
tr -d '\.' |
tr -d '\?' |
tr -d '!' |
tr -d ';' |
tr -d '\<' |
tr -d '\>' |
tr -d ','  |
tr -d ':'  |
sed 's/&[^ ]*//g' |
grep -v '\[- spa\]' |
sed 's/[^ ]*@sspa//g' |
sed 's/\[[^[]*\]//g' |
sed 's/([^(]*)//g' |
sed 's/xxx//g' |
sed 's/www//g' |
sed 's/XXX//g' |
sed 's/yyy//g' |
sed 's/0*//g' |
sed 's/@o//g' |
sed 's/@f//g' |
sed 's/@q//g' |
sed 's/@u//g' |
sed 's/@c//g' |
sed "s/\' / /g"  |
sed 's/  / /g' |
sed 's/ $//g' |
sed 's/^ //g' |
sed 's/^[ ]*//g' |
sed 's/ $//g' |
sed '/^$/d' |
sed '/^ $/d' |
awk '{gsub("\"",""); print}' > tmp.tmp


#********** A T T E N T I O N ***************#
# check that the next set of replacements for unusual spellings is adapted to your purposes
#next set of replacements for unusual spellings - English
	sed 's/allgone/all gone/g' tmp.tmp |
	 sed 's/[0-9]//g' |
	 sed 's/whaddaya/what do you/g' |
	sed 's/whadda/what do/g' |
	sed 's/haveto/have to/g' |
	sed 's/hasto/has to/g' |
	sed 's/outof/out of/g' |
	sed 's/lotsof/lots of/g' |
	sed 's/lotta/lots of/g' |
	sed 's/alotof/a lot of/g' |
	sed "s/wha\'s/what's/g" |
	sed "s/this\'s/this is/g" |
	sed 's/chya/ you/g' |
	 sed 's/tcha/t you/g' |
	sed 's/dya /d you /g' |
	sed 's/chyou/ you/g' |
	sed "s/dont you/don\'t you/g" |
	sed 's/wanta/wanna/g'  |
	sed "s/whats / what\'s /g" |
	sed "s/'re/ are/g" |
	sed "s/klenex/kleenex/g" |
	sed 's/yogourt/yogurt/g' |
	sed 's/weee*/wee/g' |
	sed 's/oooo*/oh/g' |
	sed 's/ oo / oh /g' |
	sed 's/ohh/oh/g' |
	sed "s/ im / I\'m /g" |
	iconv -t ISO-8859-1 > "$RESFOLDER$ORTHO"


#This is to process all the "junk" that were generated when making the
#changes from included to ortho.  For e.g., the cleaning process
#generated double spaces between 2 words (while not present in
#included)
sed -i -e 's/  $//g' $RESFOLDER$ORTHO
sed -i -e 's/  / /g' $RESFOLDER$ORTHO
sed -i -e 's/  / /g' $RESFOLDER$ORTHO	#not same encoding as above?
sed -i -e 's/^ //g' $RESFOLDER$ORTHO
sed -i -e 's/ $//g' $RESFOLDER$ORTHO

rm -f tmp.tmp
