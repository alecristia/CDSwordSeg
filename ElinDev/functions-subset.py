# -*- coding: utf-8 -*-
"""
Created on Sat Oct  8 14:27:39 2016

@author: elinlarsen
"""

import os
import random 

def corpus_as_list(corpus_file='/Users/elinlarsen/Documents/CDSwordSeg/recipes/bernstein/data_06_10/ADS/phono/tags.txt'):
    list_corpus=[]
    with open(corpus_file,'r') as text:
        for line in text:
            for word in line.split():
                list_corpus.append(word)
    return(list_corpus)

def div_list(list_corpus, k,output_dir,name_corpus):
    q=len(list_corpus)/k
    r=len(list_corpus)%k
    res=[]
    for i in range(q+1):
        res.append(list_corpus[i*q:(i+1)*q])
    if not r==0:
        res[-1]+=list_corpus[:-r]
    for i in range(k):
        nom=output_dir+"sub"+name_corpus +"_"+ str(i) + ".txt"
        dataFile=open(nom,'w')
        for eachitem in res[i]:
            dataFile.write(str(eachitem))
    return(res)

                        
            