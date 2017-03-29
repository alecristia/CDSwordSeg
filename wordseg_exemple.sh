#!/bin/bash

# the directory where we put the intermediate data and results
data=exemple_data
mkdir -p $data

# the input text to segment (-e to preserve \n)
echo -e "Hi\nHello\nI'm a word segmenter\nSegmenting is beautiful" > $data/text.txt

# make a phonological level transcript with word and syllable boundaries
phonemize -l en-us-festival -p " " -s ";esyll " -w ";eword " $data/text.txt > $data/text.tags

# build the gold version
wordseg-gold $data/text.tags > $data/text.gold

# TP segmentation
wordseg-tp -u phoneme -t relative $data/text.tags > $data/text.seg.tp

# evaluation
wordseg-eval $data/text.seg.tp -g $data/text.gold > $data/text.eval.tp


echo 'Input text'
echo '----------'
cat $data/text.txt
echo

echo 'Phonemized text'
echo '---------------'
cat $data/text.tags
echo

echo 'Gold'
echo '----'
cat $data/text.gold
echo

echo 'TP segmentation'
echo '---------------'
cat $data/text.seg.tp
echo
cat $data/text.eval.tp
echo
