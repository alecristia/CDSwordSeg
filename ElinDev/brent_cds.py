# -*- coding: utf-8 -*-
"""
Created on Mon Nov 21 14:07:10 2016

@author: elinlarsen
"""
import os
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


os.chdir('/Users/elinlarsen/Documents/CDSwordSeg/results/res-brent-CDS/ComparaisonAvecAGu/')

path_data='/Users/elinlarsen/Documents/CDSwordSeg/recipes/childes/data/Brent'
path_res='/Users/elinlarsen/Documents/CDSwordSeg/results/res-brent-CDS'

ALGOS=['tps','dibs','puddle','AGu']
SUBS=["sub0","sub1","sub2","sub3","sub4","sub5","sub6","sub7","sub8","sub9"]

path_tags="/Users/elinlarsen/Documents/CDSwordSeg/recipes/childes/data/Brent/tags.txt"
path_gold="/Users/elinlarsen/Documents/CDSwordSeg/recipes/childes/data/Brent/gold.txt"
path_ortho="/Users/elinlarsen/Documents/CDSwordSeg/recipes/childes/data/Brent/ortholines.txt"
path_to_file_CDI= "/Users/elinlarsen/Documents/CDSwordSeg/results/res-brent-CDS/ComparaisonAvecAGu/TypesAllSubsInCDI"

prop_understand=pd.read_csv("PropUnderstandCDI.csv", sep=None, header=0)
prop_understand['words']=prop_understand['words'].str.replace('*', '')
prop_understand.to_csv("PropUnderstandCDI.csv", sep='\t', index=False)

d=build_phono_to_ortho(path_gold,path_ortho)
dic_corpus= build_phono_to_ortho_representative(d)[0]
freq_token=build_phono_to_ortho_representative(d)[1]
list_freq=[]
word_freq=[]
for i in range(len(freq_token)): 
    list_freq.append(freq_token[i][0])
    word_freq.append(freq_token[i][1])
     
#### Look at words in common in all sub corpus and sort by frequency
In_all_SUB=common_type_in_all_sub(SUBS, path_data,name_gold="ortholines.txt")
df_in_all_sub=DataFrame(In_all_SUB.items(), columns=['Type', 'Freq'])
df_sorted=df_in_all_sub.sort('Freq', ascending=False)
# save in mac
df_sorted.to_csv('TypesInCommonInAllSubs', sep='\t', index=False)
freq_brent=freq_token_in_corpus(path_ortho)

# replace frequency by the global frequency in brent corpus
del df_sorted['Freq']
s= pd.merge(freq_brent, df_sorted, how='inner', on=['Type'])
s.to_csv('TypesAllSubs_FreqBrent', sep='\t', index=False)

##### read file of types in all sub that are in CDI with Brent frequence
df_types_all_subs_CDI=pd.read_csv('TypesAllSubsInCDI', sep="\t", header=0)
df_types_all_subs_CDI.columns=['Type', 'Freq']

###### read file with proportion of babies understanding words in CDI
# If you want the proportionof understanding averaged by age
df_mean=read_CDI_data_by_age(file_CDI="PropUnderstandCDI.csv", age='all', save_file=True)

# If you want the proportion of understanding of babies for a certain age 
age_choosed=8
df_age_8=read_CDI_data_by_age(file_CDI="PropUnderstandCDI.csv", age=age_choosed, save_file=False)
df_age_18=read_CDI_data_by_age(file_CDI="PropUnderstandCDI.csv", age=18, save_file=False)


##### intersection of type in two dataframe of words in CDI
df_freq_score_CDI=pd.merge(df_types_all_subs_CDI,df_mean, on=['Type'], how='inner' )


#### mutiple proportion of understanding to total frequency of words in brent corpus 
#### => get the score in CDI
res_freq=df_freq_score_CDI['MeanProp']*df_freq_score_CDI['Freq']
df_freq_score_CDI['WeightedFreq']=res_freq

######################## Segmented words by ALGOS
###### Occurence of words segmented by all algos across sub
create_file_word_freq(path_res, dic_corpus, SUBS, ALGOS, "/freq-top.txt")
select_word_segmented_in_CDI('/Users/elinlarsen/Documents/CDSwordSeg/results/res-brent-CDS/sub0/AGu/freq-words.txt', "TypesAllSubsInCDI", "AGu")

#Accumulated occurence on all subcorpus of words segmented by all algos that are in CDI
df_freq_score_algo=create_df_freq_all_algo_all_sub(path_res,SUBS,ALGOS,path_to_file_CDI,"/freq-words.txt")

## This idea is to compare the frequency of words in CDI 
# (modulated by the proportion of undertsnading of children averaged by age)
# with the frequency accumalated over sub-corpus of words segmented by all algos

################### draw score of CDI against score of all algos
data_r2=plot_algos_CDI_fit_by_age(path_ortho,path_res, SUBS, ALGOS, range(8,19), CDI_file="PropUnderstandCDI.csv", save_file=False, average_algos=False,freq_file="/freq-words.txt")

all_data=pd.DataFrame(all_data)
all_data.to_csv('Data_CDI_algo_combined.csv', sep='\t', index=True)

# plot R2 
data_r2=[]
for algo in ALGOS:
    trace_r2=go.Bar(
            x=range(8,19),
            y=fit_data.iloc[ALGOS.index(algo),:],
            name= algo ,
            showlegend=True,)
    data_r2.append(trace_r2)
layout=go.Layout(
    barmode='group',
    title='Evolution of R2 for different of age of children',
    xaxis=dict(title='Age of children '),
    yaxis=dict(title=' Coefficient of correlation R2 (CDI score fitting algo score) '),
    )
fig = go.Figure(data=data_r2, layout=layout)
py.iplot(fig, filename='grouped-bar')



### Now select proportion of understanding âge by âge 

countType=count_type_segmented_per_algo_per_sub(ALGOS,SUBS,path_res,freq_file="/freq-top.txt")    
countTypeSplit=count_type_well_segmented_per_algo_per_sub(dic_corpus,ALGOS,SUBS,path_res,freq_file="/freq-top.txt")
                        
intersection_btw_algo=compare_token_btw_algo(path_res,dic_corpus,SUBS,ALGOS,"dibs","/freq-top.txt")
     
intersection_btw_sub=compare_token_btw_sub(path_res,dic_corpus,SUBS,sub_ref="sub0",algos=ALGOS,freq_file="/freq-top.txt")
    
intersection_all_sub=compare_token_all_sub(path_res,dic_corpus,sub=SUBS,algos=ALGOS,freq_file="/freq-top.txt" )

inter_all_algo=intersection_all_algo(path_res, dic_corpus, sub=SUBS,algos=ALGOS,algo_ref="dibs",freq_file="/freq-top.txt")

ALGOS=['dibs','tps','puddle','AGu']
dibs_signature=signature_algo(path_res,dic_corpus,sub=SUBS,algo_ref="dibs",algos=ALGOS,freq_file="/freq-top.txt")
tps_signature=signature_algo(path_res,dic_corpus,sub=SUBS,algo_ref="tps",algos=ALGOS,freq_file="/freq-top.txt")
puddle_signature=signature_algo(path_res,dic_corpus,sub=SUBS,algo_ref="puddle",algos=ALGOS,freq_file="/freq-top.txt")
AGu_signature=signature_algo(path_res,dic_corpus,sub=SUBS,algo_ref="AGu",algos=ALGOS,freq_file="/freq-top.txt")

Inter_signature(dibs_signature,'dibs')
Inter_signature(puddle_signature, 'puddle')
Inter_signature(tps_signature, 'TPs')
Inter_signature(AGu_signature, 'AGu')
 
inter_all_algo=intersection_all_algo(path_res, dic_corpus, sub=SUBS,algos=ALGOS,algo_ref="dibs",freq_file="/freq-top.txt")
inter_all_algo_inter_all_sub(inter_all_algo) 







