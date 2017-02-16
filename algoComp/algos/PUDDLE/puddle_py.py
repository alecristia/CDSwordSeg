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
logger.setLevel(logging.INFO) #to be change in ' logger.setLevel(logging.INFO)' to get all the print 

#formateur
formatter = logging.Formatter(
   '%(asctime)s -- %(name)s -- %(levelname)s -- %(message)s')

#console handler 
fileHandler = logging.FileHandler('puddle_test/puddle.log')
fileHandler.setFormatter(formatter)
logger.addHandler(fileHandler)

#consoleHandler = logging.StreamHandler()
#consoleHandler.setFormatter(formatter)
#logger.addHandler(consoleHandler)


### Main fonction of the puddle
'''
lexicon, beginning and ending are counters (ie dictionnary that identify a string with its occurence)
they are global variable (out of the update_line function) in order to avoid for python to store twice the counters
'''
 
lexicon = Counter()
beginning = Counter()
ending = Counter()


def update_line(phonemes, window):
    
    segmentation_output=[] #empty list that will be filled by word chunks
    #check if the list of phonemes is not null
    if len(phonemes) == 0:
        raise NotImplementedError
       
    found = False # at first, no match is found
    i = 0
    
    while i < len(phonemes) and (found == False): #look at all phonemes in the list while no match between a string of phonemes and a word_candidate in the lexicon is found             
        
        bb="".join(phonemes[i:i+2]) #beginning biphonemes, should prevent to have individual phonemes as lexical item
        
        if bb in beginning:
                 
            for j in range(i+1,len(phonemes)+1):# look at every possible merge between the phoneme n° i and phoneme n°i+1, i+2, ..., len(phonemes)     
                #boundary condition satisfied ? 
                
                candidate_list = phonemes[i:j]
                candidate_word = "".join(candidate_list)
                candidate_pre_word="".join(phonemes[:i]) 
                    
                if candidate_word in lexicon:
                    found = True
                    #logger.info("Candidate {} found in lexicon".format(candidate_word)) #print in the log file
                    
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
                        segmentation_output.append(candidate_pre_word)
                        if len(phonemes[:i])>=2: # f the list of phonemes before the word chunk consideredhas more than 2phonemes
                            beginning.update(["".join(phonemes[0:2])])
                            ending.update(["".join(phonemes[i-2:i])])
                            logger.info("Bi-phonemes {} added in beginning".format("".join(phonemes[0:2])))
                            logger.info("Bi-phonemes {} added in ending".format("".join(phonemes[i-2:i])))
                        
                    if found==True: 
                        if len(candidate_list)>=2:
                            beginning.update(["".join(candidate_list[0:2])]) #beginning BI-phonemes added
                            ending.update(["".join(candidate_list[-2:])])  #ending BI-phonemes added
                            logger.info( "Bi-phonemes {} added in beginning".format("".join(candidate_list[0:2])))
                            logger.info( "Bi-phonemes {} added in ending".format("".join(candidate_list[-2:])))
                    lexicon.update([candidate_word])
                    logger.info( "Candidate word {} added in lexicon".format(candidate_word))
                    segmentation_output.append(candidate_word)
                        
                    if j != len(phonemes):
                        return update_line(phonemes[j:], window) #repeat the procedure for the list of phonemes without the previous phonemes n° 1, ..., j-1
                    break
            
            else:
                pass
        i+=1
    
    if found != True and len(phonemes)>=2: # if the list of phoneme considered has more than 2 phonemes
            beginning.update(["".join(phonemes[0:2])])
            logger.info( " Bi-phonemes {} added in beginning".format("".join(phonemes[0:2])))
            ending.update(["".join(phonemes[i-2:i])])
            logger.info("Bi-phonemes {} added in ending ".format("".join(phonemes[i-2:i])))
            lexicon.update(["".join(phonemes)])
            logger.info( " Utterance or end-of-utterance not in lexicon {} added ".format("".join(phonemes)))
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
def pipeline_puddle(tags_file, res_folder, window):
    ''' puddle pipeline'''
    with open(tags_file,'r') as f:
        #replace tags by space and delete double ande triple space
        filedata = f.read()
        filedata = filedata.replace(';esyll', '')
        filedata = filedata.replace(';eword', '')
        filedata = filedata.replace('  ', ' ')
        filedata = filedata.replace('  ', ' ')
        
    #write the input of algo
    with open(res_folder+ '/input.txt', 'w') as file:
        file.write(filedata)
            
    #read the file without tags
    with open(res_folder+ '/input.txt','r') as f_input: 
        
        output_seg=res_folder+'/cfgold.txt'
        f_seg=open(output_seg,'w')
        for line in f_input.readlines(): # get each line of the file  
            if len(line) != 0:
                line_seg=update_line(line.strip().split(), window)#split line as a list of strings which are separated by a space in the line
                for word in line_seg:
                    f_seg.write(word + " " )
                f_seg.write("\n")
    ### Write down the list of frequency into an ouput file 
    l=sort_counter(lexicon)
    output_freq=res_folder+'/freq-top.txt'
    f=open(output_freq,'w')
    for i in range(0,len(l)) : 
        f.write(l[i][0] + " " + str(l[i][1]) +"\n")
      
    #list of beginning biphones with frequency
    b_freq==res_folder+'/beginning-freq.txt'
    b=open(b_freq,'w')
    for i in range(0,len(l)) : 
        b.write(l[i][0] + " " + str(l[i][1]) +"\n")
        
    #list of ending biphones with frequency
    e_freq==res_folder+'/ending-freq.txt'
    e=open(e_freq,'w')
    for i in range(0,len(l)) : 
        e.write(l[i][0] + " " + str(l[i][1]) +"\n")
        

if __name__=="__main__":
     parser = argparse.ArgumentParser(description='Divide your corpus in k sub corpus linearly.')
     parser.add_argument('-s', '--output_seg', help='the absolute path of your output directory where segmentation of input will be put')
     #parser.add_argument('-d', '--decay',   help='parameter that decrease the size of lexicon -- modelize memory of lexicon ')
     parser.add_argument('-w', '--window', type=int, help='number of phonemes to be taken into account for boundary constraint')
     parser.add_argument('-r', '--res_folder', type=int, help='absolute path of the folder of results')
     args=parser.parse_args()
     pipeline_puddle(input_file=args.input_file,res_folder=args.res_folder , window=args.window)
     

### Apply function to file
full_brent='/Users/elinlarsen/Documents/puddle_test/Brent/tags.txt'
#brent_child='/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/recipes/childes/data/Brent/c1-0902/tags.txt'
test='/Users/elinlarsen/Documents/puddle_test/tags_test.txt'

#python puddle.py -i /../../../CDSwordSeg_Pipeline/recipes/childes/data/  
res ='/Users/elinlarsen/Documents/puddle_test/Brent'
pipeline_puddle(full_brent, res, window=2)      #PROELEME AVEC LE LEXICON in or out the fonction ?

#test update line
'''
seg_test=[]
with open(test,'r') as test: 
    for line in test.readlines():
        seg_test.append(update_line(line.strip().split(" "), 2))


with open(test,'r') as t:
    for line in t.readlines():
        line.replace(';esyll', '')
        line.replace(';eword', '')
        print(line)        

# Read in the file
filedata = None
with open(test, 'r') as file :
  filedata = file.read()

# Replace the target string
filedata = filedata.replace(';esyll', '')
filedata = filedata.replace(';eword', '')
filedata = filedata.replace('  ', ' ')
filedata = filedata.replace('  ', ' ')

#write the input of algo
with open('puddle_test/input_test.txt', 'w') as file:
  file.write(filedata)
'''