#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Thu Feb 16 10:53:35 2017

@author: elinlarsen
"""

#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Wed Feb 15 10:56:17 2017

@author: elinlarsen + J.Thomas

'Translation' of the puddle philosophy developped by P. Monaghan in a python language
Monaghan, P., & Christiansen, M. H. (2010). Words in puddles of sound: modelling psycholinguistic effects in speech segmentation. Journal of child language, 37(03), 545-564.

The fonction update_line is a recursive function that takes as input a list of phonemes (ie character separated by space) defining all together an utterance


"""

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
lexicon=Counter() 
beginning=Counter()
ending=Counter()
segmentation_output=[]  #empty list that will be filled by word chunks, do not put it in the updata_line function, otherwise it will empty for each line, pre word will be lost

def update_line(phonemes, window):
       
    if len(phonemes) == 0: #check if the list of phonemes is not null
        raise NotImplementedError
       
    found = False # at first, no match is found
    i = 0
    
    while i < len(phonemes) and (found == False): #look at all phonemes in the list while no match between a string of phonemes and a word_candidate in the lexicon is found             
        
        bb="".join(phonemes[i:i+window]) #beginning biphonemes, should prevent to have individual phonemes as lexical item
        
        if bb in beginning:
                 
            for j in range(i+1,len(phonemes)+1):# look at every possible merge between the phoneme n° i and phoneme n°i+1, i+2, ..., len(phonemes)     
                #boundary condition satisfied ? 
                
                candidate_list = phonemes[i:j]
                candidate_word = "".join(candidate_list)
                candidate_pre_word="".join(phonemes[:i]) 
                    
                if candidate_word in lexicon:
                    found = True
                    #logger.info("Candidate {} found in lexicon".format(candidate_word)) #print in the log file
                    if i!=0: 
                        segmentation_output.append(candidate_pre_word)
                        logger.warning(" pre word {} added in segmentation output".format(candidate_pre_word))
                        
                    if (i>= window) and (found==True) and ("".join(phonemes[i-1-window:i-1]) not in ending) : #two previous phonemes (number determined by 'window')must be word-end
                       found=False
                    
                    if (i==window-1) and (found==True) and (phonemes[i-1] not in ending) : #one previous phoneme must be word-end, exemple 'g' before 'ow' starting an utterance (go)
                       found=False
                   
                    if (j<=(len(phonemes)-window)) and (found==True) and ("".join(phonemes[j+1:j+1+window]) not in beginning) : # 2 post phonemes (number determined by 'window') must be word-start
                       found=False  
                       
                    if (j==(len(phonemes)-window-1)) and (found==True) and (phonemes[j+1] not in beginning) : # post phoneme  must be word-start
                       found=False
                                 
                    if (found==True) and (i != 0):
                        lexicon.update([candidate_pre_word])
                        logger.info("Candidate pre word {} not found in lexicon added".format(candidate_pre_word))
                        if len(phonemes[:i])>=2: # f the list of phonemes before the word chunk consideredhas more than 2phonemes
                            beginning.update(["".join(phonemes[0:window])])
                            ending.update(["".join(phonemes[i-window:i])])
                            logger.info("Bi-phonemes {} added in beginning".format("".join(phonemes[0:window])))
                            logger.info("Bi-phonemes {} added in ending".format("".join(phonemes[i-window:i])))
                        
                    if found==True: 
                        if len(candidate_list)>=window:
                            beginning.update(["".join(candidate_list[0:window])]) #beginning BI-phonemes added
                            ending.update(["".join(candidate_list[-window:])])  #ending BI-phonemes added
                            logger.info( "Bi-phonemes {} added in beginning".format("".join(candidate_list[0:window])))
                            logger.info( "Bi-phonemes {} added in ending".format("".join(candidate_list[-window:])))
                    lexicon.update([candidate_word])
                    logger.info( "Candidate word {} added in lexicon".format(candidate_word))
                    segmentation_output.append(candidate_word)
                    logger.warning("word {} added in segmentation output".format(candidate_word))
                        
                    if (j != len(phonemes)) and (len(phonemes)>=window) : #
                        return update_line(phonemes[j:], window) #repeat the procedure for the list of phonemes without the previous phonemes n° 1, ..., j-1
                       
                    break  
            else:
                pass
        i+=1
    
    if (found != True) :
        if len(phonemes)>=window: # if the list of phoneme considered has more than 2 phonemes, add it to lexicon 
            beginning.update(["".join(phonemes[0:window])])
            logger.info( " Bi-phonemes {} added in beginning".format("".join(phonemes[0:window])))
            ending.update(["".join(phonemes[i-window:i])])
            logger.info("Bi-phonemes {} added in ending ".format("".join(phonemes[i-window:i])))
            lexicon.update(["".join(phonemes)])
            logger.info( " Utterance or end-of-utterance not in lexicon {} added ".format("".join(phonemes)))
        segmentation_output.append("".join(phonemes))
        logger.warning("chunk {} added in segmentation output".format("".join(phonemes)))
    
    segmentation_output.append("\n") #go back to line at the end of the utterance segmented    
    
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
def pipeline_puddle(path_tags_file, res_folder, output_file, window):
    ''' puddle pipeline'''
    #replace tags by space and delete double ande triple space
    with open(path_tags_file,'r') as f:
        filedata = f.read()
        filedata = filedata.replace(';esyll', '') # to join phonemes between ';esyll' if the unity of input wanted is syllable
        filedata = filedata.replace(';eword', '')
        filedata = filedata.replace('  ', ' ')
        filedata = filedata.replace('  ', ' ')
        
    #write the input of algo
    with open(res_folder+ '/input.txt', 'w') as file:
        file.write(filedata)
            
    #read the file without tags
    with open(res_folder+ '/input.txt','r') as f_input: 
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
     parser.add_argument('-p', '--path_tags_file', help='the absolute path of your tags file')
     #parser.add_argument('-d', '--decay',   help='parameter that decrease the size of lexicon -- modelize memory of lexicon ')
     parser.add_argument('-r', '--res_folder', help='absolute path of the folder of results')
     parser.add_argument('-o', '--output_file', help='name of the output file, might change for crossvalidation')
     parser.add_argument('-w', '--window', type=int, help='number of phonemes to be taken into account for boundary constraint')
     args=parser.parse_args()
     pipeline_puddle(path_tags_file=args.path_tags_file,res_folder=args.res_folder, output_file=args.output_file, window=args.window)