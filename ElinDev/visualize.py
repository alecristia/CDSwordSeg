# -*- coding: utf-8 -*-
"""
Created on Thu Dec 15 17:14:22 2016

@author: elinlarsen
"""
import os
import plotly 
#plotly must have downloaded  cf https://plot.ly/python/getting-started/
# open spyder from terminal !
import plotly.plotly as py
import plotly.graph_objs as go
import pandas as pd

init_notebook_mode(connected=False)

# Scientific libraries
import numpy as np
from scipy import stats
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score

#import file
os.chdir('/Users/elinlarsen/Documents/CDSwordSeg/ElinDev')
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
            slope, intercept, r_value, p_value, std_err = stats.linregress(x,y)
            y_fit=  intercept + slope*x
            trace_fit=go.Scatter(
                x=x,
                y=y_fit,
                mode='line',
                name='Fit' +name,
                text=df_data['Type'],
                textposition='top', 
                visible='legendonly',
                showlegend=True,
                #legendgroup=name,
                )
            data.append(trace)
            data.append(trace_fit)
    annotation = go.Annotation(
          text='R^2 =' + str(round(r_value**2,2)) +' \\ Y =' + str(round(slope,2)) +'*X + ' + str(round(intercept,2)),
          showarrow=False,
          font=go.Font(size=16)
          )
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
        gridwidth= 2,),
    annotations=[annotation]
    )   
    fig=go.Figure(data=data, layout=layout)
    plot=py.iplot(fig, filename=name_vis)
    
def plot_by_lexical_classes(path_res, sub, algos,unit, ages, lexical_classes, save_file=False, CDI_file="PropUnderstandCDI.csv", freq_file="/freq-words.txt", name_vis="plot", out="r2"):  
    data=[]
    R2=pd.DataFrame(0, columns=lexical_classes, index=algos)
    Err=pd.DataFrame(0, columns=lexical_classes, index=algos)
    for age in ages: 
        for algo in algos:
            df_CDI=read.read_CDI_data_by_age(CDI_file, age, save_file)
            df_algo=read.create_df_freq_by_algo_all_sub(path_res, sub, algo,unit, freq_file)
            df_data=pd.merge(df_CDI, df_algo, on=['Type'], how='inner')
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
                    showlegend=True,
                )
                data.append(trace)
                slope, intercept, r_value, p_value, std_err = stats.linregress(x,y)             
                y_fit=  intercept + slope*x
                trace_fit=go.Scatter(
                    x=x,
                    y=y_fit,
                    mode='line',
                    name='Fit algo ' + algo+ ' age ' + str(age) + ' '+ lc,
                    text=df_data['Type'],
                    textposition='top', 
                    visible='legendonly',
                    showlegend=True,
                    #legendgroup=name,
                )
                data.append(trace_fit)
                R2.iloc[algos.index(algo),lexical_classes.index(lc)]=r_value**2
                Err.iloc[algos.index(algo), lexical_classes.index(lc)]=std_err
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
    if out=='r2' :
        return(R2)
    elif out=='std_err': 
        return(Err)
    
    

def plot_algo_gold_lc(path_res, sub, algos, gold, unit, out='r2', CDI_file="PropUnderstandCDI.csv", lexical_classes=['nouns','function_words', 'adjectives', 'verbs'],freq_file="/freq-words.txt", name_vis="plot"):  
    data=[]
    df_r_2=pd.DataFrame(0, columns=lexical_classes, index=algos)
    df_std_err=pd.DataFrame(0, columns=lexical_classes, index=algos)
    df_gold=read.create_df_freq_by_algo_all_sub(path_res, sub, gold,unit, freq_file) 
    df_gold=df_gold.loc[lambda d_gold: d_gold.Freqgold > 1, :] # get rid of low frequency type : good probability for mistake : @wp

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
                showlegend=True,
                )
            data.append(trace)
            slope, intercept, r_value, p_value, std_err = stats.linregress(x,y)             
            y_fit=  intercept + slope*x
            trace_fit=go.Scatter(
                x=x,
                y=y_fit,
                mode='line',
                name='Fit algo ' + algo+ ' '+ lc,
                text=df_data['Type'],
                textposition='top', 
                visible='legendonly',
                showlegend=True,
                #legendgroup=name,
                )
            data.append(trace_fit)
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
 
    
def plot_bar_R2_algos_unit_by_age(df_R2, df_std_err, ages, algos, unit=['syllable', 'phoneme'], name_vis="R2"): 
    data=[]
    if isinstance(ages, list):
        x=ages
        for u in unit :
            gr_R2=df_R2.groupby('unit').get_group(u)
            gr_std_err=df_std_err.groupby('unit').get_group(u)
            for algo in algos: 
                y=gr_R2.loc[algo]
                err_y=np.array(gr_std_err.loc[algo])
                trace=go.Scatter(
                            x=x,
                            y=y,
                            error_y=dict(
                                type='data',
                                array=np.array(err_y),
                                visible=True 
                                    ),
                        name= algo + ' ' + u,
                        visible='legendonly',
                        showlegend=True,)
                data.append(trace)       
        layout= go.Layout(
            title= name_vis ,
            hovermode= 'closest',
            xaxis= dict(
                title= 'Children ages (months) ',
                ticklen= 5,
                zeroline= False,
                gridwidth= 2,),
            yaxis=dict(
                domain=[0, 1],
                title= 'R2',
                ticklen= 5,
                gridwidth= 2,))    
    else : 
        df_R2['algos']=df_R2.index
        df_std_err['algos']=df_std_err.index            
        a=[] 
        for algo in algos: 
            g=df_R2.groupby('algos').get_group(algo)[[ages]].values.tolist()
            gr_std_err=df_std_err.groupby('algos').get_group(algo)[[ages]].values.tolist()
            
            trace=go.Bar(
                x=unit,
                y=g, 
                error_y=dict(
                    type='data',
                    array=np.array(gr_std_err),
                    visible=True),
                name= algo,
                )
                
            a_a = [dict(x=xi,y=yi,
             text=str(yi),
             xanchor='ceter',
             yanchor='top',
             showarrow=False,
             ) for xi, yi in zip(unit, g)]
            data.append(trace)  
            a=a+a_a
            
        layout= go.Layout(
            title= name_vis ,
              barmode='group',
            xaxis= dict(
                title= 'Unit of sound representation ',
                        ),
            yaxis=dict(
                domain=[0, 1],
                title= 'Coefficient of determination ',
                    ),
            annotations=a
            ) 
    fig=go.Figure(data=data, layout=layout)
    plot=py.iplot(fig, filename=name_vis)
    

def plot_R2_algos_unit_for_one_age(df_R2, df_std_err, algos,age, R2_gold, unit=['syllable', 'phoneme'], name_vis="R2"): 
    data=[]
    R2=df_R2[[age,'unit']]
    std_err=df_std_err[[age,'unit']]
    for u in unit :
        x=algos
        y=R2.groupby('unit').get_group(u)[age]
        err_y=np.array(std_err.groupby('unit').get_group(u)[age])
        trace=go.Scatter(
                x=x,
                y=y,
                error_y=dict(
                    type='data',
                    array=np.array(err_y),
                    visible=True 
                        ),
                name= u,
                mode="markers",
                visible='legendonly',
                showlegend=True,
                )
    
        data.append(trace) 
    trace_gold=go.Scatter(
            x = x,
            y= np.repeat(R2_gold, len(x)),
            mode = "lines",
            name= 'Gold',
            )
    data.append(trace_gold)
    layout= go.Layout(
        title= name_vis ,
        hovermode= 'closest',
        titlefont=dict(size=18, ),
        legend=dict(font=dict(size=18)),
        xaxis= dict(
            title= 'Word segmentation algorithms',
            ticklen= 5,
            zeroline= False,
            gridwidth= 2,
            titlefont=dict(size=18),
            tickfont=dict(size=14)
            ),
        yaxis=dict(
            title= 'R2',
            ticklen= 5,
            gridwidth= 2,
            titlefont=dict(size=18),
            tickfont=dict(size=14),
            )
        )    
    fig=go.Figure(data=data, layout=layout)
    plot=py.iplot(fig, filename=name_vis)
    

def plot_R2_fscore_for_one_age(R2, std_err, fscore, algos,age, R2_gold, unit=['Syllable', 'Phoneme'], name_vis="R2", which_fscore='token'): 
    data=[]
    for u in unit :
        a=fscore.groupby('unit').get_group(u)['algos']
        x=fscore.groupby('unit').get_group(u)[which_fscore]
        y=R2.groupby('unit').get_group(u)['R2']
        err=std_err.groupby('unit').get_group(u)['std_err'].values
        trace=go.Scatter(
                x=x,
                y=y,
                error_x=dict(
                    type='data',
                    array=err,
                    visible=True),
                name= u,
                visible='legendonly',
                showlegend=True,
                mode='markers+text',
                text=a,
                textposition='top',
                textfont=dict(size=20),
                marker=dict(
                    symbol='circle', 
                    size=10,)
                )
        data.append(trace) 
    trace_gold=go.Scatter(
        x = 1,
        y= R2_gold,
        mode = 'markers+text',
        name= 'Gold',
        text='Gold',
        textfont=dict(size=20),
        textposition='top',
        marker=dict(
                symbol='diamond', 
                size=10,
                color='grey')
            )
    data.append(trace_gold)
    layout= go.Layout(
        titlefont=dict(size=18, ),
        legend=dict(font=dict(size=18)),
        xaxis= dict(
            title= which_fscore + ' F-score',
            zeroline= True,
            titlefont=dict(size=20),
            tickfont=dict(size=18)
            ),
        yaxis=dict(
            title= 'Coefficient of determination',
            domain=[0, 1],
            zeroline= True,
            titlefont=dict(size=20),
            tickfont=dict(size=18),
            )
        )    
    fig=go.Figure(data=data, layout=layout)
    plot=py.iplot(fig, filename=name_vis)
    
    
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
py.iplot(fig, filename='Token F-score Algos')
    
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



