# Script written by Amanda Saksida, modified 15/10/15
### input: corpus with syllable boundaries marked and no word boundaries. all in one line, all the syllables delimited by spaces, utterances delimited by " UB ". 
### output: corpus with words suggested acc to the model, in separate lines. 
### command line: python TPsegmentation.py syllableboundaries_marked.txt > outputABS.txt 
### absolute threshold = a value of the average TP in a corpus. 

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


"""
for line in fileinput.input(sys.argv[1]): 
	words = [word.split("-") for word in line.split()]


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
freq_bigrams_all = Counter(bigrams_all)	
tp_bigrams_all = dict((bigram,float(freq)/freq_syls[bigram[0]]) for bigram,freq in freq_bigrams_all.items())
TPall = sum(tp_bigrams_all.values())/len(tp_bigrams_all) if len(tp_bigrams_all)!=0 else 0


# absolute threshold (Absolute algorithm)
cwords = []
last_syl = syls[0]
last_word = [last_syl]
cwords.append(last_word)
#with open(sys.argv[3], "a") as outstreamABS:
for syl in syls[1:]:
	if (tp_bigrams_all[last_syl,syl] <= TPall) or last_syl=="UB" or syl=="UB":
		last_word = []
		cwords.append(last_word)
	last_word.append(syl)
	last_syl=syl
cwordsTPa = map(''.join, cwords)
wordsTPa = ' '.join(cwordsTPa)
sentencesTPa = wordsTPa.replace("UB ", "\n")[:-2]
print sentencesTPa





