#!/bin/sh
# Wrapper to take a single cleaned up transcript and phonologize it
# Alex Cristia alecristia@gmail.com 2015-10-26
# Modified by Laia Fibla laia.fibla.reixachs@gmail.com 2016-09-28 adapted to arg spanish


#########VARIABLES
#Variables to modify
LANGUAGE="catalan" #language options:  cspanish (castillan spanish), catalan  -- NOTICE, IN SMALL CAPS


PATH_TO_SCRIPTS="/fhgfs/bootphon/scratch/lfibla/CDSwordSeg/phonologization"
#path to the phonologization folder - E.g. PATH_TO_SCRIPTS="/home/xcao/cao/projects/ANR_Alex/CDSwordSeg/phonologization/"

RES_FOLDER="/fhgfs/bootphon/scratch/lfibla/SegCatSpa/RES_corpus_cat/"
#this is where we will put the processed versions of the transcripts E.g. RES_FOLDER="/home/xcao/cao/projects/ANR_Alex/res_Childes_Eng-NA_cds/"
# NOTICE THE / AT THE END OF THE NAME


for ORTHO in ${RES_FOLDER}*ortholines.txt; do
	KEYNAME=$(basename "$ORTHO" -ortholines.txt)

	#########
	if [ "$LANGUAGE" = "cspanish" ]
	   then
	  echo "recognized $LANGUAGE"
tr '[:upper:]' '[:lower:]'  < "$ORTHO"  | #Spanish files have different encoding
	  sed 's/ch/C/g' | # substitute all ch by tS
	  sed 's/v/b/g' |
	  sed 's/z/O/g' |
		sed 's/ce/Oe/g' |
		sed 's/ci/Oi/g' |
	  sed 's/c/k/g' |
	  sed 's/rr/R/g' | # substitute the spanish rr by 5
	  sed 's/ r/ R/g' | # substitue the initial r for R
	  sed 's/^r/R/g' | # substitue the initial r for R
	  sed 's/ll/L/g' | # very mixed in spain choose between L and y
	  sed 's/j/x/g' |
	  sed 's/qu/k/g' |
	  sed 's/h//g' | # removing h
	  sed 's/ñ/N/g' |
	  sed 's/á/a/g' |
	  sed 's/é/e/g' |
	  sed 's/í/i/g' |
	  sed 's/ó/o/g' |
	  sed 's/ú/u/g' |
	  sed 's/ü/u/g'  > intoperl.tmp

	  echo "syllabify-corpus.pl"
	  perl $PATH_TO_SCRIPTS/scripts/syllabify-corpus.pl aspanish intoperl.tmp outofperl.tmp $PATH_TO_SCRIPTS


	elif [ "$LANGUAGE" = "catalan" ]
		 then
		echo "recognized $LANGUAGE"
	tr '[:upper:]' '[:lower:]'  < "$ORTHO"  | #Spanish files have different encoding
		sed 's/v/b/g' |
		sed 's/sc/s/g' |
		sed 's/ce/sE/g' |
		sed 's/ci/si/g' |
		sed 's/ca/ka/g' |
		sed 's/co/ko/g' |
		sed 's/cu/ku/g' |
		sed 's/rr/R/g' |
		sed 's/^r/R/g' | # substitue the initial r for R
		sed 's/ss/s/g' |
		sed 's/ll/L/g' |
		sed 's/qu/k/g' |
		sed 's/h//g' | # removing h
		sed 's/b^//g' |
		sed 's/d^/t/g' |
		sed 's/ny/N/g' |
		sed 's/tz/dz/g' |
		sed 's/tg/dZ/g' |
		sed 's/dj/dZ/g' |
		sed 's/tx/tS/g' |
		sed 's/ig/tS/g' |
		sed 's/ix/S/g' |
		sed 's/^x/tS/g' |
		sed 's/x/S/g' |
		sed 's/chs/ks/g' |
		sed 's/ch/S/g' |
		sed 's/c/k/g' |
		sed 's/qu/k/g' |
		sed 's/gue/ge/g' |
		sed 's/gui/gi/g' |
		sed 's/à/a/g' |
		sed 's/a^/E/g' |
		sed 's/é/e/g' | # replace by 8?
		sed 's/è/3/g' |
		sed 's/^e/E/g' |
		sed 's/e^/E/g' |
		sed 's/es/Es/g' |
		sed 's/em/Em/g' |
		sed 's/er^/e/g' |
		sed 's/re/rE/g' |
		sed 's/ej/Ej/g' |
		sed 's/eg/Eg/g' |
		sed 's/í/i/g' |
		sed 's/ó/O/g' |
		sed 's/^o/o/g' |
		sed 's/ò/0/g' |
		sed 's/or^/O/g' |
		sed 's/o/6/g' |
		sed 's/ú/u/g' |
		sed 's/r^//g' |
	#	sed 's/e/8/g' | ## !!!
		sed 's/asa/aza/g' |
		sed 's/ase/aze/g' |
		sed 's/asE/azE/g' |
		sed 's/as3/az3/g' |
		sed 's/asi/azi/g' |
		sed 's/asO/azO/g' |
		sed 's/as0/az0/g' |
		sed 's/as6/az6/g' |
		sed 's/asu/azu/g' |
		sed 's/esa/eza/g' |
		sed 's/ese/Eze/g' |
		sed 's/3se/3ze/g' |
		sed 's/es3/ez3/g' |
		sed 's/esi/ezi/g' |
		sed 's/Esi/Ezi/g' |
		sed 's/esO/ezO/g' |
		sed 's/es0/ez0/g' |
		sed 's/es6/ez6/g' |
		sed 's/3s6/3z6/g' |
		sed 's/Es6/Ez6/g' |
		sed 's/EsO/EzO/g' |
		sed 's/Es0/Ez0/g' |
		sed 's/esu/ezu/g' |
		sed 's/3su/3zu/g' |
		sed 's/Esu/Ezu/g' |
		sed 's/isa/iza/g' |
		sed 's/ise/ize/g' |
		sed 's/is3/iz3/g' |
		sed 's/isi/izi/g' |
		sed 's/isO/izO/g' |
		sed 's/is0/iz0/g' |
		sed 's/is6/iz6/g' |
		sed 's/isu/izu/g' |
		sed 's/Osa/Oza/g' |
		sed 's/0sa/0za/g' |
		sed 's/6sa/6za/g' |
		sed 's/Ose/Oze/g' |
		sed 's/0se/0ze/g' |
		sed 's/6se/6ze/g' |
		sed 's/6s3/6z3/g' |
		sed 's/OsE/OzE/g' |
		sed 's/0sE/0zE/g' |
		sed 's/6sE/6zE/g' |
		sed 's/Osi/Ozi/g' |
		sed 's/0si/0zi/g' |
		sed 's/6si/6zi/g' |
		sed 's/6sO/6zO/g' |
		sed 's/6s6/6z0/g' |
		sed 's/usa/uza/g' |
		sed 's/use/uzE/g' |
		sed 's/usu/uzu/g' |
		sed 's/nsa/nza/g' |
		sed 's/nce/nse/g' |
		sed 's/ncE/nsE/g' |
		sed 's/nc3/ns3/g' |
		sed 's/nci/nsi/g' |
		sed 's/ç/s/g' |
		sed 's/ja/Za/g' |
		sed 's/ge/Ze/g' |
		sed 's/g3/Z3/g' |
		sed 's/gE/ZE/g' |
		sed 's/gi/Zi/g' |
		sed 's/jo/Zo/g' |
		sed 's/j0/Z0/g' |
		sed 's/ju/Zu/g' |
		sed 's/j/Z/g' |
		sed 's/ieu/jew/g' |
		sed 's/i3u/j3w/g' |
		sed 's/ü3u/w3w/g' |
		sed 's/uai/waj/g' |
		sed 's/uEi/wEj/g' |
		sed 's/ai/aj/g' |
		sed 's/ei/ej/g' |
		sed 's/3i/3j/g' |
		sed 's/Ei/Ej/g' |
		sed 's/oi/0j/g' |
		sed 's/ui/uj/g' |
		sed 's/au/aw/g' |
		sed 's/eu/ew/g' |
		sed 's/3u/3w/g' |
		sed 's/Eu/Ew/g' |
		sed 's/iu/iw/g' |
		sed 's/ou/ow/g' |
		sed 's/0u/0w/g' |
		sed 's/uu/uw/g' |
		sed 's/ia/ja/g' |
		sed 's/ie/je/g' |
		sed 's/i3/j3/g' |
		sed 's/iE/jE/g' |
		sed 's/io/j0/g' |
		sed 's/iu/ju/g' |
		sed 's/ua/wa/g' |
		sed 's/üe/we/g' |
		sed 's/ü3/w3/g' |
		sed 's/üE/wE/g' |
		sed 's/üi/wi/g' |
		sed 's/uo/w0/g' |
		sed 's/tn/n/g' |
		sed 's/tm/m/g' |
		sed 's/^ad/at/g' |
		sed 's/^pn/n/g' |
		sed 's/^ps/s/g' |
		sed 's/nt^/n/g' |
		sed 's/^E/a/g' | #
		sed 's/^3L/eL/g' > intoperl.tmp

		echo "syllabify-corpus.pl"
		perl $PATH_TO_SCRIPTS/scripts/syllabify-corpus.pl aspanish intoperl.tmp outofperl.tmp $PATH_TO_SCRIPTS

	fi

		echo "removing blank lines"
		sed '/^$/d' outofperl.tmp |
		sed '/^ $/d'  |
		sed '/^[ ]*$/d'  |
		sed 's/^ //'  |
		sed 's/^\///'  | #there aren't really any of these, this is just a cautionary measure
	sed 's/ / ;eword /g' |
		sed -e 's/\(.\)/\1 /g'  |
	sed 's/ ; e w o r d/ ;eword /g' |
	sed 's/\// ;esyll /g'|
	tr -s ' ' > tmp.tmp

		mv tmp.tmp ${RES_FOLDER}/${KEYNAME}-tags.txt

	echo "creating gold versions"

	sed 's/;esyll//g'  < ${RES_FOLDER}/${KEYNAME}-tags.txt |
		tr -d ' ' |
		sed 's/;eword/ /g' > ${RES_FOLDER}/${KEYNAME}-gold.txt

done


echo "end"
