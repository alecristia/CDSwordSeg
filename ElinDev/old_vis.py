#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Mar 27 14:57:01 2017

@author: elinlarsen
"""

import os
import plotly 
#plotly must have downloaded  cf https://plot.ly/python/getting-started/
# open spyder from terminal !
import plotly.plotly as py
import plotly.graph_objs as go
import plotly.figure_factory as ff
import pandas as pd


# Scientific libraries
import numpy as np
from scipy import stats
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score

    
#test
algos=['TPs', 'DiBS', 'PUDDLE', 'AGu']
#plot_R2_algos_unit_for_one_age(R2_lin, std_err_lin, algos, 13, R2_gold=0.119 , unit=['syllable', 'phoneme'], name_vis="R2 scatter plot")


#  **** fscore 
#y_ph=[0.47,0.24,0.71,0.78]
#y_syl = [ 0.36, 0.60,0.81, 0.41 ]
#x = ['TPs','DiBs','PUDDLE', 'AGu']

y_TPs=[0.36,0.47]
y_DiBs=[0.60, 0.24]
y_p=[0.81, 0.71]
y_AGu=[0.41, 0.78]

x=['Syllable','Phoneme']

trace_TPs = go.Scatter(
            x=x,
            y=y_TPs,
            name='TPs',
            #text=y_syl,
        )
trace_DiBs=go.Scatter(
        x=x,
        y=y_DiBs, 
        name='DiBs',
        #text=y_ph
        )

trace_PUDDLE=go.Scatter(
        x=x, 
        y=y_p,
        name='PUDDLE', 
        )

trace_AGu=go.Scatter(
        x=x,
        y=y_AGu, 
        name='AGu')

data=[trace_TPs, trace_DiBs, trace_PUDDLE, trace_AGu ]


a1 = [dict(x=xi,y=yi,
         text=str(yi),
         xanchor='ceter',
         yanchor='top',
         showarrow=False,
    ) for xi, yi in zip(x, y_TPs)]

a2 = [dict(x=xi,y=yi,
         text=str(yi),
         xanchor='right',
         yanchor='bottom',
         showarrow=False,
    ) for xi, yi in zip(x, y_DiBs)]
    
a3=[dict(x=xi,y=yi,
         text=str(yi),
         xanchor='left',
         yanchor='bottom',
         showarrow=False,
    ) for xi, yi in zip(x, y_p)]

a4=[dict(x=xi,y=yi,
         text=str(yi),
         xanchor='left',
         yanchor='bottom',
         showarrow=False,
    ) for xi, yi in zip(x, y_AGu)]

layout = go.Layout(
        title='F-score', 
        xaxis= dict(
            title= 'Word segmentation algorithms ',
            ),
        yaxis=dict(
            domain=[0, 1],
            title= 'Token F-score ',
        ),
        annotations=a1+a2+a3+a4
        ) 

fig = go.Figure(data=data, layout=layout)
py.iplot(fig, filename='Token_F-score_Algos_Scatter')
    
# lexicon fscore 
y_TPs=[0.188,	0.166]
y_DiBs=[0.417,	0.057]
y_p=[0.315,	0.38]
y_AGu=[0.34,	0.517]

x=['Syllable','Phoneme']

trace_TPs = go.Bar(
            x=x,
            y=y_TPs,
            name='TPs',
            text=y_syl,
        )
trace_DiBs=go.Bar(
        x=x,
        y=y_DiBs, 
        name='DiBs',
        text=y_ph
        )

trace_PUDDLE=go.Bar(
        x=x, 
        y=y_p,
        name='PUDDLE', 
        )

trace_AGu=go.Bar(
        x=x,
        y=y_AGu, 
        name='AGu')

data=[trace_TPs, trace_DiBs, trace_PUDDLE, trace_AGu ]


a1 = [dict(x=xi,y=yi,
         text=str(yi),
         xanchor='ceter',
         yanchor='top',
         showarrow=False,
         font=dict(size=18),
    ) for xi, yi in zip(x, y_TPs)]

a2 = [dict(x=xi,y=yi,
         text=str(yi),
         xanchor='right',
         yanchor='bottom',
         showarrow=False,
         font=dict(size=18),
    ) for xi, yi in zip(x, y_DiBs)]
    
a3=[dict(x=xi,y=yi,
         text=str(yi),
         xanchor='left',
         yanchor='bottom',
         showarrow=False,
         font=dict(size=18),
    ) for xi, yi in zip(x, y_p)]

a4=[dict(x=xi,y=yi,
         text=str(yi),
         xanchor='left',
         yanchor='bottom',
         showarrow=False,
         font=dict(size=18),
    ) for xi, yi in zip(x, y_AGu)]

layout = go.Layout(
        title='Lexicon F-score',
        titlefont=dict(
            size=18,
        ),
        legend=dict(
            font=dict(size=18),
        ),
        xaxis= dict(
            title= 'Unit of input representation ',
            titlefont=dict(size=18),
            tickfont=dict(size=18),
            ),
        yaxis=dict(
            domain=[0, 1],
            title= 'Lexicon F-score ',
            titlefont=dict(size=18),
        ),
        annotations=a1+a2+a3+a4
        ) 

fig = go.Figure(data=data, layout=layout)
py.iplot(fig, filename='Lexicon F-score Algos')


# Fscore against R2
path='/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/Analysis_algos_CDI/13mois/'
token_f_score=pd.read_table(path+'token_fscore.txt', sep='\t', header=0, index_col=False)
lexicon_f_score=pd.read_table(path+'lexicon_f_score.txt', sep='\t', header=0,index_col=False)
boundary_f_score=pd.read_table(path+'boundary_fscore.txt', sep='\t', header=0, index_col=False)
R2=pd.read_table(path+'R2.txt', sep='\t', header=0, index_col=False)

results=pd.merge(token_f_score, lexicon_f_score, on =['algos', 'unit'], how='inner')
results=pd.merge(results, R2, on=['algos', 'unit'], how='inner')
results=pd.merge(results, boundary_f_score, on=['algos', 'unit'], how='inner')

trace_token = go.Scatter(
            x=results['R2'],
            y=results['token'] ,
            name='Token F-score',
            visible='legendonly',
            showlegend=True,
            mode = 'markers',
            text=results['algos'] + ' ' + results['unit'], 
            textposition='top', 
        )
trace_lexicon=go.Scatter(
            x=results['R2'] ,
            y=results['lexicon'],
            name='Lexicon F-score',
            visible='legendonly',
            showlegend=True,
            mode = 'markers',
            text=results['algos'] + ' ' + results['unit'], 
            textposition='top',
        )
trace_boundary=go.Scatter(
            x=results['R2'] ,
            y=results['boundary'],
            name='Boundary F-score',
            visible='legendonly',
            showlegend=True,
            mode = 'markers+text',
            text=results['algos'] + ' ' + results['unit'], 
            textposition='top',
        )
data=[trace_token, trace_lexicon, trace_boundary]

layout = go.Layout(
        title='Token, Lexicon and Boundary F-score against R2',
        titlefont=dict(
            size=18,
        ),
        legend=dict(
            font=dict(size=18),
        ),
        xaxis= dict(
            title= 'Coefficient of determination  ',
            titlefont=dict(size=18),
            tickfont=dict(size=14),
            ),
        yaxis=dict(
            domain=[0, 1],
            title= 'F-score ',
            titlefont=dict(size=18),
            tickfont=dict(size=14)
        ),
        ) 

fig = go.Figure(data=data, layout=layout)
py.iplot(fig, filename=' T-L-B F-scores against R2')

'''

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
#test 
path='/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/Analysis_algos_CDI/13mois/'
token_f_score=pd.read_table(path+'token_fscore.txt', sep='\t', header=0, index_col=False)
lexicon_f_score=pd.read_table(path+'lexicon_f_score.txt', sep='\t', header=0,index_col=False)
boundary_f_score=pd.read_table(path+'boundary_fscore.txt', sep='\t', header=0, index_col=False)
R2=pd.read_table(path+'R2.txt', sep='\t', header=0, index_col=False)

results=pd.merge(token_f_score, lexicon_f_score, on =['algos', 'unit'], how='inner')
results=pd.merge(results, R2, on=['algos', 'unit'], how='inner')
results=pd.merge(results, boundary_f_score, on=['algos', 'unit'], how='inner')

#plot_R2_fscore_for_one_age(results[['algos', 'R2', 'unit']], results[['algos', 'token', 'unit']], algos,13, R2_gold=0.118, unit=['Syllable', 'Phoneme'], name_vis="R2 -Token F-score", which_fscore='token')
    
'''



