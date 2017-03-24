#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Tue Mar  7 17:12:46 2017

@author: elinlarsen


build a lexicon f-score
"""

import decimal
D=decimal.Decimal
import pandas as pd

import read

def get_lexicon_f_score(dic_gold, df_algo_output):
    count=0
    for chunk in dic_algo_output: 
        if chunk in dic_gold.keys(): 
            count+=1
        else : 
            pass
    f_score=count/len(dic_gold)
    return f_score
     
     
## other stratehy compare phonological gold 
from collections import Counter

path_res='/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS'
path_gold="/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/recipes/childes/data/Brent/gold.txt"
ALGOS=['tps', 'dibs', 'puddle_py', 'AGu']
units=['syllable', 'phoneme']

gold=Counter()
list_gold=read.corpus_as_list(path_gold)
for word in list_gold : 
    gold.update([word])
  
lexicon_recall=pd.DataFrame(0, columns=units, index=ALGOS)
lexicon_prec=pd.DataFrame(0, columns=units, index=ALGOS)
lexicon_fs=pd.DataFrame(0, columns=units, index=ALGOS)

for algo in ALGOS : 
  for unit in units :
     dic_algo=Counter()
     dic_error=Counter()  
     path=path_res+'/full_corpus'+'/'+algo +'/'+unit +"/cfgold.txt"
     list_token=read.corpus_as_list(path)
     for word in list_token : 
         if word in gold : 
             dic_algo.update([word])
         else: 
             dic_error.update([word])
     lexicon_recall.iloc[ALGOS.index(algo),units.index(unit)]=D(len(dic_algo))/D(len(gold))
     lexicon_prec.iloc[ALGOS.index(algo),units.index(unit)]=D(len(dic_algo))/(D(len(dic_algo))+D(len(dic_error)))
     R=lexicon_recall.iloc[ALGOS.index(algo),units.index(unit)]
     P=lexicon_prec.iloc[ALGOS.index(algo),units.index(unit)]
     lexicon_fs.iloc[ALGOS.index(algo),units.index(unit)]=D(2*P*R)/D(P+R)

path='/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/Analysis_algos_CDI/13mois/'
lexicon_fs.to_csv(path+'lexicon.txt', sep='\t', header=True )
lexicon_recall.to_csv(path+'lexicon_recall.txt', sep='\t', header=True)
lexicon_prec.to_csv(path+'lexicon_prec.txt', sep='\t', header=True)