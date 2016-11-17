# -*- coding: utf-8 -*-
"""
Created on Sat Oct 15 16:53:22 2016

@author: elinlarsen
"""

#useful fonctions

def corpus_as_list(corpus_file):
    ''' open a text file and form a list of tokens'''
    list_corpus=[]
    with open(corpus_file,'r') as text:
        for line in text: 
            for word in line.split():
                list_corpus.append(word)
    return(list_corpus)

def nb_lines_corpus(corpus_file='/Users/elinlarsen/Documents/CDSwordSeg/recipes/bernstein/data_06_10/ADS/phono/tags.txt'):
    ''' count the number of lines in a text file '''
    non_blank_count=0
    with open(corpus_file,'r') as text:
        for line in text:
            if line.strip():
                non_blank_count+=1
    print 'number of non-blank lines found: %d' % non_blank_count
    return(non_blank_count)

        
def remove_item(v,List):
    ''' remove a token in a list of token '''
    for index in range(len(List)):
        if index  >= len(List):
            break
        elif List[index]==v:
            List.remove(v) 
    return(len(List))



def inter_per_size(sub, path, algo1, algo2="dibs", freq_file="/freq-top.txt", size=[20,50,100,200,300,500]):
    y=[]
    for i in range(len(size)):
        len_list=list_token_per_algo(algo1,sub,path, size[i],freq_file)[1]
        len_inter=len(inter_algo_per_subcorpus(sub,path,size[i],algo1,algo2,freq_file))
        res=len_inter/len_list
        y.append(res)
    print(y)
    plt.plot(size,y) 
    #plt.ylabel("Intersection des types segmentés par les 2 algos considérés")
    #plt.xlabel("Nombre des types segmentés les plus fréquents sélectionnés")
    plt.show()
    