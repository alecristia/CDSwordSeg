# Script written by Amanda Saksida
# Minor modifications by Alex Cristia <alecristia@gmail.com> on 2015-07

### the corpus should all be in one line, utterances can be delimited by " UB ". 
### as written now, it reads spaces as word boundaries and dashes (-) as syllable boundaries. 
### command line: python TPsegmentation.py syllable+wordboundaries_marked.txt syllableboundaries_marked.txt outputABS.txt outputREL.txt

### relative threshold = selection of the word boundary based on the locally minimal value (Saffran); 
### absolute threshold = a value of the average word-internal TP in a corpus. 

#!/usr/bin/python
import collections
import fileinput
import sys
import numpy
import math
from scipy import stats

class Counter(collections.Counter):
    def __str__(self):
        return "\n".join("{}\t{}".format("-".join(key) if isinstance(key, tuple) else key, value) # "-" 
                         for key, value in self.items())

for line in fileinput.input(sys.argv[1]): 
	words = [word.split("-") for word in line.split()]

words_all = [word for word in line.split()]
freq_wordsall = Counter(words_all)
syllables = [syllable for word in words for syllable in word]
freq_syll = Counter(syllables)

#word-internal TPs for averaging
bigrams_int = [bigram for word in words for bigram in zip(word[0:-1],word[1:])]
freq_bigrams_int = Counter(bigrams_int)
tp_bigrams_int = dict((bigram,float(freq)/freq_syll[bigram[0]]) for bigram,freq in freq_bigrams_int.items())

TPi = sum(tp_bigrams_int.values())/len(tp_bigrams_int) if len(tp_bigrams_int)!=0 else 0


##### FTP
#input
for line in fileinput.input(sys.argv[2]): 
    syls = [syl for syl in line.split()]

freq_syls = Counter(syls)

# computing TPs 
bigrams_all = zip(syls[0:-1],syls[1:])
freq_bigrams_all = Counter(bigrams_all)	
tp_bigrams_all = dict((bigram,float(freq)/freq_syll[bigram[0]]) for bigram,freq in freq_bigrams_all.items())

    
# absolute threshold (Absolute algorithm)
cwordsTP=[]
cwords = []
last_syl = syls[0]
last_word = [last_syl]
cwords.append(last_word)
with open(sys.argv[3], "a") as outstreamABS:
 	for syl in syls[1:]:
		if (tp_bigrams_all[last_syl,syl] <= TPi) or last_syl=="UB" or syl=="UB":
			last_word = []
			cwords.append(last_word)
		last_word.append(syl)
		last_syl=syl
	cwordsTP.append(cwords)
	outstreamABS.write(str(cwords))

#local minima (Relative algorithm)
with open(sys.argv[4], "a") as outstreamREL:
	lwords=[]
	prelast=syls[0]
	last=syls[1]
	syl=syls[2]
	lword=[prelast,last]
	lwords.append(lword)
	for next in syls[3:]:
		if (tp_bigrams_all[prelast,last] > tp_bigrams_all[last,syl] < tp_bigrams_all[syl,next]) or last=="UB" or syl=="UB":
			lword = []
			lwords.append(lword)
		lword.append(syl)
		prelast=last
		last=syl
		syl=next
	lwords.append([next])
	cwordsTP.append(lwords)
	outstreamREL.write(str(lwords))







