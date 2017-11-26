#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Mar 27 16:18:39 2017

@author: elinlarsen
"""

import statsmodels.api as sm
import statsmodels.formula.api as smf
from statsmodels.formula.api import ols
import pandas as pd

def anova_cdi(response, *parameters):
    dfs=list(parameters)
    data= reduce(lambda left,right: pd.merge(left,right,on='Type'), dfs)

    list_predictors=data.columns.tolist()
    list_predictors.remove(response)
    list_predictors.remove('Type')
    predictors=data[list_predictors]
    print predictors
    print predictors.describe()
    
    y=data[[response]]
    print y
    print y.describe()
    
    lm = ols(formula="y ~ predictors", data=data).fit()
    table = sm.stats.anova_lm(lm, typ=2) # Type 2 ANOVA DataFrame
    return(table)

anova_cdi('lexical_classes', cat_concreteness, cat_babiness, length_type[['Type', 'num_syllables']], length_type[['Type', 'num_phonemes']], df_CDI_lexical_classes)


anova_cdi('prop', cat_concreteness,  df_CDI_lexical_classes, prop[['Type', 'prop']])
