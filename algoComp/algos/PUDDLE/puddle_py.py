#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Wed Feb 22 00:31:20 2017

@author: elinlarsen

'Translation' of the puddle philosophy developped by P. Monaghan in a python language
Monaghan, P., & Christiansen, M. H. (2010). Words in puddles of sound: modelling psycholinguistic effects in speech segmentation. Journal of child language, 37(03), 545-564.

The fonction update_line is a function that takes as input a list of phonemes (ie character separated by space) defining all together an utterance

Invariant : à chaque fois qu'on update le lexique, on segmente (on print sur le fichier texte)
"""

import argparse
from collections import Counter
import logging


##### LOGGER

### Create logger
logger = logging.getLogger(__name__)
logger.setLevel(logging.CRITICAL) #to be change in ' logger.setLevel(logging.INFO)' to get all the print 

#formateur
formatter = logging.Formatter(
   ' %(name)s -- %(levelname)s -- %(message)s')

#console handler 
fileHandler = logging.FileHandler('/Users/elinlarsen/Documents/puddle_test/puddle.log')
fileHandler.setFormatter(formatter)
logger.addHandler(fileHandler)

consoleHandler = logging.StreamHandler()
consoleHandler.setFormatter(formatter)
logger.addHandler(consoleHandler)

##### END OF LOGGER



##### PUDDLE

lexicon=Counter() 
beginning=Counter()
ending=Counter()
segmentation_output=[]  #empty list that will be filled by word chunks, do not put it in the updata_line function, otherwise it will empty for each line, pre word will be lost


def filter_by_frequency(phonemes,i, j):
    all_candidates=[]
    for k in range(j, len(phonemes)):
        try :
            all_candidates.append((k,lexicon["".join(phonemes[i:k+1])]))
        except KeyError:
            pass          
     
    j,_=sorted(all_candidates,key=lambda x: x[1])[-1]

    return(j)
            
    
def filter_by_boundary_condition(phonemes, i,j, found,window):
    if found==True:

        previous_biphone="".join(phonemes[i-window:i])
        if i!=0 and previous_biphone not in ending :  # previous must be word-end
            return False
            
        following_biphone="".join(phonemes[j+1:j+1+window])
        if (len(phonemes)!=j-i) and (following_biphone not in beginning):
            return False 
            
        return True

      
    
def update_counters(phonemes,i,j,window):
    lexicon.update(["".join(phonemes[i:j+1])])
    segmentation_output.append("".join(phonemes[i:j+1]))
    if len(phonemes[i:j+1])==len(phonemes): 
        logger.error("Utterance {} added in lexicon".format("".join(phonemes[i:j+1])))
    else: 
        logger.error("Match {} added in lexicon".format("".join(phonemes[i:j+1])))
    
    if len(phonemes[i:j+1])>= 2:
        beginning.update(["".join(phonemes[i:i+window])])
        ending.update(["".join(phonemes[j+1-window:j+1])])
        logger.error("Bi-phonemes {} added in beginning".format("".join(phonemes[i:i+window])))
        logger.error("Bi-phonemes {} added in ending".format("".join(phonemes[j+1-window:j+1]))) 
            


def update_line(phonemes, window):
     
    if len(phonemes) == 0: #check if the list of phonemes is not null
        raise NotImplementedError

    found=False
    
    i=0 # i indice of start of word candidate
    
    while i<len(phonemes):    
        j=i

        while j<len(phonemes):
            candidate_word = "".join(phonemes[i:j+1])
            logger.info("word candidate {}".format(candidate_word))
            
            if candidate_word in lexicon : 
                found=True
 
                #j=filter_by_frequency(phonemes,i,j) # choose the best candidate by looking at the frequency of different candidates
    
                found=filter_by_boundary_condition(phonemes,i,j,found,window) #check if the boundary conditions are respected
                  
                if found==True: 
                    logger.error("match found : {}" .format(candidate_word))
                    if i!=0 : 
                        update_counters(phonemes,0,i-1,window)  #add the word preceding the word found in lexicon ; update beginning and ending counters and segment
                    update_counters(phonemes,i,j,window)   #update the lexicon, beginning and ending counters
  
                    if j!=len(phonemes)-1: 
                        return update_line(phonemes[j+1:], window) #recursive function !
                        logger.error("go to next chunk : {} ".format(phonemes[j+1:])) # go to the next chunk and apply the same condition
                    break
            
                else : 
                    j+=1
            else : 
                j+=1

        i+=1 #or go to the next phoneme
            
    if found==False:
        update_counters(phonemes,0,len(phonemes)-1,window)
        
    segmentation_output.append("\n")
    return(segmentation_output)
    
#### END OF PUDDLE


#### PIPELINE
#convert the dictionnary containing the lexicon found by puddle and its occurences into a list to be able to sort it by frequency            
def sort_counter(d):
    l = []
    for key, value in d.items():
        l.append((key,value))
    l_sorted = sorted(l, key = lambda x: x[1])
    l_sorted.reverse()
    return(l_sorted)

def pipeline_puddle(input_file, res_folder, output_file, window):
    ''' puddle pipeline'''
        
    #read the file without tags
    with open(input_file,'r') as f_input: 
        for line in f_input.readlines(): # get each line of the file  
            if len(line) != 0:
                line_seg=update_line(line.strip().split(), window) #split line as a list of strings which are separated by a space in the line
        output_seg=output_file
        f_seg=open(output_seg,'w')
        for word in line_seg: #the last line is the segmented output
            if word!="\n" :
                f_seg.write(word + " " )
            else: 
                f_seg.write(word)
    ### Write down the list of frequency into an ouput file 
    l=sort_counter(lexicon)
    output_freq=res_folder+'/freq-top.txt'
    f=open(output_freq,'w')
    for i in range(0,len(l)) : 
        f.write(str(l[i][1]) + " " + l[i][0]  +"\n")
      
    #list of beginning biphones with frequency
    beg=sort_counter(beginning)
    b_freq=res_folder+'/beginning-freq.txt'
    b=open(b_freq,'w')
    for i in range(0,len(beg)) : 
        b.write(str(beg[i][1])+ " " + beg[i][0]  +"\n")
        
    #list of ending biphones with frequency
    end=sort_counter(ending)
    e_freq=res_folder+'/ending-freq.txt'
    e=open(e_freq,'w')
    for i in range(0,len(end)) : 
        e.write(str(end[i][1]) + " " + end[i][0]  +"\n")
                

if __name__=="__main__":
     parser = argparse.ArgumentParser(description='Divide your corpus in k sub corpus linearly.')
     parser.add_argument('-i', '--input_file', help='absolute path of the input file')
     #parser.add_argument('-d', '--decay',   help='parameter that decrease the size of lexicon -- modelize memory of lexicon ')
     parser.add_argument('-r', '--res_folder', help='absolute path of the folder of results')
     parser.add_argument('-o', '--output_file', help='name of the output file, might change for crossvalidation')
     parser.add_argument('-w', '--window', type=int, help='number of phonemes to be taken into account for boundary constraint')
     args=parser.parse_args()
     pipeline_puddle(input_file=args.input_file, res_folder=args.res_folder, output_file=args.output_file, window=args.window)



#### END OF PIPELINE