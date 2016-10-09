# -*- coding: utf-8 -*-
"""
Created on Tue Sep 27 10:31:37 2016

@author: elinlarsen

Script that creates a dictionnary of orthographic word gold (ortholines.txt)to phologic word gold. (gold.txt)

"""

import os 
import random

path="/Users/elinlarsen/Documents/CDSwordSeg/recipes/bernstein/data_06_10/ADS/phono/"
path_file="/Users/elinlarsen/Documents/CDSwordSeg/recipes/bernstein/data_06_10/ADS/phono/tags.txt"
k=10
corpus_as_list(corpus_file=path_file)


''' Find a file in python'''
import os

def find(name, path):
    for root, dirs, files in os.walk(path):
        if name in files:
            return os.path.join(root, name)
            
            
def find_all(name, path):
    result = []
    for root, dirs, files in os.walk(path):
        if name in files:
            result.append(os.path.join(root, name))
    return result
    
import os, fnmatch
def find(pattern, path):
    result = []
    for root, dirs, files in os.walk(path):
        for name in files:
            if fnmatch.fnmatch(name, pattern):
                result.append(os.path.join(root, name))
    return result

find('*.txt', '/path/to/dir')