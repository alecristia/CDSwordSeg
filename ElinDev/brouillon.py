#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Feb  6 18:16:56 2017

@author: elinlarsen
"""

def test(path_ortho,path_res, sub, algos, ages, CDI_file, save_file=False, average_algos=False,freq_file="/freq-words.txt", name_visualisation="plot"):
    data=[]
    #df_r_2=pd.DataFrame(0, columns=ages, index=algos+['gold'])
    df_r_2=pd.DataFrame(0, columns=ages, index=algos)
    for age in ages: 
        for algo in algos:
            print(algo)
            if algo=='gold': 
                df_algo=analyze.freq_token_in_corpus(path_ortho)
            else : 
                df_algo=read.create_df_freq_all_algo_all_sub(path_res, sub, algo, average_algos, freq_file)
            df_CDI=read.read_CDI_data_by_age(CDI_file, age, save_file=True)
            df_data=pd.merge(df_CDI, df_algo, on=['Type'], how='inner')
    return(df_data)
 
data_r2=test(path_ortho,path_res, SUBS, ['gold'], range(8,19), CDI_file="PropUnderstandCDI.csv", save_file=False, average_algos=False,freq_file="/freq-words.txt",name_visualisation= "CDIScore_AlgoScore")
