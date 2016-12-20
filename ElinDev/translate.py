# -*- coding: utf-8 -*-
"""
Created on Thu Dec 15 11:45:59 2016

@author: elinlarsen
"""

import collections
from itertools import izip
import pandas as pd

#import file 
import read

######################### Dictionnary from phono text to ortho text
# open ortho and gold file and check if in each line, the number of words match
# if not, skip the line and count the error, 
# then create a dictionarry with key each phono token and value a dictionary  of ortho token with their occurence
def build_phono_to_ortho(phono_file, ortho_file):
    count_errors = 0
    d=collections.defaultdict(dict)
    with open(phono_file,'r') as phono, open(ortho_file,'r') as ortho:
            for line_phono, line_ortho in izip(phono, ortho):
                line_phono = line_phono.lower().split()
                line_ortho = line_ortho.lower().split()
                if len(line_phono) != len(line_ortho):
                    count_errors += 1
                else:
                    for word_phono, word_ortho in izip(line_phono, line_ortho):
                        count_freq = d[word_phono]
                        try:
                            count_freq[word_ortho] += 1
                        except:
                            count_freq[word_ortho] = 1
    print "There were {} errors".format(count_errors)
    return d
    
    
#########################  list of two dictionaries: 
# 1. one of phono token and the most representative ortho token
# 2. one linking token to their freqency 
def build_phono_to_ortho_representative(d):
    res ={}
    token_freq={}
    for d_key,d_value in d.iteritems():
        value_max=0
        key_max = 'undefined'
        for key, value in d_value.iteritems():
            if value > value_max:
                value_max = value
                key_max = key
        res[d_key] = key_max
        token_freq[value_max]=key_max
    #freq_token = {v: k for k, v in token_freq.iteritems()}
    freq_res=sorted(token_freq.items(),reverse=True)
    return([res,freq_res])
    

##### look at well segmented words in all algos and in all subs
##### from "freq-file.txt" in phonological form to orthographic form
##### for each results of each algo in each subcorpus, create the file in the orthographic form
def create_file_word_freq(path_res, dic, sub, algos, freq_file="/freq-top.txt"):
    for SS in sub:
        for algo in algos: 
            path=path_res+"/"+SS+"/"+algo+freq_file
            df_token=pd.read_table(path,sep=None, header=None, names=('Freq','phono'),  index_col=None)
            list_token=read.list_freq_token_per_algo(algo,SS,path_res,freq_file)
            d={}
            for item in list_token: 
                if dic.has_key(item)==True: 
                    d[item]=dic[item]
            df_dic_token=pd.DataFrame(d.items(),columns=['phono', 'Type'])
            s=pd.merge(df_token, df_dic_token, how='inner', on=['phono'])
            del s['phono']
            s.drop_duplicates(subset='Type', keep='first',inplace=True)
            path_out=path_res+"/"+SS+"/"+algo+"/freq-words.txt"
            s.to_csv(path_out, sep='\t', index=False)
    