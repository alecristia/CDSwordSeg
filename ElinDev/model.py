#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Tue Feb  7 16:18:08 2017

@author: elinlarsen
"""

import plotly 
#plotly must have downloaded  cf https://plot.ly/python/getting-started/
# open spyder from terminal !
import plotly.plotly as py
import plotly.graph_objs as go
import pandas as pd
import itertools

# Scientific libraries
import numpy as np
from scipy import stats
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score

#import file
import read
import analyze


def linear_algo_CDI(path_ortho,path_res, sub, algos, unit,ages, CDI_file,freq_file="/freq-words.txt", out='r2'):
    df_r_2=pd.DataFrame(0, columns=ages, index=algos)
    df_std_err=pd.DataFrame(0, columns=ages, index=algos)
    for age in ages: 
        for algo in algos:
            df_CDI=read.read_CDI_data_by_age(CDI_file, age, save_file=False)
            df_algo=analyze.freq_token_in_corpus(path_ortho)
            df_data=pd.merge(df_CDI, df_algo, on=['Type'], how='inner')
            if algo=='gold': 
                df_algo=analyze.freq_token_in_corpus(path_ortho)
            else : 
                df_algo=read.create_df_freq_by_algo_all_sub(path_res, sub, algo,unit, freq_file)
            df_data=pd.merge(df_CDI, df_algo, on=['Type'], how='inner')
            x=np.log(df_data['Freq'+algo])
            y=df_data['prop']
            slope, intercept, r_value, p_value, std_err = stats.linregress(x,y)
            df_r_2.iloc[algos.index(algo), ages.index(age)]=r_value**2
            df_std_err.iloc[algos.index(algo), ages.index(age)]=std_err
    if out=='r2' :
        return(df_r_2)
    elif out=='std_err': 
        return(df_std_err)
    
def logistic_algo_CDI(path_ortho,path_res, sub, algos, unit,ages, CDI_file, NbInfant_file="CDI_NbInfantByAge",freq_file="/freq-words.txt"):
    df_r_2_clf=pd.DataFrame(0, columns=ages, index=algos)
    df_std_err=pd.DataFrame(0, columns=ages, index=algos)
    for age in ages:  
        for algo in algos:
            df_CDI=read.read_CDI_data_by_age(CDI_file, age, save_file=False)
            df_algo=analyze.freq_token_in_corpus(path_ortho)
            df_data=pd.merge(df_CDI, df_algo, on=['Type'], how='inner')
            if algo=='gold': 
                df_algo=analyze.freq_token_in_corpus(path_ortho)
            else : 
                df_algo=read.create_df_freq_by_algo_all_sub(path_res, sub, algo,unit, freq_file)
            df_data=pd.merge(df_CDI, df_algo, on=['Type'], how='inner')
            x=np.log(df_data['Freq'+algo])
            y=np.log(df_data['prop']/(np.repeat(1,len(df_data['prop']))-df_data['prop']))
            slope, intercept, r_value, p_value, std_err = stats.linregress(x,y)
            df_r_2_clf.iloc[algos.index(algo), ages.index(age)]=r_value**2
            df_std_err.iloc[algos.index(algo), ages.index(age)]=std_err       
    return(df_r_2_clf)


'''
    df.nb_i=pd.read_csv(NbInfant_file,sep=";")
    nb_infant_by_age=df.nb_i.loc[nb_i['age'] == age].values[0][1]
    vec=np.repeat(nb_infant_by_age, len(df_data)) 
    X=np.transpose(np.matrix(np.log(df_data['Freq'+algo]))) # LogisticRegression from scikit takes only a matrix as input
            #y=np.transpose(np.matrix(df_data['prop']))
            y=df_data['prop'].to_frame()
            y_binary=[]
            for row in y.itertuples():
                if row[1]> 0.5 :
                    y_binary.append(1)
                else :
                    y_binary.append(0)
            y_t=np.transpose(np.matrix(y_binary))
            
            dic_weight=dict(zip(df_data['prop'], np.repeat(1,len(df_data['prop']))-df_data['prop']))
            
            clf = LogisticRegression(fit_intercept = True, class_weight=dic_weight  , C = 1e9, max_iter=100, solver='liblinear') # SAG : stochastic average gradiant, useful for big dataset (INRIA) # C : higher it is, the less it penalize
            X_train, X_test, Y_train, Y_test = \
            train_test_split(X, y_t, test_size=Test_size, random_state=np.random.RandomState(42))
            clf.fit(X_train, Y_train, sample_weight=vec)
            y_pred=clf.predict_proba(X_test) # returns a dataframe of 2 colums : first P(X=0|X_test) and second, P(X=1|X_test)
            df_r_2_clf.iloc[algos.index(algo), ages.index(age)]=r2_score(Y_test, y_pred[:,1])        
'''