#!/usr/bin/env python
#
# Script written by Amanda Saksida, modified 15/10/15
#
# if considering using please write to her at amanda.saksida@gmail.com
#
# input: corpus with syllable boundaries marked and no word
#     boundaries. all in one line, all the syllables delimited by
#     spaces, utterances delimited by " UB ".
#
# output: corpus with words suggested acc to the model, in separate lines.
#
# command line:
# python TPsegmentation.py syllableboundaries_marked.txt > outputABS.txt
#
# absolute threshold = a value of the average TP in a corpus.

import collections
import fileinput
import sys
import numpy
import math
from scipy import stats


class Counter(collections.Counter):
    def __str__(self):
        return "\n".join("{}\t{}".format("-".join(key)
                                         if isinstance(key, tuple) 
                                         else key, value)  # "-"
                         for key, value in self.items())


"""
for line in fileinput.input(sys.argv[1]):
	words = [word.split(" ") for word in line.split()]


words_all = [word for word in line.split()]
freq_wordsall = Counter(words_all)
syllables = [syllable for word in words for syllable in word]
freq_syll = Counter(syllables)

"""
##### FTP
#input
for line in fileinput.input(sys.argv[1]):
    syls = [syl for syl in line.split()]

# computing TPs
freq_syls = Counter(syls)
bigrams_all = zip(syls[0:-1],syls[1:])
# zip returns a list of tuples, where the i-th tuple contains the i-th element from each of the argument sequences or iterables.
# => list of all the bigrams
freq_bigrams_all = Counter(bigrams_all)
# dictionary of bigram and it forward TP (bigram[0] is the first syllable of the bigram)
tp_bigrams_all = dict((bigram,float(freq)/freq_syls[bigram[0]])
                      for bigram,freq in freq_bigrams_all.items())
# TPall is the mean TP in the corpus
TPall = (sum(tp_bigrams_all.values())/len(tp_bigrams_all)
         if len(tp_bigrams_all)!=0 else 0)

#local minima (Relative algorithm)
#with open(sys.argv[3], "a") as outstreamREL:
cwords=[]
prelast=syls[0]
last=syls[1]
syl=syls[2]
cword=[prelast,last]
cwords.append(cword) # initialisation 
for next in syls[3:]:
    if ((tp_bigrams_all[prelast,last] > tp_bigrams_all[last,syl] < tp_bigrams_all[syl,next]) # condition du seuil relatif
        or last=="UB" or syl=="UB"): # fin de phrase
	cword = []
	cwords.append(cword)
    cword.append(syl)
    prelast=last
    last=syl
    syl=next

cwordsTPa = map(''.join, cwords)
#print len(cwordsTPa)
wordsTPa = ' '.join(cwordsTPa)
sentencesTPa = wordsTPa.replace("UB ", "\n")[:-2]
print sentencesTPa

## absolute threshold (Absolute algorithm)
# cwords = []
# last_syl = syls[0]
# last_word = [last_syl]
# cwords.append(last_word)
# with open(sys.argv[3], "a") as outstreamABS:
# for syl in syls[1:]:
#	if (tp_bigrams_all[last_syl,syl] <= TPall) or last_syl=="UB" or syl=="UB":
#		last_word = []
#		cwords.append(last_word)
#	last_word.append(syl)
#	last_syl=syl
# cwordsTPa = map(''.join, cwords)
# wordsTPa = ' '.join(cwordsTPa)
# sentencesTPa = wordsTPa.replace("UB ", "\n")[:-2]
# print sentencesTPa
