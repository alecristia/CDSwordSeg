# -*- coding: utf-8 -*-
"""
Created on Wed Nov  9 15:48:57 2016

@author: elinlarsen
"""

GNU nano 2.0.9                                                                File: divide_corpus.py  
# created by elin larsen on November 8 th 2016
#can be run on terminal by using arparse
# the file takes corpus in text files of 'n' lines and divide the number of lines by 'k' 
# and return k text files with (n-r)/k lines (r = rest of euclidian division)
#!/usr/bin/python

import os
import random
import itertools
import matplotlib.pyplot as plt
import numpy as np
import collections
import operator
import sys
import argparse

def divide_corpus(text_file, k, output_dir,output_name):
    non_blank_count=0
    with open(text_file,'r') as text:
        for line in text:
            if line.strip():
                non_blank_count+=1
    q=non_blank_count/k
    r=non_blank_count%k
    with open(text_file,'r') as f:
        lines = f.readlines()
    for j in range(k):
        s="sub"+str(j)
        newpath=output_dir+s
        if not os.path.exists(newpath):
            os.makedirs(newpath)
        os.chdir(newpath)
        nom=output_dir+"/"+s+output_name
        dataFile=open(nom,'w')
        for line in lines[j*q:(j+1)*q]:
            dataFile.write(line)

if __name__=="__main__":
     parser = argparse.ArgumentParser(description='Divide your corpus in k sub corpus linearly.')
     parser.add_argument('-t', '--text_file', help='text file either orthographic, phonological or phonological with tags')
     parser.add_argument('-k', type=int,  help='number of division')
     parser.add_argument('-o', '--output_dir', help='the absolute path of your output directory')
     parser.add_argument('-n', '--output_name', help='the name of the texte file divided, for example /gold.txt')
     args=parser.parse_args()
     divide_corpus(text_file=args.text_file,k=args.k,output_dir=args.output_dir, output_name=args.output_name )