#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Mar 27 15:39:37 2017

@author: elinlarsen
"""
import pandas as pd

import plotly.plotly as py
from plotly.graph_objs import *
import plotly.tools as tls
import plotly.figure_factory as ff

from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA as sklearnPCA


def plot_pca_cdi(name_vis, *parameters):
    dfs=list(parameters)
    X= reduce(lambda left,right: pd.merge(left,right,on='Type'), dfs)
    #standardize parameters to get them on the same scale
    X_std = StandardScaler().fit_transform(X)
    sklearn_pca = sklearnPCA(n_components=2)
    Y_sklearn = sklearn_pca.fit_transform(X_std)

    for name in dfs:
        trace = Scatter(
            x=Y_sklearn[y==name,0],
            y=Y_sklearn[y==name,1],
            mode='markers',
            name=name,
            marker=Marker(
                size=12,
                line=Line(
                    color='rgba(217, 217, 217, 0.14)',
                    width=0.5),
                opacity=0.8))
        traces.append(trace)


    data = Data(traces)
    layout = Layout(xaxis=XAxis(title='PC1', showline=False),
                yaxis=YAxis(title='PC2', showline=False))
    fig = Figure(data=data, layout=layout)
    py.iplot(fig, filename=name_vis)