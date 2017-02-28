# -*- coding: utf-8 -*-
"""
Created on Mon Nov 21 14:07:10 2016

@author: elinlarsen
"""

#import libraries
import os
import pandas as pd
from pandas import DataFrame

# importing python scripts
os.chdir('/Users/elinlarsen/Documents/CDSwordSeg/ElinDev')
import read
import translate
import analyze
import visualize
import model
import robustness

# path where are the data
path_data='/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/recipes/childes/data/Brent'
path_res='/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS'

path_tags="/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/recipes/childes/data/Brent/tags.txt"
path_gold="/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/recipes/childes/data/Brent/gold.txt"
path_ortho="/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/recipes/childes/data/Brent/ortholines.txt"
path_to_file_CDI= "/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/Analysis_algos_CDI/TypesAllSubsInCDI"


# enter your current directory
os.chdir('/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/Analysis_algos_CDI/')


#parameters
ALGOS=['tps','dibs','puddle_py','AGu', 'gold']
#SUBS=["sub0","sub1","sub2","sub3","sub4","sub5","sub6","sub7","sub8","sub9"]
SUB=['full_corpus']
lexical_classes=['nouns','function_words', 'adjectives', 'verbs', 'other']
unit="syllable" 

prop_understand=pd.read_csv("PropUnderstandCDI.csv", sep=None, header=0)
#prop_understand['words']=prop_understand['words'].str.replace('*', '') #take out regular expression
#prop_understand.to_csv("PropUnderstandCDI.csv", sep='\t', index=False)

d=translate.build_phono_to_ortho(path_gold,path_ortho)
dic_corpus= translate.build_phono_to_ortho_representative(d)[0]



     
#### Look at words in common in all sub corpus and sort by frequency
In_all_SUB=analyze.common_type_in_all_sub(SUBS, path_data,name_gold="ortholines.txt")
df_in_all_sub=DataFrame(In_all_SUB.items(), columns=['Type', 'Freq'])
df_sorted=df_in_all_sub.sort('Freq', ascending=False)


##### read file of types in all sub that are in CDI with Brent frequence
df_types_all_subs_CDI=pd.read_csv('TypesAllSubsInCDI', sep="\t", header=0)
df_types_all_subs_CDI.columns=['Type', 'Freq']
df_CDI_8=read.read_CDI_data_by_age(CDI_file="PropUnderstandCDI.csv", age=8, save_file=False)


##### lexical classes
df_CDI_lexical_classes=df_CDI_8[['Type','lexical_classes']]
df_CDI_lexical_classes.to_csv("/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/ComparaisonAvecAGu/CDI_lexical_classes.txt",sep='\t', index=False )
gb_lc=df_CDI_lexical_classes.groupby('lexical_classes')
nouns=gb_lc.get_group("nouns")
lexical_classes=gb_lc.groups
list_lexical_classes=lexical_classes.keys()
df_gb_lc=gb_lc.get_group('nouns')


######################## Segmented words by ALGOS
###### Occurence of words segmented by all algos across sub
#create_file_word_freq(path_res, dic_corpus, SUBS, ALGOS, "/freq-top.txt")
translate.create_file_word_freq(path_res, dic_corpus, SUB, ALGO, unit,freq_file="/freq-top.txt")

################### draw score of CDI against score of all algos
data_r2=visualize.plot_algos_CDI_by_age(path_ortho,path_res, SUBS, ALGOS +['gold'], unit,range(8,19), CDI_file="PropUnderstandCDI.csv", save_file=False, average_algos=False,freq_file="/freq-words.txt",name_visualisation= "CDIScore_AlgoScore")

#look only at gold
data_r2=visualize.plot_algos_CDI_by_age(path_ortho,path_res, SUBS, ['gold'], unit,range(8,10), CDI_file="PropUnderstandCDI.csv", 
         average_algos=False,freq_file="/freq-words.txt",name_vis= "CDIScore_test")

#RESULTS model
df_CDI=read.read_CDI_data_by_age(CDI_file="PropUnderstandCDI.csv", age=range(), save_file=False)


lin_R2_gold=model.linear_algo_CDI(path_ortho,path_res, SUBS, ['gold'],unit, range(8,19), CDI_file="PropUnderstandCDI.csv", 
         average_algos=False,freq_file="/freq-words.txt", out='r2')

lin_R2_gold=model.linear_algo_CDI(path_ortho,path_res, SUBS, ['gold'],unit, range(8,19), CDI_file="PropUnderstandCDI.csv", 
         average_algos=False,freq_file="/freq-words.txt", out='r2')

lin_std_err=model.linear_algo_CDI(path_ortho,path_res, SUBS, ALGOS, unit, range(8,19), CDI_file="PropUnderstandCDI.csv", 
         average_algos=False,freq_file="/freq-words.txt", out='std_err')

df_log_test=visualize.plot_logistic_algo_CDI(path_ortho,path_res, SUBS, ['gold'],unit, range(8,19), CDI_file="PropUnderstandCDI.csv", NbInfant_file="CDI_NbInfantByAge.csv",
         average_algos=False,freq_file="/freq-words.txt",name_vis= "CDIScore_logistic_test", Test_size=0.5)

log_R2=model.logistic_algo_CDI(path_ortho,path_res, SUBS, ALGOS,unit, range(8,19), CDI_file="PropUnderstandCDI.csv",NbInfant_file="CDI_NbInfantByAge.csv" ,
         average_algos=False,freq_file="/freq-words.txt", Test_size=0.05)

'''
R2score for LogisticRegression
Best possible score is 1.0 and it can be negative (because the model can be arbitrarily worse). 
A constant model that always predicts the expected value of y, disregarding the input features, would get a R^2 score of 0.0.
'''

#LEXICAL classes 

visualize.plot_by_lexical_classes(path_res, ['full_corpus'], ['TPs'], unit,[13], lexical_classes, save_file=False, CDI_file="PropUnderstandCDI.csv", freq_file="/freq-words.txt", name_vis="lexical_classes_TPs_13")
visualize.plot_by_lexical_classes(path_res, ['full_corpus'], ['AGu'], unit,[13], lexical_classes, save_file=False, CDI_file="PropUnderstandCDI.csv", freq_file="/freq-words.txt", name_vis="lexical_classes_AGu_13")    
visualize.plot_by_lexical_classes(path_res, ['full_corpus'], ['puddle_py'],unit, [13], lexical_classes, save_file=False, CDI_file="PropUnderstandCDI.csv", freq_file="/freq-words.txt", name_vis="lexical_classes_puddle_py_13")
visualize.plot_by_lexical_classes(path_res, ['full_corpus'], ['dibs'], unit,[13], lexical_classes, save_file=False, CDI_file="PropUnderstandCDI.csv", freq_file="/freq-words.txt", name_vis="lexical_classes_dibs_13")
visualize.plot_by_lexical_classes(path_res, ['full_corpus'], ['gold'], unit,[18], lexical_classes, save_file=False, CDI_file="PropUnderstandCDI.csv", freq_file="/freq-words.txt", name_vis="lexical_classes_gold_18")

###algo vers gold 
visualize.plot_algo_gold_lc(path_res,['full_corpus'], ['tps','dibs','puddle_py','AGu'], 'gold','std_err',"PropUnderstandCDI.csv",lexical_classes, freq_file="/freq-words.txt", name_vis="plot_algos_vs_gold")



### Qualitative analyse

countType=analyze.count_type_segmented_per_algo_per_sub(ALGOS,SUBS,path_res,freq_file="/freq-top.txt")    
countTypeSplit=analyze.count_type_well_segmented_per_algo_per_sub(dic_corpus,ALGOS,SUBS,path_res,freq_file="/freq-top.txt")
                        
intersection_btw_algo=analyze.compare_token_btw_algo(path_res,dic_corpus,SUBS,ALGOS,"dibs","/freq-top.txt")
     
intersection_btw_sub=analyze.compare_token_btw_sub(path_res,dic_corpus,SUBS,sub_ref="sub0",algos=ALGOS,freq_file="/freq-top.txt")
    
intersection_all_sub=analyze.compare_token_all_sub(path_res,dic_corpus,sub=SUBS,algos=ALGOS,freq_file="/freq-top.txt" )

inter_all_algo=analyze.intersection_all_algo(path_res, dic_corpus, sub=SUBS,algos=ALGOS,algo_ref="dibs",freq_file="/freq-top.txt")

dibs_signature=analyze.signature_algo(path_res,dic_corpus,sub=SUBS,algo_ref="dibs",algos=ALGOS,freq_file="/freq-top.txt")
tps_signature=analyze.signature_algo(path_res,dic_corpus,sub=SUBS,algo_ref="tps",algos=ALGOS,freq_file="/freq-top.txt")
puddle_signature=analyze.signature_algo(path_res,dic_corpus,sub=SUBS,algo_ref="puddle",algos=ALGOS,freq_file="/freq-top.txt")
AGu_signature=analyze.signature_algo(path_res,dic_corpus,sub=SUBS,algo_ref="AGu",algos=ALGOS,freq_file="/freq-top.txt")

analyze.Inter_signature(dibs_signature,'dibs')
analyze.Inter_signature(puddle_signature, 'puddle')
analyze.Inter_signature(tps_signature, 'TPs')
analyze.Inter_signature(AGu_signature, 'AGu')
 
inter_all_algo=analyze.intersection_all_algo(path_res, dic_corpus, sub=SUBS,algos=ALGOS,algo_ref="dibs",freq_file="/freq-top.txt")

visualize.plot_algos_CDI_by_age(path_ortho,path_res, False , ALGOS +['gold'], range(8,19), CDI_file="PropUnderstandCDI.csv",freq_file="/freq-words.txt",name_vis= "CDIScore_AlgoScore_sans_fit")

visualize.plot_algos_CDI_by_age(path_ortho,path_res, ["full_corpus"], ['dibs', 'TPs', 'gold', 'puddle_py', 'AGu'],[8,18], CDI_file="PropUnderstandCDI.csv",freq_file="/freq-words.txt", name_vis="plot_all_algos")
    

#test robustness f-score
mean_score_dibs=robustness.search_f_score_file_by_algo(path_res, subs=SUBS,algo='dibs',text_file="/cfgold-res.txt")
mean_score_TPs=robustness.search_f_score_file_by_algo(path_res, subs=SUBS,algo='TPs',text_file="/cfgold-res.txt")
mean_score_AGu=robustness.search_f_score_file_by_algo(path_res, subs=SUBS,algo='AGu',text_file="/cfgold-res.txt")
mean_score_puddle=robustness.search_f_score_file_by_algo(path_res, subs=SUBS,algo='puddle',text_file="/cfgold-res.txt")

R2_ALGOs_CDI_phoneme=model.linear_algo_CDI(path_ortho,path_res,["full_corpus"], ALGOS, "phoneme", range(8,19), CDI_file="PropUnderstandCDI.csv", freq_file="/freq-words.txt", out='r2')

R2_ALGOs_CDI_syllable=model.linear_algo_CDI(path_ortho,path_res,["full_corpus"], ALGOS, "syllable", range(8,19), CDI_file="PropUnderstandCDI.csv", freq_file="/freq-words.txt", out='r2')

std_err_ALGOs_CDI_phoneme=model.linear_algo_CDI(path_ortho,path_res,["full_corpus"], ALGOS, "phoneme", range(8,19), CDI_file="PropUnderstandCDI.csv", freq_file="/freq-words.txt", out='std_err')

std_err_ALGOs_CDI_syllable=model.linear_algo_CDI(path_ortho,path_res,["full_corpus"], ALGOS, "syllable", range(8,19), CDI_file="PropUnderstandCDI.csv", freq_file="/freq-words.txt", out='std_err')


R2_log_phoneme=logistic_algo_CDI(path_ortho,path_res, ["full_corpus"], ALGOS,'phoneme',range(8,19), CDI_file="PropUnderstandCDI.csv", NbInfant_file="CDI_NbInfantByAge",freq_file="/freq-words.txt")
    
R2_log_syllable=logistic_algo_CDI(path_ortho,path_res, ["full_corpus"], ALGOS,'syllable',range(8,19), CDI_file="PropUnderstandCDI.csv", NbInfant_file="CDI_NbInfantByAge",freq_file="/freq-words.txt")


df= R2_ALGOs_CDI_syllable.round(decimals=4)
df.to_csv("R2_algos_CDI_syllable.txt", sep='\t' )

plot_bar_R2_algos_unit_by_age(R2_ALGOs_CDI_phoneme, std_err_ALGOs_CDI_phoneme, range(8,19),ALGOS, name_vis="R2 ALGOs versus CDI with phoneme representation")

plot_bar_R2_algos_unit_by_age(R2_ALGOs_CDI_syllable, std_err_ALGOs_CDI_syllable, range(8,19),ALGOS, name_vis="R2A ALGOs versus CDI with syllable representation")