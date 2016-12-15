# -*- coding: utf-8 -*-
"""
Created on Thu Dec 15 11:44:52 2016

@author: elinlarsen
"""


######################### CREATION OF SUB-CORPUS : the whole corpus is divided k times
def divide_corpus(text_file,k, output_dir,output_name="/gold.txt"):
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
#test            
divide_corpus("/Users/elinlarsen/Documents/CDSwordSeg/recipes/childes/data/Brent/tags.txt",k=10,output_dir="/Users/elinlarsen/Documents/CDSwordSeg/recipes/childes/data/Brent/",output_name="/tags.txt")            
