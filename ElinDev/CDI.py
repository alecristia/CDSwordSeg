#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 15 16:51:04 2017

@author: elinlarsen
"""

#import libraries
import os
import pandas as pd

os.chdir('/Users/elinlarsen/Documents/CDSwordSeg/ElinDev')
import read
import visualize

# enter your current directory
os.chdir('/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/Analysis_algos_CDI/CDI_data')

# Proportion of infants understanding a word at different ages (8--18)
prop_understand=pd.read_csv("PropUnderstandCDI.csv", sep='\t', header=0)
P_8=pd.read_csv("Prop_understand_CDI_at_age_8.csv", sep='\t', header=0)

#Proportion of infants producing a word at different ages (16--30)
prop_produce=pd.read_csv("English_prop_produce.csv", sep=',', header=0)
prop_produce=prop_produce[['age','lexical_class', 'uni_lemma', 'prop']]
prop_produce.columns=['age','lexical_class', 'Type', 'prop']
#if file does not exist
prop_produce.to_csv('PropProduceCDI.csv',  sep='\t', index=False)

#clean regular expression : to be done once and to be saved
#prop_understand['words']=prop_understand['words'].str.replace('*', '') #take out regular expression
# if file does not exist
#prop_understand.to_csv("PropUnderstandCDI.csv", sep='\t', index=False)

df_CDI_13=read.read_CDI_data_by_age(CDI_file='CDI_data/PropUnderstandCDI.txt', age=13, save_file=False)

prop=pd.read_table("CDI_data/PropUnderstandCDI.txt", sep='\t', header=0)

# *******   lexical classes *******  

df_CDI_lexical_classes=df_CDI_13[['Type','lexical_classes']]
df_CDI_lexical_classes.to_csv("CDI_lexical_classes.txt",sep='\t', index=False )
gb_lc=df_CDI_lexical_classes.groupby('lexical_classes')
nouns=gb_lc.get_group("nouns")
lexical_classes=gb_lc.groups
list_lexical_classes=lexical_classes.keys()
df_gb_lc=gb_lc.get_group('nouns')


# type length in number of syllables in CDI, these data come from wordbank database, 
length_type=pd.read_csv("CDI_data/Length_type_ph_syl.txt", sep='\t', header=0)
group_syllable_length=length_type.groupby('num_syllables', sort=True, group_keys=True).groups.keys()
group_phoneme_length=length_type.groupby('num_phonemes', sort=True, group_keys=True).groups.keys()

# concreteness
concreteness_all=pd.read_csv("concreteness/concreteness.csv", sep=",", header=0)
concreteness_all.rename(columns={'Word': 'Type'}, inplace=True)
concreteness=concreteness_all[['Type', 'Conc.M']]

#concreteness data are continuous [0,4], for a first analysis, we will look onlyat the effect of a categorical variable 
# so we can round to 0 number
cat_concreteness=concreteness.round({'Conc.M': 0} )

# babiness
babiness_all=pd.read_csv("babiness_iconicity/english_iconicity.csv", sep=",", header=0)
babiness=babiness_all[['word', 'babyAVG']]
babiness.rename(columns={'word': 'Type'}, inplace=True)
babiness.drop_duplicates(keep='first', inplace=True)
cat_babiness=babiness.round({'babyAVG':0})

visualize.correlation_btw_parameters('test-mat-corr', cat_concreteness, cat_babiness, length_type[['Type', 'num_syllables']])

pca_cdi_parameters.plot_pca_cdi('test-pca', cat_concreteness, cat_babiness, length_type[['Type', 'num_syllables']])


