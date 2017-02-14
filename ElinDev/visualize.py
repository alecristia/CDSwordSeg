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

def plot_algos_CDI_by_age(path_ortho,path_res, sub=["full_corpus"], algos=["dibs", "TPs", "puddle", "AGu"], ages=8, CDI_file="PropUnderstandCDI.csv",freq_file="/freq-words.txt", name_vis="plot"):
    data=[]
    for age in ages: 
        for algo in algos:
            df_CDI=read.read_CDI_data_by_age(CDI_file, age, save_file=False)
            if algo=='gold': 
                df_algo=analyze.freq_token_in_corpus(path_ortho)
            else : 
                df_algo=read.create_df_freq_by_algo_all_sub(path_res, sub, algo, freq_file)
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
    
def plot_by_lexical_classes(path_res, sub, algos, ages, lexical_classes, save_file=False, CDI_file="PropUnderstandCDI.csv", freq_file="/freq-words.txt", name_vis="plot"):  
    data=[]
    for age in ages: 
        for algo in algos:
            df_CDI=read.read_CDI_data_by_age(CDI_file, age, save_file=True)
            df_algo=read.create_df_freq_by_algo_all_sub(path_res, sub, algo, freq_file)
            df_data=pd.merge(df_CDI, df_algo, on=['Type'], how='inner')
            print(df_data)
            for lc in lexical_classes:
                gb_lc=df_data.groupby('lexical_classes').get_group(lc)
                x=np.log(gb_lc['Freq'+algo])
                #print(gb_lc['Type'])
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

'''            
            
### old script 
# GOLD   
'''
        df_gold=analyze.freq_token_in_corpus(path_ortho)
        df_data_g=pd.merge(df_CDI, df_gold, on=['Type'], how='inner')
        x=np.log(df_data_g['Freq'])
        y=df_data_g['prop']
        slope, intercept, r_value, p_value, std_err = stats.linregress(x,y)
        line=slope*x+intercept
        df_r_2.iloc[(algos+['gold']).index('gold'), ages.index(age)]=r_value**2
        name_gold= 'gold' + ' age ' + str(age)
        trace_g=go.Scatter(
            x=x,
            y=y,
            mode='markers+text',
            name=name_gold ,
            text=df_data_g['Type'],
            textposition='top', 
            visible='legendonly', 
            #legendgroup=name_gold,
            showlegend=True,
            )
        trace_fit_g=go.Scatter(
            x=x,
            y=line,
            mode='markers',
            name=name_gold +' fit',
            text=df_data_g['Type'],
            textposition='top', 
            visible='legendonly', 
            #legendgroup=name_gold,
            showlegend=True,
            )
        trace_hist_g=go.Histogram(
            x=x,
            opacity=0.75,
            name=name_gold + ' histogram',
            visible='legendonly',
            xaxis= "x2",
            yaxis='y2',
            #legendgroup=name_gold,
            showlegend=True,
     
            )
        data.append(trace_g)
        data.append(trace_fit_g)
        data.append(trace_hist_g)
'''
