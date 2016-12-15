# -*- coding: utf-8 -*-
"""
Created on Thu Dec 15 11:39:15 2016

@author: elinlarsen
"""

import os 
import random
import itertools
import matplotlib.pyplot as plt
import numpy as np
import collections
import operator
from itertools import izip
import glob

#########################  MERGE data files (ortholines, tags, gold) of each child to get a big corpus 
def merge_data_files(corpus_path, name_corpus, name_file):
    ''' name_file ="/ortholines.txt", "/tags.txt", "/gold.txt" '''
    ''' the output is writtent in the current working directory'''
    path=corpus_path + "*" + "/"+ name_file                  
    for file in glob.glob(path):
        with open(file,'r') as infile:
            with open(corpus_path+name_file,'a') as outfile:
                for line in infile:
                    outfile.write(line)
#TEST        
os.chdir('/Users/elinlarsen/Documents/CDSwordSeg/recipes/childes/data')
merge_data_files(corpus_path="/Users/elinlarsen/Documents/CDSwordSeg/recipes/childes/data/Providence/", name_corpus="Brent", name_file="ortholines.txt")


######################### OPEN TEXT FILE AS LIST OF TOKEN
def corpus_as_list(corpus_file):
    ''' open a text file and form a list of tokens'''
    list_corpus=[]
    with open(corpus_file,'r') as text:
        for line in text: 
            for word in line.split():
                list_corpus.append(word)
    return(list_corpus)
    

######################### OPEN FREQ FILE AS A LIST OF TOKEN 
def list_freq_token_per_algo(algo,sub,path_res,freq_file="/freq-top.txt"):
    algo_list=[]
    if algo!="ngrams": 
    ### read only the second columns: top frequent phonological type segmented 
        with open(path_res+"/"+sub+"/"+algo+freq_file) as inf:
            for line in inf:
                parts = line.split() # split line into parts
                if len(parts) > 1:   # if at least 2 parts/columns
                    #if parts[0]>1:
                    algo_list.append(parts[1])
    else : 
        with open(path_res+"/"+sub+"/"+algo+freq_file) as inf:
            for line in inf:
                parts = line.split() # split line into parts
                if len(parts) > 2:   # if at least 3 parts/columns
                    #if parts[0]>1:
                    algo_list.append(parts[2])
    #res=[algo_list,len(algo_list)]
    res=algo_list
    return(res)