# -*- coding: utf-8 -*-
"""
Created on Thu Dec 15 17:14:22 2016

@author: elinlarsen
"""
import os
import plotly.plotly as py
import plotly.graph_objs as go
import pandas as pd
from pandas import DataFrame
from pandas import concat
from pandas.util.testing import rands
from plotly.offline import download_plotlyjs, init_notebook_mode, plot, iplot
import lxml.html
from lxml.html import builder as E

# Scientific libraries
import numpy as np
from numpy import arange,array,ones
from scipy import stats

#import file
import read
import analyze

def plot_algos_CDI_fit_by_age(path_ortho,path_res, sub, algos, ages, CDI_file, save_file=False, average_algos=False,freq_file="/freq-words.txt"):
    data=[]
    df_r_2=pd.DataFrame(0, columns=ages, index=ALGOS+['gold'])
    for age in ages: 
        for algo in algos:
            df_CDI=read_CDI_data_by_age(CDI_file, age, save_file=True)
            df_algo=create_df_freq_all_algo_all_sub(path_res, sub, algo, average_algos, freq_file)
            df_data=pd.merge(df_CDI, df_algo, on=['Type'], how='inner')
            x=np.log(df_data['Freq'+algo])
            y=df_data['prop']
            slope, intercept, r_value, p_value, std_err = stats.linregress(x,y)
            line=slope*x+intercept
            df_r_2.iloc[algos.index(algo), ages.index(age)]=r_value**2
            name='algo ' + algo+ ' age ' + str(age) 
            trace=go.Scatter(
                x=x,
                y=y,
                mode='markers+text',
                name=name,
                text=df_data['Type'],
                textposition='top', 
                visible='legendonly',
                legendgroup=name
                )
            trace_fit=go.Scatter(
                x=x,
                y=line,
                mode='markers',
                name=name +' fit',
                text=df_data['Type'],
                textposition='top',
                visible='legendonly',
                legendgroup=name,
                showlegend=False,
                )
            trace_hist = go.Histogram(
                x=x,
                opacity=0.75,
                name=name + ' histogram',
                visible='legendonly',
                #legendgroup=name,
                xaxis= "x2",
                yaxis='y2',
                #showlegend=False,
                )
            '''data.append(trace)'''
            data.append(trace_fit)
            data.append(trace_hist)
            #data.append(df_data['lexical_classes'])
        df_gold=freq_token_in_corpus(path_ortho)
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
            legendgroup=name_gold)
        trace_fit_g=go.Scatter(
            x=x,
            y=line,
            mode='markers',
            name=name_gold +' fit',
            text=df_data_g['Type'],
            textposition='top', 
            visible='legendonly', 
            legendgroup=name_gold,
            showlegend=False,
            )
        trace_hist_g = go.Histogram(
                x=x,
                opacity=0.75,
                name=name_gold + ' histogram',
                visible='legendonly',
                #legendgroup=name,
                xaxis= "x2",
                yaxis='y2',
                #showlegend=False,
                )
        data.append(trace_g)
        data.append(trace_fit_g)
        data.append(trace_hist_g)
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
        domain=[0.35, 1],
        title= 'Score of CDI : porportion of babies understanding each word at age '+str(age)+' in Brent corpus',
        #type='log',
        ticklen= 5,
        gridwidth= 2,
        ),
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
    )   
    fig=go.Figure(data=data, layout=layout)
    plot=py.iplot(fig, filename='CDIScore_AlgoScore')
    return(df_r_2)
    
def plot_by_lexical_classes(path_res, sub, algos, ages, CDI_file, lexical_classes, save_file=False, average_algos=False,freq_file="/freq-words.txt"):  
    data=[]
    df_r_2=pd.DataFrame(0, columns=ages, index=algos+['gold'])
    for age in ages: 
        for algo in algos:
            df_CDI=read_CDI_data_by_age(CDI_file, age, save_file=True)
            df_algo=create_df_freq_all_algo_all_sub(path_res, sub, algo, average_algos, freq_file)
            df_data=pd.merge(df_CDI, df_algo, on=['Type'], how='inner')
            df_data_gr=df_data.groupe_by('lexical_classes').get_group(lexical_classes)
            x=np.log(df_data_gr['Freq'+algo])
            y=df_data_gr['prop']
            trace=go.Scatter(
                x=x,
                y=y,
                mode='markers+text',
                name='algo ' + algo+ ' age ' + str(age) ,
                text=df_data['Type'],
                textposition='top', 
                visible='legendonly')
            data.append(trace)
            
    