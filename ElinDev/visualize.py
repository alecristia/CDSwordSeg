# -*- coding: utf-8 -*-
"""
Created on Thu Dec 15 17:14:22 2016

@author: elinlarsen
"""

import plotly 
#plotly must have downloaded  cf https://plot.ly/python/getting-started/
# open spyder from terminal !
import plotly.plotly as py
import plotly.graph_objs as go
import pandas as pd


# Scientific libraries
import numpy as np
from scipy import stats
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score

#import file
import read
import analyze
import model

def plot_algos_CDI_by_age(path_ortho,path_res, sub=["full_corpus"], algos=["dibs", "TPs", "puddle", "AGu"], unit="syllable",ages=8, CDI_file="PropUnderstandCDI.csv",freq_file="/freq-words.txt", name_vis="plot"):
    data=[]
    for age in ages: 
        for algo in algos:
            df_CDI=read.read_CDI_data_by_age(CDI_file, age, save_file=False)
            if algo=='gold': 
                df_algo=analyze.freq_token_in_corpus(path_ortho)
            else : 
                df_algo=read.create_df_freq_by_algo_all_sub(path_res, sub, algo, unit,freq_file)
            df_data=pd.merge(df_CDI, df_algo, on=['Type'], how='inner')
            x=np.log(df_data['Freq'+algo])
            y=df_data['prop']
            name=algo+ ' age ' + str(age) 
            trace=go.Scatter(
                x=x,
                y=y,
                mode='markers+text',
                name=name,
                text=df_data['Type'],
                textposition='top', 
                visible='legendonly',
                showlegend=True,
                #legendgroup=name,
                )
            data.append(trace)
    layout= go.Layout(
    title= 'Proportion of children understanding words at different ages against score of '+ ', '.join(algos) ,
    hovermode= 'closest',
    xaxis= dict(
        title= 'log(Score of algos)',
        #type='log',
        ticklen= 5,
        zeroline= False,
        gridwidth= 2,),
    yaxis=dict(
        domain=[0, 1],
        title= 'Score of CDI : porportion of babies understanding each word at age '+str(age)+' in Brent corpus',
        #type='log',
        ticklen= 5,
        gridwidth= 2,))   
    fig=go.Figure(data=data, layout=layout)
    plot=py.iplot(fig, filename=name_vis)
    
def plot_by_lexical_classes(path_res, sub, algos,unit, ages, lexical_classes, save_file=False, CDI_file="PropUnderstandCDI.csv", freq_file="/freq-words.txt", name_vis="plot"):  
    data=[]
    for age in ages: 
        for algo in algos:
            df_CDI=read.read_CDI_data_by_age(CDI_file, age, save_file)
            df_algo=read.create_df_freq_by_algo_all_sub(path_res, sub, algo,unit, freq_file)
            df_data=pd.merge(df_CDI, df_algo, on=['Type'], how='inner')
            print(df_data)
            for lc in lexical_classes:
                gb_lc=df_data.groupby('lexical_classes').get_group(lc)
                x=np.log(gb_lc['Freq'+algo])
                y=gb_lc['prop']
                trace=go.Scatter(
                    x=x,
                    y=y,
                    mode='markers+text',
                name='algo ' + algo+ ' age ' + str(age) +' '+ lc ,
                text=gb_lc['Type'],
                textposition='top', 
                visible='legendonly',
                showlegend=True,)
                data.append(trace)
    layout= go.Layout(
    title= 'Proportion of children understanding words at different ages against score of '+ ', '.join(algos) ,
    hovermode= 'closest',
    xaxis= dict(
        title= 'log(Score of algos)',
        #type='log',
        ticklen= 5,
        zeroline= False,
        gridwidth= 2,),
    yaxis=dict(
        domain=[0, 1],
        title= 'Score of CDI : porportion of babies understanding each word at age '+str(age)+' in Brent corpus',
        #type='log',
        ticklen= 5,
        gridwidth= 2,))   
    fig=go.Figure(data=data, layout=layout)
    plot=py.iplot(fig, filename=name_vis)
    
    

def plot_algo_gold_lc(path_res, sub, algos,unit, gold, out='r2', CDI_file="PropUnderstandCDI.csv", lexical_classes=['nouns','function_words', 'adjectives', 'verbs'],freq_file="/freq-words.txt", name_vis="plot"):  
    data=[]
    df_r_2=pd.DataFrame(0, columns=lexical_classes, index=algos)
    df_std_err=pd.DataFrame(0, columns=lexical_classes, index=algos)
    df_gold=read.create_df_freq_by_algo_all_sub(path_res, sub, gold, freq_file) 
    df_gold=df_gold.loc[lambda d_gold: d_gold.Freqgold > 1, :] # get rid of low frequency type : good probability for mistake : @wp
    print(df_gold)
        
    for algo in algos:
        df_CDI=read.read_CDI_data_by_age(CDI_file, age=8, save_file=False) #age does not matte here
        df_algo=read.create_df_freq_by_algo_all_sub(path_res, sub, algo,unit, freq_file)
        df=pd.merge(df_gold, df_algo, on=['Type'], how='inner')
        df_data=pd.merge(df_CDI, df, on=['Type'], how='inner')
        df_data=df_data[['lexical_classes','Type','Freqgold', 'Freq'+algo]]
        for lc in lexical_classes:
            gb_lc=df_data.groupby('lexical_classes').get_group(lc)
            #x=np.log(gb_lc['Freqgold'])
            #y=np.log(gb_lc['Freq'+algo])
            x=gb_lc['Freqgold']
            y=gb_lc['Freq'+algo]
            trace=go.Scatter(
                x=x,
                y=y,
                mode='markers+text',
            name='algo ' + algo+ ' '+ lc ,
            text=gb_lc['Type'],
            textposition='top', 
            visible='legendonly',
            showlegend=True,)
            data.append(trace)
            slope, intercept, r_value, p_value, std_err = stats.linregress(x,y)
            df_r_2.iloc[algos.index(algo), lexical_classes.index(lc)]=r_value**2
            df_std_err.iloc[algos.index(algo), lexical_classes.index(lc)]=std_err
    layout= go.Layout(
    title= 'Number of True Positives (TP) for different word segmentation algorithm over TP+TN (gold) in normal scale',
    hovermode= 'closest',
    xaxis= dict(
        title= 'Occurence of words in gold',
        type='log',
        ticklen= 5,
        zeroline= False,
        gridwidth= 2,),
    yaxis=dict(
        domain=[0, 1],
        title= 'Occurence of words in algos',
        type='log',
        ticklen= 5,
        gridwidth= 2,))   
    fig=go.Figure(data=data, layout=layout)
    plot=py.iplot(fig, filename=name_vis)
    
    if out=='r2' :
        return(df_r_2)
    elif out=='std_err': 
        return(df_std_err)
 
    
def plot_bar_R2_algos_unit_by_age(df_R2, df_std_err, ages,algos, name_vis): 
    data=[]
    x=ages
    for algo in algos: 
        y=df_R2.loc[algo]
        err_y=np.array(df_std_err.loc[algo])
        trace=go.Bar(
                    x=x,
                    y=y,
                    error_y=dict(
                        type='data',
                        array=np.array(err_y),
                        visible=True 
                            ),
                name='algo ' + algo,
                visible='legendonly',
                showlegend=True,)
        data.append(trace)
    layout= go.Layout(
    title= name_vis ,
    hovermode= 'closest',
    xaxis= dict(
        title= 'Children ages',
        #type='log',
        ticklen= 5,
        zeroline= False,
        gridwidth= 2,),
    yaxis=dict(
        domain=[0, 1],
        title= 'R2',
        #type='log',
        ticklen= 5,
        gridwidth= 2,))   
    fig=go.Figure(data=data, layout=layout)
    plot=py.iplot(fig, filename=name_vis)
    
    
def plot_bar_f_score_algos(df_fscore, algos, unit=['syllable', 'phoneme'], name_vis='Fscore visualiation'):
    data=[]
    x=ages
    for u in unit : 
        for algo in algos: 
            y=df_fscore.loc[algo]
            trace=go.Bar(
                        x=x,
                        y=y,
                    name='algo ' + algo + 'with unit represation as' + unit,
                    visible='legendonly',
                    showlegend=True,)
            data.append(trace)
    layout= go.Layout(
    title= name_vis ,
    hovermode= 'closest',
    xaxis= dict(
        title= 'Word segmentation algorithm',
        #type='log',
        ticklen= 5,
        zeroline= False,
        gridwidth= 2,),
    yaxis=dict(
        domain=[0, 1],
        title= 'Token F-score',
        #type='log',
        ticklen= 5,
        gridwidth= 2,))   
    fig=go.Figure(data=data, layout=layout)
    plot=py.iplot(fig, filename=name_vis)
    
           

    '''
    
def plot_linear_algo_CDI(path_ortho,path_res, sub, algos, ages, CDI_file,freq_file="/freq-words.txt", name_vis="plot_lin"):
    data=[]
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
                df_algo=read.create_df_freq_all_algo_all_sub(path_res, sub, algo, freq_file)
            df_data=pd.merge(df_CDI, df_algo, on=['Type'], how='inner')
            x=np.log(df_data['Freq'+algo])
            y=df_data['prop']
            slope, intercept, r_value, p_value, std_err = stats.linregress(x,y)
            line=slope*x+intercept
            df_r_2.iloc[algos.index(algo), ages.index(age)]=r_value**2
            #df_std_err.iloc=[algos.index(algo), ages.index(age)]=std_err
            name=algo+ ' age ' + str(age) 
            trace_fit=go.Scatter(
                x=x,
                y=line,
                mode='markers',
                name=name +' fit',
                text=df_data['Type'],
                textposition='top',
                visible='legendonly',
                #legendgroup=name,
                showlegend=True,
                )
            data.append(trace_fit)
    layout= go.Layout(
    title= 'Linear Regression : Proportion of children understanding words at different ages against score of '+ ', '.join(algos) ,
    hovermode= 'closest',
    xaxis= dict(
        title= 'log(Score of algos)',
        #type='log',
        ticklen= 5,
        zeroline= False,
        gridwidth= 2,),
    yaxis=dict(
        domain=[0.35, 1],
        title= 'Score of CDI : porportion of babies understanding each word at age '+str(age)+' in Brent corpus',
        #type='log',
        ticklen= 5,
        gridwidth= 2,))   
    fig=go.Figure(data=data, layout=layout)
    plot=py.iplot(fig, filename=name_vis)
    return([df_r_2,df_std_err])
    
def plot_logistic_algo_CDI(path_ortho,path_res, sub, algos, ages, CDI_file,freq_file="/freq-words.txt", name_vis="plot_log", Test_size=0.50):
    data=[]
    df_r_2_clf=pd.DataFrame(0, columns=ages, index=algos)
    for age in ages: 
        for algo in algos:
            df_CDI=read.read_CDI_data_by_age(CDI_file, age, save_file=False)
            df_algo=analyze.freq_token_in_corpus(path_ortho)
            df_data=pd.merge(df_CDI, df_algo, on=['Type'], how='inner')
            if algo=='gold': 
                df_algo=analyze.freq_token_in_corpus(path_ortho)
            else : 
                df_algo=read.create_df_freq_all_algo_all_sub(path_res, sub, algo, freq_file)
            df_data=pd.merge(df_CDI, df_algo, on=['Type'], how='inner')
            #x=np.log(df_data['Freq'+algo])
            X=np.transpose(np.matrix(np.log(df_data['Freq'+algo]))) # LogisticRegression from scikit takes only a matrix as input
            y=pd.DataFrame(df_data['prop'])
            y_binary=[]
            for row in y.itertuples():
                if row[1]> 0.5 :
                    y_binary.append(1)
                else :
                    y_binary.append(0)
            y_t=np.transpose(np.matrix(y_binary))
            clf = LogisticRegression(fit_intercept = True, C = 1e9, max_iter=100, solver='sag', tol=1e-1) 
            # SAG : stochastic average gradiant, useful for big dataset (INRIA) # C : higher it is, the less it penalize
            X_train, X_test, Y_train, Y_test = \
            train_test_split(X, y_t, test_size=Test_size, random_state=np.random.RandomState(42))
            clf.fit(X_train, Y_train)
            y_pred=clf.predict_proba(X_test) # returns a dataframe of 2 colums : first P(X=0|X_test) and second, P(X=1|X_test)
            #mean_acc=clf.score(X_test,Y_test)
            df_r_2_clf.iloc[algos.index(algo), ages.index(age)]=r2_score(Y_test, y_pred[:,1])
            name=algo+ ' age ' + str(age) 
            trace_fit=go.Scatter(
                x=X,
                y=y_pred[:,1], # proba X=1 -> prediction whether the infant knows the word or not
                mode='markers',
                name=name +' fit',
                text=df_data['Type'],
                textposition='top',
                visible='legendonly',
                showlegend=True,
                )
            data.append(trace_fit)
    layout= go.Layout(
    title= 'Logistic Regression : Proportion of children understanding words at different ages against score of '+ ', '.join(algos) ,
    hovermode= 'closest',
    xaxis= dict(
        title= 'log(Score of algos)',
        #type='log',
        ticklen= 5,
        zeroline= False,
        gridwidth= 2,),
    yaxis=dict(
        domain=[0.35, 1],
        title= 'Score of CDI : porportion of babies understanding each word at age '+str(age)+' in Brent corpus',
        #type='log',
        ticklen= 5,
        gridwidth= 2,
        )
    )   
    fig=go.Figure(data=data, layout=layout)
    plot=py.iplot(fig, filename=name_vis)
    return(df_r_2_clf)
    
    
 
'''

'''
    trace_hist=go.Histogram(
        x=x,
        opacity=0.75,
        name=name + ' histogram',
        visible='legendonly',
        #legendgroup=name,
        xaxis= "x2",
        yaxis='y2',
        showlegend=True,
        )
    data.append(trace_hist)
    
    
    dans le layout
    ,
    xaxis2= dict(
        title= 'log(Score of algos)',
        #type='log',
        ticklen= 5,
        zeroline= False,
        gridwidth= 2,
        anchor='y2'
        ),
     yaxis2=dict(
        domain=[0, 0.25],
        title=" Number of words",
        side="left",
        #overlaying="y",
        )
'''
    
# A FINIR
'''


