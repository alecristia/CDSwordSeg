# -*- coding: utf-8 -*-
"""
Created on Fri Feb 24 10:45:32 2017

@author: elinlarsen
"""


from collections import Counter

def create_counter_syll(tags_file):
    syllable=Counter()

    with open(tags_file,'r') as f:
        filedata = f.read()
        filedata = filedata.replace(';eword', '')
        filedata = filedata.replace(' ', '')
        filedata = filedata.replace(';esyll', ' ')

        list_lines=filedata.split() 
        
        for syl in list_lines: 
                syllable.update([syl])          
    return syllable
    

#test
tags='/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/recipes/childes/data/Brent/tags.txt'
dic=create_counter_syll(tags)


def generate_unigram_grammar_syll_file(dic_syll, name_file):
    sorted_syllables=[]
    for key,value in sorted(dic.items()):
        sorted_syllables.append(key)
    with open (name_file,'w') as g:
        g.write('1 1 Sentence --> Colloc0s' + '\n')
        g.write('1 1 Colloc0s --> Colloc0'+ '\n')
        g.write('1 1 Colloc0s --> Colloc0 Colloc0s'+ '\n')
        g.write('Colloc0 --> Syllables'+ '\n')
        g.write('1 1 Syllables --> Syllable'+ '\n')
        g.write('1 1 Syllables --> Syllable Syllables'+ '\n')
        for syl in sorted_syllables: 
            g.write('1 1 Syllable --> ' + syl + '\n')
        
#test
name='/Users/elinlarsen/Documents/CDSwordSeg/algoComp/algos/AG/grammars/syllable/Colloc0syll_en.lt'
generate_unigram_grammar_syll_file(dic, name)  
            
        

