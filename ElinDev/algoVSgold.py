#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Wed Apr 19 11:34:19 2017

@author: elinlarsen
"""


#import libraries
import os
import pandas as pd
from pandas import DataFrame
import numpy as np

# importing python scripts
os.chdir('/Users/elinlarsen/Documents/CDSwordSeg/ElinDev')
import read
import translate
import analyze
import visualize
import model
import robustness


CDI_file="CDI_data/PropUnderstandCDI.csv"

os.chdir('/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/Analysis_algos_CDI/')

path_res='/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS'
freq_TP=read.create_df_freq_by_algo_all_sub(path_res, ['full_corpus'], 'TPs', 'syllable', '/freq-words.txt')
freq_TP['log_freq_TP']=np.log(freq_TP['FreqTPs'])

freq_brent=pd.read_table('/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/full_corpus/gold/freq-words.txt', sep='\t', header=0)
freq_brent['log_freq']=np.log(freq_brent['Freq'])

df_CDI_13=read.read_CDI_data_by_age(CDI_file, age=13, save_file=False)

TP_CDI=pd.merge(freq_TP, df_CDI_13, on='Type', how='inner')

TP_gold=pd.merge(freq_brent, freq_TP, on='Type', how='inner')

TP_gold[TP_gold['log_freq']>0.0001]


df_gold=read.create_df_freq_by_algo_all_sub(path_res, ['full_corpus'], 'gold','syllable', "/freq-words.txt") 
df_gold=pd.merge(df_gold, df_tag_file)
visualize.plot_algo_gold_lc(path_res, ['full_corpus'], ['TPs'], df_gold, 'syllable', 'r2', "" , group_by="lexical_class", lexical_classes=['nouns','function_words', 'adjectives', 'verbs'],freq_file="/freq-words.txt", name_vis="TP-gold")  
    