#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Fri Jun 16 15:55:21 2017

@author: elinlarsen
"""

import os
import pandas as pd
import numpy as np
from collections import Counter

os.chdir('/Users/elinlarsen/Documents/CDSwordSeg/ElinDev')

# *******  parameters *****


path_tps_syl="/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/sub0/TPs/cfgold.txt"


def create_counter_syll(tags_file):
    syllable=Counter()

    with open(tags_file,'r') as f:
        filedata = f.read()
        filedata = filedata.replace(';eword', '')
        filedata = filedata.replace(' ', '')
        filedata = filedata.replace(';esyll', ' ')

        list_lines=filedata.split() 
        
        for syl in list_lines: 
                syllable.update([syl])          
    return syllable
    

#test
tags='/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/recipes/childes/data/Brent/tags.txt'
dic_syl=create_counter_syll(tags)
path_syl_marked="/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/sub0/TPs/syllableboundaries_marked.txt"
    


def get_utterance_as_list(path_syl_boundaries_marked, path_segmented):
    utterance_seg=[]
    with open(path_segmented,'r') as text:
        for line in text: 
            utterance_seg.append(line.split("\n")[0])
            #for word in line.split():
                #list_seg.append(word)
    
    with open(path_syl_boundaries_marked,'r') as text:
        for line in text: 
            utterance_syl=line.split('UB')
            #for word in line.split():
                #list_syl.append(word)
    
    return([utterance_syl,utterance_seg])

#test
utt_syl=get_utterance_as_list('/Users/elinlarsen/Documents/marked_test.txt' ,'/Users/elinlarsen/Documents/tps_test_copie.txt')[0]
utt_seg=get_utterance_as_list('/Users/elinlarsen/Documents/marked_test.txt' ,'/Users/elinlarsen/Documents/tps_test_copie.txt')[1]


def get_count_syl_per_utterance(utt_syl, utt_seg, length_utt):

    count_syl_per_utt=[]
    for u,v in zip(utt_syl,utt_seg): 
        list_seg=[]
        list_syl=[]
        for word in u.split():
            list_syl.append(word)
        for word in v.split():
            list_seg.append(word)

        ii=0 
        while ii< len(list_syl):
            for item in list_seg:
                #print item
                #print list_syl[ii]
                count=0 # number of syllable in item 
                i=0 # i start of the syllable candidate
                while i < len(item):
                    j=0
                    while j<len(item):
                        candidate_syl=item[i:j+1]
                        
                        if candidate_syl==list_syl[ii]:
                            count+=1
                            i+=len(candidate_syl)
                            if ii<len(list_syl)-1:
                                ii+=1
                        else:
                            j+=1
                    i+=1 
            
                count_syl_per_utt.append(count)
            break
        count_syl_per_utt.append("\n")
    return(count_syl_per_utt)
        
#test 
import time

start_time = time.clock()
get_utterance_as_list('/Users/elinlarsen/Documents/marked_test.txt' ,'/Users/elinlarsen/Documents/tps_test_copie.txt')
print time.clock() - start_time, "seconds"


utt_syl=get_utterance_as_list(path_syl_marked, path_tps_syl)[0]
utt_seg=get_utterance_as_list(path_syl_marked, path_tps_syl)[1]


start_time = time.clock()
count_syl_utt=get_count_syl_per_utterance(utt_syl, utt_seg)
print time.clock() - start_time, "seconds"