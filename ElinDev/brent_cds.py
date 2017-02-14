# -*- coding: utf-8 -*-
"""
Created on Mon Nov 21 14:07:10 2016

@author: elinlarsen
"""

#import libraries
import os
import sys
import plotly.plotly as py
import plotly.graph_objs as go
import pandas as pd
from pandas import DataFrame
from pandas import concat
from pandas.util.testing import rands
import numpy as np
# Scientific libraries
from numpy import arange,array,ones
from scipy import stats


# importing python scripts
os.chdir('/Users/elinlarsen/Documents/CDSwordSeg/ElinDev')
import read
import translate
import analyze
import visualize
import model
import robustness

# path where are the data
path_data='/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/recipes/childes/data/Brent'
path_res='/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS'

path_tags="/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/recipes/childes/data/Brent/tags.txt"
path_gold="/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/recipes/childes/data/Brent/gold.txt"
path_ortho="/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/recipes/childes/data/Brent/ortholines.txt"
path_to_file_CDI= "/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/ComparaisonAvecAGu/TypesAllSubsInCDI"

ALGOS=['tps','dibs','puddle','AGu']
SUBS=["sub0","sub1","sub2","sub3","sub4","sub5","sub6","sub7","sub8","sub9"]


# enter your current directory
os.chdir('/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/ComparaisonAvecAGu/')


prop_understand=pd.read_csv("PropUnderstandCDI.csv", sep=None, header=0)
#prop_understand['words']=prop_understand['words'].str.replace('*', '')
#prop_understand.to_csv("PropUnderstandCDI.csv", sep='\t', index=False)

d=translate.build_phono_to_ortho(path_gold,path_ortho)
dic_corpus= translate.build_phono_to_ortho_representative(d)[0]
freq_token=translate.build_phono_to_ortho_representative(d)[1]

     
#### Look at words in common in all sub corpus and sort by frequency
In_all_SUB=analyze.common_type_in_all_sub(SUBS, path_data,name_gold="ortholines.txt")
df_in_all_sub=DataFrame(In_all_SUB.items(), columns=['Type', 'Freq'])
df_sorted=df_in_all_sub.sort('Freq', ascending=False)


#freq_word.txt for gold 
freq_brent=analyze.freq_token_in_corpus(path_ortho)
freq_brent.to_csv("/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/full_corpus/gold/freq_word.txt", sep='\t', index=False)
for ss in SUBS:
    path=path_res+"/"+ss+"/"+"gold"+"/ortholines.txt"
    freq_ss=analyze.freq_token_in_corpus(path)
    freq_ss.to_csv(path_res+"/"+ss+"/"+"gold"+"/freq-words.txt", sep='\t', index=False)



##### read file of types in all sub that are in CDI with Brent frequence
df_types_all_subs_CDI=pd.read_csv('TypesAllSubsInCDI', sep="\t", header=0)
df_types_all_subs_CDI.columns=['Type', 'Freq']
df_CDI_8=read.read_CDI_data_by_age(CDI_file="PropUnderstandCDI.csv", age=8, save_file=False)


##### lexical classes
df_CDI_lexical_classes=df_CDI_8[['Type','lexical_classes']]
df_CDI_lexical_classes.to_csv("/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/ComparaisonAvecAGu/CDI_lexical_classes.txt",sep='\t', index=False )
gb_lc=df_CDI_lexical_classes.groupby('lexical_classes')
nouns=gb_lc.get_group("nouns")
lexical_classes=gb_lc.groups
list_lexical_classes=lexical_classes.keys()
df_gb_lc=gb_lc.get_group('nouns')

#### mutiple proportion of understanding to total frequency of words in brent corpus 
#### => get the score in CDI
res_freq=df_freq_score_CDI['MeanProp']*df_freq_score_CDI['Freq']
df_freq_score_CDI['WeightedFreq']=res_freq

######################## Segmented words by ALGOS
###### Occurence of words segmented by all algos across sub
#create_file_word_freq(path_res, dic_corpus, SUBS, ALGOS, "/freq-top.txt")

#Accumulated occurence on all subcorpus of words segmented by all algos that are in CDI
df_freq_score_dibs=read.create_df_freq_by_algo_all_sub(path_res,SUBS,'dibs',"/freq-words.txt")

## This idea is to compare the frequency of words in CDI (modulated by the proportion of undertsnading of children averaged by age)
# with the frequency accumalated over sub-corpus of words segmented by all algos

################### draw score of CDI against score of all algos
data_r2=visualize.plot_algos_CDI_by_age(path_ortho,path_res, SUBS, ALGOS +['gold'], range(8,19), CDI_file="PropUnderstandCDI.csv", save_file=False, average_algos=False,freq_file="/freq-words.txt",name_visualisation= "CDIScore_AlgoScore")

#look only at gold
data_r2=visualize.plot_algos_CDI_by_age(path_ortho,path_res, SUBS, ['gold'], range(8,10), CDI_file="PropUnderstandCDI.csv", 
         average_algos=False,freq_file="/freq-words.txt",name_vis= "CDIScore_test")

#RESULTS model
df_CDI=read.read_CDI_data_by_age(CDI_file="PropUnderstandCDI.csv", age=range(), save_file=False)


lin_R2_gold=model.linear_algo_CDI(path_ortho,path_res, SUBS, ['gold'], range(8,19), CDI_file="PropUnderstandCDI.csv", 
         average_algos=False,freq_file="/freq-words.txt", out='r2')

lin_R2_gold=model.linear_algo_CDI(path_ortho,path_res, SUBS, ['gold'], range(8,19), CDI_file="PropUnderstandCDI.csv", 
         average_algos=False,freq_file="/freq-words.txt", out='r2')

lin_std_err=model.linear_algo_CDI(path_ortho,path_res, SUBS, ALGOS, range(8,19), CDI_file="PropUnderstandCDI.csv", 
         average_algos=False,freq_file="/freq-words.txt", out='std_err')
    

df_log_test=visualize.plot_logistic_algo_CDI(path_ortho,path_res, SUBS, ['gold'], range(8,19), CDI_file="PropUnderstandCDI.csv", NbInfant_file="CDI_NbInfantByAge.csv",
         average_algos=False,freq_file="/freq-words.txt",name_vis= "CDIScore_logistic_test", Test_size=0.5)

log_R2=model.logistic_algo_CDI(path_ortho,path_res, SUBS, ALGOS, range(8,19), CDI_file="PropUnderstandCDI.csv",NbInfant_file="CDI_NbInfantByAge.csv" ,
         average_algos=False,freq_file="/freq-words.txt", Test_size=0.05)

'''
R2score for LogisticRegression
Best possible score is 1.0 and it can be negative (because the model can be arbitrarily worse). 
A constant model that always predicts the expected value of y, disregarding the input features, would get a R^2 score of 0.0.
'''

### Now select proportion of understanding âge by âge 

countType=analyze.count_type_segmented_per_algo_per_sub(ALGOS,SUBS,path_res,freq_file="/freq-top.txt")    
countTypeSplit=analyze.count_type_well_segmented_per_algo_per_sub(dic_corpus,ALGOS,SUBS,path_res,freq_file="/freq-top.txt")
                        
intersection_btw_algo=analyze.compare_token_btw_algo(path_res,dic_corpus,SUBS,ALGOS,"dibs","/freq-top.txt")
     
intersection_btw_sub=analyze.compare_token_btw_sub(path_res,dic_corpus,SUBS,sub_ref="sub0",algos=ALGOS,freq_file="/freq-top.txt")
    
intersection_all_sub=analyze.compare_token_all_sub(path_res,dic_corpus,sub=SUBS,algos=ALGOS,freq_file="/freq-top.txt" )

inter_all_algo=analyze.intersection_all_algo(path_res, dic_corpus, sub=SUBS,algos=ALGOS,algo_ref="dibs",freq_file="/freq-top.txt")

ALGOS=['dibs','tps','puddle','AGu']
dibs_signature=analyze.signature_algo(path_res,dic_corpus,sub=SUBS,algo_ref="dibs",algos=ALGOS,freq_file="/freq-top.txt")
tps_signature=analyze.signature_algo(path_res,dic_corpus,sub=SUBS,algo_ref="tps",algos=ALGOS,freq_file="/freq-top.txt")
puddle_signature=analyze.signature_algo(path_res,dic_corpus,sub=SUBS,algo_ref="puddle",algos=ALGOS,freq_file="/freq-top.txt")
AGu_signature=analyze.signature_algo(path_res,dic_corpus,sub=SUBS,algo_ref="AGu",algos=ALGOS,freq_file="/freq-top.txt")

analyze.Inter_signature(dibs_signature,'dibs')
analyze.Inter_signature(puddle_signature, 'puddle')
analyze.Inter_signature(tps_signature, 'TPs')
analyze.Inter_signature(AGu_signature, 'AGu')
 
inter_all_algo=analyze.intersection_all_algo(path_res, dic_corpus, sub=SUBS,algos=ALGOS,algo_ref="dibs",freq_file="/freq-top.txt")
analyze.inter_all_algo_inter_all_sub(inter_all_algo) 

analyze.create_freq_top_gold(path_res, SUBS)

null=0
visualize.plot_algos_CDI_by_age(path_ortho,path_res, False , ALGOS +['gold'], range(8,19), CDI_file="PropUnderstandCDI.csv",freq_file="/freq-words.txt",name_vis= "CDIScore_AlgoScore_sans_fit")

visualize.plot_algos_CDI_by_age(path_ortho,path_res, ["full_corpus"], ['dibs', 'TPs, gol'],range(8,19), CDI_file="PropUnderstandCDI.csv",freq_file="/freq-words.txt", name_vis="plot_dibs_tps")
    

#test robustness f-score
mean_score_dibs=search_f_score_file_by_algo(path_res, subs=SUBS,algo='dibs',text_file="/cfgold-res.txt")
mean_score_TPs=search_f_score_file_by_algo(path_res, subs=SUBS,algo='TPs',text_file="/cfgold-res.txt")
mean_score_AGu=search_f_score_file_by_algo(path_res, subs=SUBS,algo='AGu',text_file="/cfgold-res.txt")
mean_score_puddle=search_f_score_file_by_algo(path_res, subs=SUBS,algo='puddle',text_file="/cfgold-res.txt")

R2_gold=model.linear_algo_CDI(path_ortho,path_res,["full_corpus"], ['gold'], range(8,19), CDI_file="PropUnderstandCDI.csv", freq_file="/freq-words.txt", out='r2')
   
df_gold=create_df_freq_by_algo_all_sub(path_res, ["full_corpus"], algo='gold', freq_file="/freq-words.txt")
df_dibs=create_df_freq_by_algo_all_sub(path_res, ["full_corpus"], algo='dibs', freq_file="/freq-words.txt")