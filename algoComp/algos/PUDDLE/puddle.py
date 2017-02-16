#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Wed Feb 15 10:56:17 2017

@author: elinlarsen + J.Thomas

'Translation' of the puddle philosophy developped by P. Monaghan in a python language
Monaghan, P., & Christiansen, M. H. (2010). Words in puddles of sound: modelling psycholinguistic effects in speech segmentation. Journal of child language, 37(03), 545-564.

The fonction update_line is a recursive function that takes as input a list of phonemes (ie character separated by space) defining all together an utterance


"""
import os
import argparse
from collections import Counter
import logging

### Create logger
logger = logging.getLogger(__name__)
logger.setLevel(logging.CRITICAL) #to be change in ' logger.setLevel(logging.INFO)' to get all the print 

#formateur
formatter = logging.Formatter(
   '%(asctime)s -- %(name)s -- %(levelname)s -- %(message)s')

#console handler 
fileHandler = logging.FileHandler('puddle.log')
fileHandler.setFormatter(formatter)
logger.addHandler(fileHandler)

consoleHandler = logging.StreamHandler()
consoleHandler.setFormatter(formatter)
logger.addHandler(consoleHandler)


### Main fonction of the puddle
'''
lexicon, beginning and ending are counters (ie dictionnary that identify a string with its occurence)
they are global variable (out of the update_line function) in order to avoid for python to store twice the counters
'''
 
lexicon = Counter()
beginning = Counter()
ending = Counter()


def update_line(phonemes):
    
    segmentation_output=[] #empty list that will be filled by word chunks
    #check if the list of phonemes is not null
    if len(phonemes) == 0:
        raise NotImplementedError
    
    # at first, no match is found
    found = False
    i = 0
    
    
    while i < len(phonemes) and (found == False): 
        #look at all phonemes in the list while no match between a string of phonemes and a word_candidate in the lexicon is found
        p = phonemes[i]
        #logger.debug("phonemes {}".format(p))
        if p in beginning:
            #check if  phoneme n° i is in the dictionnary of beginnings
            for j in range(i+1,len(phonemes)+1):
                # look at every possible merge between the phoneme n° i and phoneme n°i+1, i+2, ..., len(phonemes)
                candidate_list = phonemes[i:j]
                candidate_word = "".join(candidate_list)
                candidate_pre_word="".join(phonemes[:i]) 
                if candidate_word in lexicon:
                    logger.info("Candidate {} found in lexicon".format(candidate_word)) #print in the log file
                    if i != 0:
                        lexicon.update([candidate_pre_word])
                        beginning.update([phonemes[0]])
                        ending.update([phonemes[i-1]])
                        logger.info("candidate pre word {} added in lexicon".format(candidate_pre_word))
                        logger.info("phonemes {} added in beginning".format(phonemes[0]))
                        logger.info("phonemes {} added in ending".format(phonemes[i-1]))
                        segmentation_output.append(candidate_pre_word)

                    lexicon.update([candidate_word])
                    beginning.update([candidate_list[0]])
                    ending.update([candidate_list[-1]])
                    logger.info( "candidate word {} added in lexicon".format(candidate_word))
                    logger.info( "phonemes {} added in beginning".format(candidate_list[0]))
                    logger.info( "phonemes {} added in ending".format(candidate_list[-1]))
                    segmentation_output.append(candidate_word)
                    found = True
                    if j != len(phonemes):
                        return update_line(phonemes[j:]) #repeat the procedure for the list of phonemes without the previous phonemes n° 1, ..., j-1
                    break
        else:
            pass
        
        i+=1
    
    if found != True:
        lexicon.update(["".join(phonemes)])
        logger.info( " Chunk {} not found in lexicon added ".format("".join(phonemes)))
        beginning.update([phonemes[0]])
        logger.info( " phonemes {} added in beginning".format(phonemes[0]))
        ending.update([phonemes[i-1]])
        logger.info("phonemes {} added in ending ".format(phonemes[i-1]))
        segmentation_output.append("".join(phonemes))
        
    return(segmentation_output)

### Sort by frequency
#convert the dictionnary containing the lexicon found by puddle and its occurences into a list to be able to sort it by frequency            
def sort_counter(d):
    l = []
    for key, value in d.items():
        l.append((key,value))
    l_sorted = sorted(l, key = lambda x: x[1])
    l_sorted.reverse()
    return(l_sorted)

### Puddle pipeline
def main(input_file, output_freq, output_seg):
    ''' puddle pipeline'''
    with open(input_file,'r') as f:
        f_bis=open(output_seg,'w')
        for line in f.readlines(): # get each line of the file  
            if len(line) != 0:
                line_seg=update_line(line.strip().split(" "))#split line as a list of strings which are separated by a space in the line
                for word in line_seg:
                    f_bis.write(word + " " )
                f_bis.write("\n")
    ### Write down the list into an ouput file 
    #lexicon=update_line(line.strip().split(" "))[1]
    l=sort_counter(lexicon)
    f=open(output_freq,'w')
    for i in range(0,len(l)) : 
        f.write(l[i][0] + " " + str(l[i][1]) +"\n")

if __name__=="__main__":
     parser = argparse.ArgumentParser(description='Divide your corpus in k sub corpus linearly.')
     parser.add_argument('-i', '--input_file', help='text file with phonemes separated by space and each line is utterance')
     parser.add_argument('-o', '--output_freq', help='the absolute path of your output directory where the freqency of word chunk will be put')
     parser.add_argument('-s', '--output_seg', help='the absolute path of your output directory where segmentation of input will be put')
     #parser.add_argument('-d', '--decay',   help='parameter that decrease the size of lexicon -- modelize memory of lexicon ')
     args=parser.parse_args()
     main(input_file=args.input_file,output_freq=args.output_freq,output_seg=args.output_seg )
     

### Apply function to file
full_brent='/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/recipes/childes/data/Brent/input_test.txt'
brent_child='/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/recipes/childes/data/Brent/c1-0902/tags.txt'
test='/Users/elinlarsen/Documents/CDSwordSeg/ElinDev/input_test.txt'

#python puddle.py -i /../../../CDSwordSeg_Pipeline/recipes/childes/data/
            
main(input_file=full_brent, output_freq="freq.txt", output_seg="seg_out.txt")      #PROELEME AVEC LE LEXICON in or out the fonction ?

