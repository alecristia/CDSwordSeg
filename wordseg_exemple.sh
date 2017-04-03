#!/bin/bash

# the directory where we put the intermediate data and results
data=$(mktemp -d)
trap "rm -rf $data" EXIT

# the input text to segment (-e to preserve \n)
echo -e "Hi\nHello\nI'm a word segmenter\nSegmenting is beautiful" > $data/text.txt

# make a phonological level transcript with word and syllable boundaries
cat $data/text.txt | phonemize -l en-us-festival -p " " -s ";esyll " -w ";eword " > $data/text.tags

# build the gold version
cat $data/text.tags | wordseg-gold > $data/text.gold

# TP segmentation at phoneme level
cat $data/text.tags | wordseg-prep -u phoneme | wordseg-tp -t relative > $data/text.seg.tp
cat $data/text.seg.tp | wordseg-eval -g $data/text.gold > $data/text.eval.tp

# dibs segmentation at phoneme level
cat $data/text.tags | wordseg-prep -u phoneme | wordseg-dibs > $data/text.seg.dibs
cat $data/text.seg.dibs | wordseg-eval -g $data/text.gold > $data/text.eval.dibs


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

echo 'DiBS segmentation'
echo '---------------'
cat $data/text.seg.dibs
echo
cat $data/text.eval.dibs
echo
