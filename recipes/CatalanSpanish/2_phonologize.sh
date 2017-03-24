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
	  perl $PATH_TO_SCRIPTS/scripts/syllabify-corpus.pl cspanish intoperl.tmp outofperl.tmp $PATH_TO_SCRIPTS


	elif [ "$LANGUAGE" = "catalan" ]
		 then
		echo "recognized $LANGUAGE"
	tr '[:upper:]' '[:lower:]'  < "$ORTHO"  | #Catalan rules to phonologize
		sed 's/v/b/g' |
		sed 's/fresso/frazo/g' |
		sed 's/sc/s/g' |
		sed 's/ce/s6/g' |
		sed 's/ci/si/g' |
		sed 's/ca/ka/g' |
		sed 's/co/ko/g' |
		sed 's/cu/ku/g' |
		sed 's/rr/R/g' |
		sed 's/^r/R/g' |
		sed 's/^lleo/Lao/g' |
		sed 's/ll/L/g' |
		sed 's/ho\>/u/g' |
		sed 's/eh/eg/g' |
		sed 's/h//g' |
		sed 's/b\>//g' |
		sed 's/d\>/t/g' |
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
		#sed 's/ar$/a/g' |
	#	sed 's/\<es\>/6s/g' |
		sed 's/é/e/g' |
		sed 's/è/3/g' |
		sed 's/^e/6/g' |
		sed 's/\<6s\>/es/g' |
		#sed 's/^k3/ke/g' | #
		sed 's/^k6/ke/g' |
		sed 's/6ss/3ss/g' |
		sed 's/t6s\>/tes/g' |
		sed 's/em/6m/g' |
		sed 's/er\>/e/g' |
		sed 's/re/r6/g' |
		sed 's/ej/6j/g' |
		sed 's/eg/6g/g' |
		sed 's/í/i/g' |
		sed 's/ó/O/g' |
		sed 's/ò/0/g' |
		sed 's/or\>/O/g' |
		sed 's/ú/u/g' |
		sed 's/r\>//g' | #
		sed 's/asa/aza/g' |
		sed 's/ase/aze/g' |
		sed 's/as6/az6/g' |
		sed 's/as3/az3/g' |
		sed 's/asi/azi/g' |
		sed 's/asO/azO/g' |
		sed 's/as0/az0/g' |
		sed 's/aso/azo/g' |
		sed 's/asu/azu/g' |
		sed 's/esa/eza/g' |
		sed 's/ese/6ze/g' |
		sed 's/3se/3ze/g' |
		sed 's/es3/ez3/g' |
		sed 's/esi/ezi/g' |
		sed 's/6si/6zi/g' |
		sed 's/esO/ezO/g' |
		sed 's/es0/ez0/g' |
		sed 's/eso/ezo/g' |
		sed 's/3so/3zo/g' |
		sed 's/6so/6zo/g' |
		sed 's/6sO/6zO/g' |
		sed 's/6s0/6z0/g' |
		sed 's/esu/ezu/g' |
		sed 's/3su/3zu/g' |
		sed 's/6su/6zu/g' |
		sed 's/isa/iza/g' |
		sed 's/ise/ize/g' |
		sed 's/is3/iz3/g' |
		sed 's/isi/izi/g' |
		sed 's/isO/izO/g' |
		sed 's/is0/iz0/g' |
		sed 's/iso/izo/g' |
		sed 's/isu/izu/g' |
		sed 's/Osa/Oza/g' |
		sed 's/0sa/0za/g' |
		sed 's/osa/oza/g' |
		sed 's/Ose/Oze/g' |
		sed 's/0se/0ze/g' |
		sed 's/ose/oze/g' |
		sed 's/os3/oz3/g' |
		sed 's/Os6/Oz6/g' |
		sed 's/0s6/0z6/g' |
		sed 's/os6/oz6/g' |
		sed 's/Osi/Ozi/g' |
		sed 's/0si/0zi/g' |
		sed 's/osi/ozi/g' |
		sed 's/osO/ozO/g' |
		sed 's/oso/oz0/g' |
		sed 's/usa/uza/g' |
		sed 's/use/uz6/g' |
		sed 's/usu/uzu/g' |
		sed 's/nsa/nza/g' |
		sed 's/ss/s/g' |
		sed 's/nce/nse/g' |
		sed 's/nc6/ns6/g' |
		sed 's/nc3/ns3/g' |
		sed 's/nci/nsi/g' |
		sed 's/ç/s/g' |
		sed 's/ja/Za/g' |
		sed 's/ge/Ze/g' |
		sed 's/g3/Z3/g' |
		sed 's/g6/Z6/g' |
		sed 's/gi/Zi/g' |
		sed 's/jO/ZO/g' |
		sed 's/j0/Z0/g' |
		sed 's/jo/Zo/g' |
		sed 's/ju/Zu/g' |
		sed 's/j/Z/g' |
		sed 's/ieu/jew/g' |
		sed 's/i3u/j3w/g' |
		sed 's/ü3u/w3w/g' |
		sed 's/uai/waj/g' |
		sed 's/u6i/w6j/g' |
		sed 's/ai/aj/g' |
		sed 's/ei/ej/g' |
		sed 's/3i/3j/g' |
		sed 's/6i/6j/g' |
		sed 's/oi/0j/g' |
		sed 's/ui/uj/g' |
		sed 's/au/aw/g' |
		sed 's/eu/ew/g' |
		sed 's/3u/3w/g' |
		sed 's/6u/6w/g' |
		sed 's/iu/iw/g' |
		sed 's/Ou/Ow/g' |
		sed 's/0u/0w/g' |
		sed 's/ou/ow/g' |
		sed 's/uu/uw/g' |
		sed 's/ia/ja/g' |
		sed 's/ie/je/g' |
		sed 's/i3/j3/g' |
		sed 's/i6/j6/g' |
		sed 's/io/j0/g' |
		sed 's/iu/ju/g' |
		sed 's/ua/wa/g' |
		sed 's/üe/we/g' |
		sed 's/ü3/w3/g' |
		sed 's/ü6/w6/g' |
		sed 's/üi/wi/g' |
		sed 's/uo/w0/g' |
		sed 's/tn/n/g' |
		sed 's/tm/m/g' |
		sed 's/^ad/at/g' |
		sed 's/^pn/n/g' |
		sed 's/^ps/s/g' |
		sed 's/nt/n/g' |
		sed 's/os\>/us/g' |
		sed 's/eg\>/ak/g' |
		sed 's/6g\>/ek/g' |
		sed 's/ek\>/eg/g' |
		sed 's/es\>/as/g' |
		sed 's/o\>/u/g' |
		sed 's/nu\>/no/g' |
		sed 's/t /t/g' |
		sed 's/h//g' |
		sed 's/^6L/eL/g' > intoperl.tmp

		echo "syllabify-corpus.pl"
		perl $PATH_TO_SCRIPTS/scripts/syllabify-corpus.pl catalan intoperl.tmp outofperl.tmp $PATH_TO_SCRIPTS

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
