# -*- coding: utf-8 -*-
"""
Created on Fri Feb 24 10:45:32 2017

@author: elinlarsen
"""


from collections import Counter


def create_counter_syll(corpus_file):
    syllable=Counter()

    with open(corpus_file,'r') as c:
        list_file=c.readlines() 
        corpus_as_list=list_file[0] 

        list_lines=corpus_as_list.split('UB')
        print list_lines[:10]
        
        for line in list_lines: 
            for syl in line.split() :
                syllable.update([syl])          
    return syllable
    
#test
c='/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/full_corpus/TPs/syllable/boundaries_marked.txt'
tags='/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/recipes/childes/data/Brent/tags.txt'
dic=create_counter_syll(tags)


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
    