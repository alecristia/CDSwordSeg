# -*- coding: utf-8 -*-
"""
Created on Mon Nov 21 14:07:10 2016

@author: elinlarsen
"""

import plotly.plotly as py
import plotly.graph_objs as go

path_data='/Users/elinlarsen/Documents/CDSwordSeg/recipes/childes/data'
path_res='/Users/elinlarsen/Documents/CDSwordSeg/results/res-brent-cds'

ALGOS=['tps','dibs','puddle']
SUBS=["sub0","sub1","sub2","sub3","sub4","sub5","sub6","sub7","sub8","sub9"]

path_tags="/Users/elinlarsen/Documents/CDSwordSeg/recipes/childes/data/Brent/tags.txt"
path_gold="/Users/elinlarsen/Documents/CDSwordSeg/recipes/childes/data/Brent/gold.txt"
path_ortho="/Users/elinlarsen/Documents/CDSwordSeg/recipes/childes/data/Brent/ortholines.txt"


d=build_phono_to_ortho(path_gold,path_ortho)
dic_corpus= build_phono_to_ortho_representative(d)[0]
freq_token=build_phono_to_ortho_representative(d)[1]
list_freq=[]
word_freq=[]
for i in range(len(freq_token)): 
    list_freq.append(freq_token[i][0])
    word_freq.append(freq_token[i][1])
    
    
countType=count_type_segmented_per_algo_per_sub(ALGOS,SUBS,path_res,freq_file="/freq-top.txt")    
countTypeSplit=count_type_well_segmented_per_algo_per_sub(dic_corpus,ALGOS,SUBS,path_res,freq_file="/freq-top.txt")
                        
intersection_btw_algo=compare_token_btw_algo(path_res,dic_corpus,SUBS,ALGOS,"dibs","/freq-top.txt")
     
intersection_btw_sub=compare_token_btw_sub(path_res,dic_corpus,SUBS,sub_ref="sub0",algos=ALGOS,freq_file="/freq-top.txt")
    
intersection_all_sub=compare_token_all_sub(path_res,dic_corpus,sub=SUBS,algos=ALGOS,freq_file="/freq-top.txt" )

inter_all_algo=intersection_all_algo(path_res, dic_corpus, sub=SUBS,algos=ALGOS,algo_ref="dibs",freq_file="/freq-top.txt")


ALGOS=['dibs','tps','puddle']
dibs_signature=signature_algo(path_res,dic_corpus,sub=SUBS,algo_ref="dibs",algos=ALGOS,freq_file="/freq-top.txt")
tps_signature=signature_algo(path_res,dic_corpus,sub=SUBS,algo_ref="tps",algos=ALGOS,freq_file="/freq-top.txt")
puddle_signature=signature_algo(path_res,dic_corpus,sub=SUBS,algo_ref="puddle",algos=ALGOS,freq_file="/freq-top.txt")

Inter_signature(dibs_signature,'dibs')
Inter_signature(puddle_signature, 'puddle')

 
inter_all_algo=intersection_all_algo(path_res, dic_corpus, sub=SUBS,algos=ALGOS,algo_ref="dibs",freq_file="/freq-top.txt")
inter_all_algo_inter_all_sub(inter_all_algo) 

import plotly 
plotly.tools.set_credentials_file(username='elarsen', api_key='eotx5duava')
from plotly import __version__
from plotly.offline import download_plotlyjs, init_notebook_mode, plot, iplot
print __version__
from plotly.graph_objs import Scatter, Figure, Layout
plot([Scatter(x=range(len(list_freq)), y=list_freq)])



