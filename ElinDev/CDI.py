#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 15 16:51:04 2017

@author: elinlarsen
"""

#import libraries
import os
import pandas as pd
from pandas import DataFrame
import numpy as np


# enter your current directory
os.chdir('/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/Analysis_algos_CDI/')


prop_understand=pd.read_csv("PropUnderstandCDI.csv", sep='\t', header=0)
P_8=pd.read_csv("Prop_understand_CDI_at_age_8.csv", sep='\t', header=0)
P_8['Type']

#clean regular expression : to be done once and to be saved
#prop_understand['words']=prop_understand['words'].str.replace('*', '') #take out regular expression
#prop_understand.to_csv("PropUnderstandCDI.csv", sep='\t', index=False)

##### read file of types in all sub that are in CDI with Brent frequence
df_types_all_subs_CDI=pd.read_csv('TypesAllSubsInCDI', sep="\t", header=0)
df_types_all_subs_CDI.columns=['Type', 'Freq']
df_CDI_13=read.read_CDI_data_by_age(CDI_file="PropUnderstandCDI.txt", age=13, save_file=False)

prop=pd.read_table("PropUndestandCDI.txt", sep='\t', header=0)

# *******   lexical classes *******  

df_CDI_lexical_classes=df_CDI_8[['Type','lexical_classes']]
df_CDI_lexical_classes.to_csv("CDI_lexical_classes.txt",sep='\t', index=False )
gb_lc=df_CDI_lexical_classes.groupby('lexical_classes')
nouns=gb_lc.get_group("nouns")
lexical_classes=gb_lc.groups
list_lexical_classes=lexical_classes.keys()
df_gb_lc=gb_lc.get_group('nouns')


# type length in number of syllables in CDI, these data come from wordbank database, 
length_type=pd.read_csv("Length_type_ph_syl.txt", sep='\t', header=0)
group_syllable_length=length_type.groupby('num_syllables', sort=True, group_keys=True).groups.keys()
group_phoneme_length=length_type.groupby('num_phonemes', sort=True, group_keys=True).groups.keys()



