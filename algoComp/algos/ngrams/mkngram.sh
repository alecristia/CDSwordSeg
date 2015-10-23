# script written by Emmanuel Dupoux
# if considering use please write to him at emmanuel.dupoux@gmail.com 

#!/bin/bash

if [ "$1" == "" ]; then
    echo "USAGE: $0 [--syll] input_file"
    echo ""
    echo "  Extracts a dictionnary of all of the ngrams sorted by frequency."
    echo "  with --syll, it is syllabic ngrams (from 1 to 4), otherwise phonemic (1 to 20)."
    echo "  The input has to be in modified chat format:"
    echo ""
    echo "     file name age speaker TRANSCRIPTION [;orth=\"...\"]"
    echo ""
    echo "   where TRANSCRIPTION has phonemes separated by spaces or with ;esyll for syllabic breaks"
    exit -1
fi

if [ "$1" == "--syll" ]; then
    SYLL=1
    shift
else
    SYLL=0
fi

if [ ! -f "$1" ]; then
    echo "ERROR: file '$1' does not exist" > "/dev/stderr"
    exit -1
fi

#create the ngram-frequency list for both
if  [ "$SYLL" == "1" ] ; then
       # cleaning up (removing spurious columns and anything after the orthographic mark)
    awk '{gsub(";orth=.*","");print}' "$1" > tmp.tmp
       # parsing into syll
    awk -F '[ \t]*;esyll[ \t]*' '{for(i=1;i<=NF;i++){gsub(" ","_",$i);gsub("^_+","",$i);if($i)printf("%s ",$i)}printf("\n")}' tmp.tmp > tmp2.tmp
       # setting the limit in nb of syllables
    LIM=4
else
       # cleaning up (removing spurious columns and anything after the orthographic mark)
    awk '{gsub(";orth=.*",""); gsub(";esyll",""); $1="";$2="";$3="";$4="";print}' "$1" > tmp2.tmp
    LIM=20
fi
    
 # constructing the ngrams
awk '{gsub("_","");for(n=1;n<='$LIM';n++)for(i=1;i<=NF-n+1;i++){s="";for(k=0;k<n;k++)s=s""$(i+k);S[s]++;L[s]+=n}}END{for(w in S)print S[w],L[w]/S[w],w}' tmp2.tmp |sort -n -r 

