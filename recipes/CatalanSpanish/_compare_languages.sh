#!/bin/sh
# Laia Fibla laia.fibla.reixachs@gmail.com 2017-04-20
# This scripts calculates the syllable, phone and word inventory of two corpora and allows to find out the differences

######### VARIABLES ##########

RESFOLDER="/fhgfs/bootphon/scratch/lfibla/seg/SegCatSpa/big_corpora"

##############################

#declare useful function
function countchar()
{
    while IFS= read -r i; do printf "%s" "$i" | tr -dc "$1" | wc -m; done
}

#Extract syllable inventory
for thisfile in $RESFOLDER/conc_???/4/tags.txt; do
  sed 's/;eword/;esyll/g' < $thisfile | sed 's/ //g' | sed 's/;esyll/%/g' | tr '%' '\n' | sed '/^$/d' |
sort | uniq -c | awk '{print $2}' > ${thisfile}-syllablefreq.txt
done

  # Look at the differences
diff /Users/Laia/Documents/SegCatSpa/big_corpora/conc_cat/4/tags.txt-syllablefreq.txt /Users/Laia/Documents/SegCatSpa/big_corpora/conc_spa/4/tags.txt-syllablefreq.txt > $RESFOLDER/syll_differences.txt

num_syllab_cat=`wc -l /Users/Laia/Documents/SegCatSpa/big_corpora/conc_cat/4/tags.txt-syllablefreq.txt | awk '{print $1}'`
num_syllab_spa=`wc -l /Users/Laia/Documents/SegCatSpa/big_corpora/conc_spa/4/tags.txt-syllablefreq.txt | awk '{print $1}'`

echo $num_syllab_cat
echo $num_syllab_spa

syll_uniq_cat=`grep '<' < $RESFOLDER/syll_differences.txt | wc -l | awk '{print $1}'`
syll_uniq_spa=`grep '>' < $RESFOLDER/syll_differences.txt | wc -l | awk '{print $1}'`

echo $syll_uniq_cat
echo $syll_uniq_spa

# Extract word inventory

for thisfile in $RESFOLDER/conc_???/4/tags.txt; do
  sed 's/;esyll//g' < $thisfile | sed 's/ //g' | sed 's/;eword/%/g' | tr '%' '\n' | sed '/^$/d' |
sort | uniq -c | awk '{print $2}' > ${thisfile}-wordfreq.txt
done

  # Look at the differences
diff /Users/Laia/Documents/SegCatSpa/big_corpora/conc_cat/4/tags.txt-wordfreq.txt /Users/Laia/Documents/SegCatSpa/big_corpora/conc_spa/4/tags.txt-wordfreq.txt > $RESFOLDER/word_differences.txt

num_words_cat=`wc -l /Users/Laia/Documents/SegCatSpa/big_corpora/conc_cat/4/tags.txt-syllablefreq.txt | awk '{print $1}'`
num_words_spa=`wc -l /Users/Laia/Documents/SegCatSpa/big_corpora/conc_spa/4/tags.txt-syllablefreq.txt | awk '{print $1}'`

echo $num_words_cat
echo $num_words_spa

word_uniq_cat=`grep '<' < $RESFOLDER/word_differences.txt | wc -l | awk '{print $1}'`
word_uniq_spa=`grep '>' < $RESFOLDER/word_differences.txt | wc -l | awk '{print $1}'`

echo $word_uniq_cat
echo $word_uniq_spa


# Extract phone inventory

for thisfile in $RESFOLDER/conc_???/4/tags.txt; do
  sed 's/;esyll//g' < $thisfile | sed 's/;eword//g' | sed 's/ /%/g' | tr '%' '\n' | sed '/^$/d' |
sort | uniq -c | awk '{print $2}' > ${thisfile}-phonefreq.txt
done

  # Look at the differences
  diff /Users/Laia/Documents/SegCatSpa/big_corpora/conc_cat/4/tags.txt-phonefreq.txt /Users/Laia/Documents/SegCatSpa/big_corpora/conc_spa/4/tags.txt-phonefreq.txt > $RESFOLDER/phone_differences.txt

  num_phones_cat=`wc -l /Users/Laia/Documents/SegCatSpa/big_corpora/conc_cat/4/tags.txt-syllablefreq.txt | awk '{print $1}'`
  num_phones_spa=`wc -l /Users/Laia/Documents/SegCatSpa/big_corpora/conc_spa/4/tags.txt-syllablefreq.txt | awk '{print $1}'`

  echo $num_phones_cat
  echo $num_phones_spa

  phon_uniq_cat=`grep '<' < $RESFOLDER/phone_differences.txt | wc -l | awk '{print $1}'`
  phon_uniq_spa=`grep '>' < $RESFOLDER/phone_differences.txt | wc -l | awk '{print $1}'`

  echo $phon_uniq_cat
  echo $phon_uniq_spa

# it would be nice to write all this in a .txt document
