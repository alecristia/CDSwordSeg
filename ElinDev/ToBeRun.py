# -*- coding: utf-8 -*-
"""
Created on Sat Oct 15 13:25:12 2016

@author: elinlarsen
"""

# -*- coding: utf-8 -*-
import os 
import random
import itertools
import matplotlib.pyplot as plt
import numpy as np
import collections
import operator
from itertools import izip
import glob
#from functions-subset.py import *


#########################  MERGE data files (ortholines, tags, gold) of each child to get a big corpus 
def merge_data_files(corpus_path, name_corpus, name_file):
    ''' name_file ="/ortholines.txt", "/tags.txt", "/gold.txt" '''
    ''' the output is writtent in the current working directory'''
    path=corpus_path + "*" + "/"+ name_file                  
    for file in glob.glob(path):
        with open(file,'r') as infile:
            with open(corpus_path+name_file,'a') as outfile:
                for line in infile:
                    outfile.write(line)
#TEST        
os.chdir('/Users/elinlarsen/Documents/CDSwordSeg/recipes/childes/data')
merge_data_files(corpus_path="/Users/elinlarsen/Documents/CDSwordSeg/recipes/childes/data/Providence/", name_corpus="Brent", name_file="ortholines.txt")


######################### OPEN TEXT FILE AS LIST OF TOKEN
def corpus_as_list(corpus_file):
    ''' open a text file and form a list of tokens'''
    list_corpus=[]
    with open(corpus_file,'r') as text:
        for line in text: 
            for word in line.split():
                list_corpus.append(word)
    return(list_corpus)

def count_lines_corpus(corpus_file='/Users/elinlarsen/Documents/CDSwordSeg/recipes/bernstein/data_06_10/ADS/phono/tags.txt'):
    ''' count the number of lines in a text file '''
    non_blank_count=0
    with open(corpus_file,'r') as text:
        for line in text:
            if line.strip():
                non_blank_count+=1
    print 'number of non-blank lines found: %d' % non_blank_count
    return(non_blank_count)

cds_lines= count_lines_corpus('/Users/elinlarsen/Documents/CDSwordSeg/recipes/bernstein/data_06_10/CDS/phono/tags.txt')


######################### CREATION OF SUB-CORPUS : the whole corpus is divided k times
def divide_corpus(text_file,k, output_dir,output_name="/gold.txt"):
    non_blank_count=0
    with open(text_file,'r') as text:
        for line in text:
            if line.strip():
                non_blank_count+=1
    q=non_blank_count/k
    r=non_blank_count%k
    with open(text_file,'r') as f:
        lines = f.readlines()
    for j in range(k):
        s="sub"+str(j)
        newpath=output_dir+s
        if not os.path.exists(newpath):
            os.makedirs(newpath)
        os.chdir(newpath)
        nom=output_dir+"/"+s+output_name
        dataFile=open(nom,'w')
        for line in lines[j*q:(j+1)*q]:
            dataFile.write(line)
#test
test_sub=sub_corpus(text_file=path_tags,k=10,output_dir=path_data,output_name="/tags.txt")            

######################### OPEN FREQ FILE AS A LIST OF TOKEN 
def list_freq_token_per_algo(algo,sub,path_res,freq_file="/freq-top.txt"):
    algo_list=[]
    if algo!="ngrams": 
    ### read only the second columns: top frequent phonological type segmented 
        with open(path_res+"/"+sub+"/"+algo+freq_file) as inf:
            for line in inf:
                parts = line.split() # split line into parts
                if len(parts) > 1:   # if at least 2 parts/columns
                    #if parts[0]>1:
                    algo_list.append(parts[1])
    else : 
        with open(path_res+"/"+sub+"/"+algo+freq_file) as inf:
            for line in inf:
                parts = line.split() # split line into parts
                if len(parts) > 2:   # if at least 3 parts/columns
                    #if parts[0]>1:
                    algo_list.append(parts[2])
    res=[algo_list,len(algo_list)]
    return(res)
    

######################### Dictionnary from phono text to ortho text
# open ortho and gold file and check if in each line, the number of words match
# if not, skip the line and count the error, 
# then create a dictionarry with key each phono token and value a dictionary  of ortho token with their occurence
def build_phono_to_ortho(phono_file, ortho_file):
    count_errors = 0
    d=collections.defaultdict(dict)
    with open(phono_file,'r') as phono, open(ortho_file,'r') as ortho:
            for line_phono, line_ortho in izip(phono, ortho):
                line_phono = line_phono.lower().split()
                line_ortho = line_ortho.lower().split()
                if len(line_phono) != len(line_ortho):
                    count_errors += 1
                else:
                    for word_phono, word_ortho in izip(line_phono, line_ortho):
                        count_freq = d[word_phono]
                        try:
                            count_freq[word_ortho] += 1
                        except:
                            count_freq[word_ortho] = 1
    print "There were {} errors".format(count_errors)
    return d

#########################  list of two dictionaries: 
# 1. one of phono token and the most representative ortho token
# 2. one linking token to their freqency 
def build_phono_to_ortho_representative(d):
    res ={}
    token_freq={}
    for d_key,d_value in d.iteritems():
        value_max=0
        key_max = 'undefined'
        for key, value in d_value.iteritems():
            if value > value_max:
                value_max = value
                key_max = key
        res[d_key] = key_max
        token_freq[value_max]=key_max
    
    #freq_token = {v: k for k, v in token_freq.iteritems()}
    freq_res=sorted(token_freq.items(),reverse=True)
    return([res,freq_res])
    

def freq_token_in_corpus(ortho_file):
    count_freq={}
    token_freq={}
    t=[]
    with open(ortho_file,'r') as ortho: 
        for line in ortho: 
            for word in line.split():
                try: 
                    count_freq[word]+=1
                except: 
                    count_freq[word]=1
    rank=count_freq.values()
    rank=sorted(rank,reverse=True)
    '''value_max=0
    key_max = 'undefined'
    for key, value in count_freq.iteritems():
         t.append([value,key])
    t_s= sorted(sorted(t, key = lambda x : x[1]), key = lambda x : x[0], reverse = True) ''' 
    print(rank)
    return([count_freq,rank])

freq_ortho_0=freq_token_in_corpus(path_ortho_sub0)[0]
rank_ortho_0=freq_token_in_corpus(path_ortho_sub0)[1]

def add_freq_to_list_token(intersection_all_algo,freq_list,nb_sub):
    '''look at each element of the token segmented by all algo in one subcorpus  
    and add the frequence in which they occur in each subcorpus '''     
    freq={}
    not_in_dic=[]
    for i in intersection_all_algo[nb_sub].values()[0]:   
        if i not in freq_list.keys():
            not_in_dic.append(i)
            print(i)
        else:
            freq[i]=freq_list[i] 
    return(freq)

test=add_freq_to_list_token(intersection_all_algo,freq_ortho_0,0)
#### write a script that match words, rank and freq in a sub corpus and create a text file with results
    
######################### SPLIT BETWEEN BAD AND WELL SEGMENTED TOKEN
#  by checking if they belong to the dictionnary
def split_segmented_token(dic, list_token):
    ortho_inter=[]
    bad_seg_inter=[]
    d={}
    for item in list_token: 
        if dic.has_key(item)==False:
            bad_seg_inter.append(item)
        else: 
            ortho_inter.append(dic[item])
    d['wrong_segmentation']=bad_seg_inter
    d['ortho']=ortho_inter
    return(d)    


######################### Comparison of algorithms intersection between sub-corpus
def compare_token_btw_algo(path_res, dic_corpus, sub=["sub0","sub1","sub2","sub3","sub4","sub5","sub6","sub7","sub8","sub9"],
                          algos=['dibs','ngrams','tps','puddle','dmcmc','AGu'],algo_ref="dibs",freq_file="/freq-top.txt"): 
    res=[]
    for i in range(len(sub)):
        dic_inter={}
        ref=list_freq_token_per_algo(algo_ref,sub[i],path_res,freq_file)[0]
        for j in range(len(algos)):
            if algos[j]!=algo_ref:
                b=list_freq_token_per_algo(algos[j],sub[i],path_res,freq_file)[0]
                list_inter=list(set(ref).intersection(set(b)))
                dic_inter[algos[j]]=split_segmented_token(dic_corpus, list_inter)
        res.append(dic_inter)   
    return(res)
    ##v = venn2(subsets = {'10':len(algo1_list),'01':len(inter_algo12), '11': len(algo_list2)}, set_labels = (algo1, algo2))

def intersection_all_algo(path_res, dic_corpus, sub=["sub0","sub1","sub2","sub3","sub4","sub5","sub6","sub7","sub8","sub9"],
                          algos=['dibs','ngrams','tps','puddle','dmcmc','AGu'],algo_ref="dibs",freq_file="/freq-top.txt"):
    """for each sub-corpus, look at types segmented by all algorithms """
    res=[]
    dic={}
    a_ortho={}
    a_wrong_seg={}
    n=len(algos)-2
    for ss in sub:
        ref_ortho=compare_token_btw_algo(path_res, dic_corpus,[ss],algos,algo_ref,freq_file)[0].values()[n]["ortho"]
        ref_wrong_seg=compare_token_btw_algo(path_res, dic_corpus,[ss],algos,algo_ref,freq_file)[0].values()[n]["wrong_segmentation"]
        for algo in algos:
            if not algo==algo_ref:
                a_ortho[algo]=compare_token_btw_algo(path_res, dic_corpus,[ss],algos,algo_ref,freq_file)[0][algo]["ortho"]
                a_wrong_seg[algo]=compare_token_btw_algo(path_res, dic_corpus,[ss],algos,algo_ref,freq_file)[0][algo]["wrong_segmentation"]
                ref_ortho=list(set(ref_ortho).intersection(set(a_ortho[algo])))
                ref_wrong_seg=list(set(ref_wrong_seg).intersection(set(a_wrong_seg[algo])))
        dic["ortho"]=ref_ortho
        dic["wrong_segmentation"]=ref_wrong_seg
        res.append(dic)
    file = open("TypesBySubsInAllAlgos.txt", "w")
    for i in range(len(sub)): 
        file.write(sub[i] +"\n"+"\n")
        mean_o=0
        for j in ["ortho"]:
            count=0
            file.write(j+"\n"+"\n")
            for types in res[i][j]:
                file.write(types +"\n")
                count+=1
        mean_o+=count
        file.write("Number of types well segmented by all algorithms in " + sub[i] + " are : " + str(count) +"\n"+"\n")
        mean_ws=0
        for jj in ["wrong_segmentation"]: 
            count=0
            file.write(jj+"\n"+"\n")
            for types in res[i][jj]:
                file.write(types +"\n")
                count+=1
        mean_ws+=count
        file.write("Number of types badly segmented by all algorithms in the subcorpus " + sub[i] + " are : " + str(count) +"\n"+"\n")   
    mean_o=mean_o/len(sub)
    mean_ws=mean_ws/len(sub)
    file.write("Mean word per sub is :"+str(mean_o)+ "\n")
    file.write("Mean wrong segmented types per sub is :"+str(mean_ws)+"\n")
    file.close()
    return(res)
    
def compare_token_btw_sub(path_res,dic_corpus,sub=["sub0","sub1","sub2","sub3","sub4","sub5","sub6","sub7","sub8","sub9"],sub_ref="sub0",
                          algos=['dibs','ngrams','tps','puddle','dmcmc','AGu'],freq_file="/freq-top.txt"):
    '''for each algo, comparison of intersection of words and non words segmented in two different corpus for all subcorpus'''
    res={}
    for j in range(len(algos)):
        comparison_sub_for_one_algo=[]
        ref=list_freq_token_per_algo(algos[j],sub_ref,path_res,freq_file)[0]
        for i in range(len(sub)):
            dic_inter={} #empty dictionnary
            b=list_freq_token_per_algo(algos[j],sub[i],path_res,freq_file)[0]
            list_inter=list(set(ref).intersection(set(b)))# intersection of token of sub[i] and sub_ref for one algo
            dic_inter[sub[i]]=split_segmented_token(dic_corpus, list_inter) # distinction of token as word or badly segmented for one sub_corpus
            comparison_sub_for_one_algo.append(dic_inter) # add the comparison in a list 
        res[algos[j]]=comparison_sub_for_one_algo
    return(res) 

def compare_token_all_sub(path_res,dic_corpus,sub=["sub0","sub1","sub2","sub3","sub4","sub5","sub6","sub7","sub8","sub9"],algos=['dibs','ngrams','tps','puddle','dmcmc','AGu'],freq_file="/freq-top.txt"):
    n=len(sub)-1
    res={}
    for i in range(len(algos)):
        comp_all_sub_per_algo=list_freq_token_per_algo(algos[i],sub[n],path_res,freq_file)[0]# list of freq words for algo[i] computed in  sub[n]
        for j in range(n):
            a=list_freq_token_per_algo(algos[i],sub[j],path_res,freq_file)[0]
            comp_all_sub_per_algo=list(set(a).intersection(set(comp_all_sub_per_algo)))
        all_sub_per_algo_dis=split_segmented_token(dic_corpus, comp_all_sub_per_algo) 
        res[algos[i]]=all_sub_per_algo_dis
    file = open("TypesByAlgosInAllSubs.txt", "w")
    for i in algos: 
        file.write(i +"\n"+"\n")
        for j in ["ortho"]:
            count=0
            file.write(j+"\n"+"\n")
            for types in res[i][j]:
                file.write(types +"\n")
                count+=1
        file.write("Number of types well segmented by " + i + " are : " + str(count) +"\n"+"\n")
        for jj in ["wrong_segmentation"]: 
            count=0
            file.write(jj+"\n"+"\n")
            for types in res[i][jj]:
                file.write(types +"\n")
                count+=1
        file.write("Number of types badly segmented by " + i + " are : " + str(count) +"\n"+"\n")   
    file.close()
    return(res)

########################    
def differentiate_token_btwn_algo(path_res,dic_corpus,sub=["sub0","sub1","sub2","sub3","sub4","sub5","sub6","sub7","sub8","sub9"],algo_ref="dibs",
                          algos=['dibs','ngrams','tps','puddle','dmcmc','AGu'],freq_file="/freq-top.txt"):
    res=[]
    for i in range(len(sub)):
        dic_inter={}
        ref=list_freq_token_per_algo(algo_ref,sub[i],path_res,freq_file)[0]
        for j in range(len(algos)):
            if algos[j]!=algo_ref:
                b=list_freq_token_per_algo(algos[j],sub[i],path_res,freq_file)[0]
                list_diff=[k for k in ref if not k in b]
                dic_inter[algos[j]]=split_segmented_token(dic_corpus, list_diff)
        res.append(dic_inter)     
    return(res)
    
def signature_algo(path_res,dic_corpus,sub=["sub0","sub1","sub2","sub3","sub4","sub5","sub6","sub7","sub8","sub9"],algo_ref="dibs",
                          algos=['dibs','ngrams','tps','puddle','dmcmc','AGu'],freq_file="/freq-top.txt"):
    res=[]
    n=len(algos)
    for i in range(len(sub)):
        dic_inter={}
        ref=list_freq_token_per_algo(algo_ref,sub[i],path_res,freq_file)[0]
        for j in range(n):
            if not algos[j]==algo_ref: 
                b=list_freq_token_per_algo(algos[j],sub[i],path_res, freq_file)[0]
                dic_inter[algos[j]]=[k for k in ref if not k in b] # which token is segmented in ref and not in algo j
        sign_ref=dic_inter.values()[0]
        #print(sign_ref)
        for j in range(n-1):
            if not algos[j]==algo_ref: 
                sign_ref=set(sign_ref) & set(dic_inter[algos[j]])
        #for key, value in dic_inter.iteritems():
            #inter_diff=list(set(dic_inter.values()[0]).intersection(set(value)))# which token is segmented in ref and not in all the others algo     
        token_algo_ref=split_segmented_token(dic_corpus,sign_ref)
        res.append(token_algo_ref)     
    return(res)

def in_common_two_algo( path_res,dic_corpus, sub, algos, algo1, algo2, freq_file):
    dic_inter={}
    ref1=list_freq_token_per_algo(algo1,sub,path_res,freq_file)[0]
    ref2=list_freq_token_per_algo(algo2,sub,path_res,freq_file)[0]
    inter=list(set(ref1).intersection(set(ref2)))
    for j in range(len(algos)):
        if (algos[j]!=algo1 and algos[j]!=algo2):
            inter=[x for x in inter if x not in list(set(ref1).intersection(set(algos[j])))]
            #create intersection of token belonging only to algo1 and algo2
    dic_inter[algo1,algo2]=split_segmented_token(dic_corpus, inter)
    return(dic_inter)

def common_type_in_all_sub(sub, path_data,name_gold="gold.txt"):
    sub_ref=sub[1]
    path_ref=path=path_data+str(sub_ref)+"/"+name_gold
    list_ref=corpus_as_list(path_ref)
    for i in sub: 
        if not sub==sub_ref:
            path=path_data+str(i)+"/"+name_gold
            list_sub=corpus_as_list(corpus_file=path)
            list_sub=[x for x in list_sub if x in list_ref]
    return([list_sub,len(list_sub)])
        
    
    
def intersection_exclusive_in_2_algo( path_res, dic_corpus, sub, algos, freq_file="/freq-top.txt"):
    '''for one sub !!!! '''
    tuple_res=()
    res=[]
    z=list(numpy.copy(algos))
    n=len(algos)*(len(algos)-1)/2
    file = open("TypesCommonsIn2Algos.txt", "w")
    for algo1 in z:  
        #print(z)
        #z.remove(algo1)
        for algo2 in z:
            #z.remove(algo2)
            if algo2!=algo1:
                res.append(in_common_two_algo(path_res,dic_corpus, sub, z, algo1, algo2, freq_file))
    for i in range(len(res)): 
        file.write(str(res[i].keys()[0]) +"\n"+"\n")
        #for j in ["ortho"]:
        count=0
        file.write(str("ortho")+"\n"+"\n")
        for types in res[i].values()[0].values()[0]:
            file.write(types +"\n")
            count+=1
        file.write("Number of types well segmented in common all " + str(res[i].keys()[0])+  str(sub) +" are : " + str(count) +"\n"+"\n")
        #for jj in ["wrong_segmentation"]: 
        count=0
        file.write(str("wrong_segmentation")+"\n"+"\n")
        for types in res[i].values()[0].values()[1]:
            file.write(types +"\n")
            count+=1
        file.write("Number of types badly segmented in common by  " +str(res[i].keys()[0]) + " in" + str(sub) + " are : " + str(count) +"\n"+"\n")   
    file.close()
    return(res) 
    
def average_inter_per_sub( path_res, dic_corpus, sub, algos, freq_file="/freq-top.txt"):
    res=[]
    for ss in sub: 
        res.append(intersection_exclusive_in_2_algo(path_res, dic_corpus, ss, algos, freq_file="/freq-top.txt"))
  
def count_type_segmented_per_algo_per_sub(algos,sub,path_res, freq_file="/freq-top.txt"):
    res=[]
    file=open("NumberTypesPerAlgoPerSub.txt","w")
    for i in sub: 
        file.write("\n"+i+"\n")
        for j in algos: 
            count=list_freq_token_per_algo(j,i,path_res,freq_file)[1]
            file.write(j+" " +str(count)+"\n")
            res.append(count)
    file.close()
    return(res)  
    
def count_type_well_segmented_per_algo_per_sub(dic,algos,sub,path_res,freq_file="/freq-top.txt"):
    res=[]
    file=open("NumberTypesPerAlgoPerSub.txt","w")
    for i in sub: 
        file.write("\n"+i+"\n")
        for j in algos: 
            list_type=list_freq_token_per_algo(j,i,path_res,freq_file)[0]
            splitted=split_segmented_token(dic, list_type)
            count_o=len(splitted["ortho"])
            file.write(j+" " + str("ortho")+" " +str(count_o)+"\n")
            count_ws=len(splitted['wrong_segmentation'])
            file.write(j+" " +str("wrong_segmentation")+" " +str(count_ws)+"\n")
    file.close()

    

######################### TESTS  
#Arguments of corpus
k=10
path_data="/Users/elinlarsen/Documents/CDSwordSeg/recipes/bernstein/data_06_10/ADS/"
path_res="/Users/elinlarsen/Documents/CDSwordSeg/algoComp/res-sub-bern-ADS/"
path_tags="/Users/elinlarsen/Documents/CDSwordSeg/recipes/bernstein/data_06_10/ADS/phono/tags.txt"
path_gold="/Users/elinlarsen/Documents/CDSwordSeg/recipes/bernstein/data_06_10/ADS/phono/gold.txt"
path_ortho="/Users/elinlarsen/Documents/CDSwordSeg/recipes/bernstein/data_06_10/ADS/ortho/ortholines.txt"
path_ortho_sub0="/Users/elinlarsen/Documents/CDSwordSeg/recipes/bernstein/data_06_10/ADS/sub0/ortholines.txt"
#cleaning arguments
#args_ortho=['nt','n','ll']
#args_phono=['ehn','tiy','ehl']

#arguments of algos
ALGOS=['tps','dibs','puddle']
SUBS=["sub0","sub1","sub2","sub3","sub4","sub5","sub6","sub7","sub8","sub9"]

#lists of token
o=corpus_as_list(path_ortho)
g=corpus_as_list(path_gold)
t=corpus_as_list(tags)

### number of lines
lines_ortho=count_lines_corpus(corpus_file=path_ortho)
lines_gold=count_lines_corpus(path_gold)

lines_sub=[]
for ss in SUBS: 
    sub_ortho=path_data+ss+"/"+"ortholines.txt"
    sub_gold=path_data+ss+"/"+"gold.txt"
    d_subcorpus.append(count_lines_corpus(sub_gold))
  
    
#### freq file
freq_ngrams_0=list_freq_token_per_algo("ngrams","sub0",path_res,"/freq-top.txt")[0]
freq_tps_0=list_freq_token_per_algo("tps","sub0",path_res,"/freq-top.txt")[0]
freq_dibs_0=list_freq_token_per_algo("dibs","sub0",path_res,"/freq-top.txt")[0]
freq_puddle_0=list_freq_token_per_algo("puddle","sub0",path_res,"/freq-top.txt")[0]

seg_ngrams_0=split_segmented_token(dic_corpus, freq_ngrams_0)
seg_tps_0=split_segmented_token(dic_corpus, freq_tps_0)
seg_dibs_0=split_segmented_token(dic_corpus, freq_dibs_0)
seg_puddle_0=split_segmented_token(dic_corpus, freq_puddle_0)

def mean_token_segmented_per_sub(algos, sub,path_res, dic, freq_file):
    freq={}
    seg_freq={}
    res={}
    mean_o=collections.defaultdict(int)
    mean_ws=collections.defaultdict(int)
    count_o={}
    count_ws={}
    for algo in algos: 
        for ss in sub: 
            freq[ss]=list_freq_token_per_algo(algo,ss,path_res,freq_file)[0]
            seg_freq[ss]=split_segmented_token(dic, freq[ss])
            count_o[ss]=len(seg_freq[ss].values()[0])
            print(count_o[ss])
            count_ws[ss]=len(seg_freq[ss].values()[1])
            mean_o[algo]+=count_o[ss]
            mean_ws[algo]+=count_ws[ss]
        mean_o[algo]=mean_o[algo]/len(sub)
        mean_ws[algo]=mean_ws[algo]/len(sub)
        res["ortho"]=mean_o
        res["wrong_segmentation"]=mean_ws
    #file=open("MeanTokensSegmentedAllSubs.txt",'w')
    #file.write(res)
    #file.close()
    return(res)
        
mean_freq_res=mean_token_segmented_per_sub(ALGOS, SUBS,path_res, dic_corpus, freq_file="/freq-top.txt")

#dictionary phono to ortho of ADS bernstein corpus
d=build_phono_to_ortho(path_gold,path_ortho)
dic_corpus= build_phono_to_ortho_representative(d)[0]
freq_token=build_phono_to_ortho_representative(d)[1]
freq_ortho_0=freq_token_in_corpus(path_ortho_sub0)

d_subcorpus=[]
for ss in SUBS: 
    sub_ortho=path_data+ss+"/"+"ortholines.txt"
    sub_gold=path_data+ss+"/"+"gold.txt"
    d_subcorpus.append(build_phono_to_ortho(sub_gold,sub_ortho))
    
    
countType=count_type_segmented_per_algo_per_sub(ALGOS,SUBS,path_res,freq_file="/freq-top.txt")    
countTypeSplit=count_type_well_segmented_per_algo_per_sub(dic_corpus,ALGOS,SUBS,path_res,freq_file="/freq-top.txt")
                        
intersection_btw_algo=compare_token_btw_algo(path_res,dic_corpus,SUBS,ALGOS,"dibs","/freq-top.txt")
     
intersection_btw_sub=compare_token_btw_sub(path_res,dic_corpus,SUBS,sub_ref="sub0",algos=ALGOS,freq_file="/freq-top.txt")
    
intersection_all_sub=compare_token_all_sub(path_res,dic_corpus,sub=SUBS,algos=ALGOS,freq_file="/freq-top.txt" )

intersection_all_algo=intersection_all_algo(path_res, dic_corpus, sub=SUBS,algos=ALGOS,algo_ref="dibs",freq_file="/freq-top.txt")

#for one sub !!!!
list_inter_exclu=intersection_exclusive_in_2_algo(path_res,dic_corpus,"sub0",ALGOS, freq_file="/freq-top.txt") 


## tokens segmented by all algos in all 
ALGOS=['dibs','tps','puddle']
 dibs_signature=signature_algo(path_res,dic_corpus,sub=SUBS,algo_ref="dibs",algos=ALGOS,freq_file="/freq-top.txt")
 tps_signature=signature_algo(path_res,dic_corpus,sub=SUBS,algo_ref="tps",algos=ALGOS,freq_file="/freq-top.txt")
 puddle_signature=signature_algo(path_res,dic_corpus,sub=SUBS,algo_ref="puddle",algos=ALGOS,freq_file="/freq-top.txt")
  
ALGOS=['ngrams', 'dibs','tps','puddle']
ngrams_signature=signature_algo(path_res,dic_corpus,sub=SUBS,algo_ref="ngrams",algos=ALGOS,freq_file="/freq-top.txt")
 
### mean singnature across all sub
def mean_signature_all_sub(signature, sub):
    mean_sign_o=0
    mean_sign_ws=0
    for i in range(len(sub)): 
        mean_sign_o+=len(signature[i].values()[0])
        mean_sign_ws+=len(signature[i].values()[1])
    mean_sign_o=mean_sign_o/len(sub)
    mean_sign_ws=mean_sign_ws/len(sub)
    res=[mean_sign_o, mean_sign_ws]
    print(res)
    return(res)
  
dibs_mean=mean_signature_all_sub(dibs_signature, SUBS)
tps_mean=mean_signature_all_sub(tps_signature, SUBS)
puddle_mean=mean_signature_all_sub(puddle_signature, SUBS)
ngrams_mean=mean_signature_all_sub(ngrams_signature, SUBS) 
 
def Inter_signature_per_sub(nb_inter, signature): 
    """" signature of one algo for each sub corpus"""
    ortho=set(signature[0]["ortho"])
    ws=set(signature[0]['wrong_segmentation'])
    for i in range(nb_inter):
        if not i==0:
            ortho= set(ortho) & set(signature[i]["ortho"])
            ws= set(ws) & set(signature[i]['wrong_segmentation'])
    print("ortho : " +str(len(ortho)) +" and wrong segmented "+ str(len(ws)))
    return([ortho,ws])

def Inter_signature(signature,name_algo): 
    """" signature of one algo for each sub corpus"""
    n=len(signature)
    ortho=set(signature[n-1]["ortho"])
    ws=set(signature[n-1]['wrong_segmentation'])
    file=open("Signature"+ name_algo+"PerSub.txt","w")
    for i in range(n-1):
        file.write("\n"+"Number of intersection between subcorpus : "+ str(i+2) + "\n")
        for ii in range(i):
            ortho= set(ortho) & set(signature[ii]["ortho"])
            ws= set(ws) & set(signature[ii]['wrong_segmentation'])
        file.write("\n"+"Words types : "+"\n" )
        for word in ortho:
            file.write(word + "\n")  
        file.write("\n"+"Badly segmented"+ "\n")
        for word in ws:
            file.write( word + "\n")
        file.write("\n"+ "Number of words types segmented in common between subcorpus : "+ str(len(ortho)) + "\n")
        file.write("\n"+"Number of types badly segmented in common between subcorpus : "+ str(len(ws)) + "\n")
    return([ortho,ws])

test_sign_inter=Inter_signature_per_sub(2, dibs_signature)
##Check: well segmented token       
set_dibs=set(dibs_signature[0]["ortho"])
set_ngrams=set(ngrams_signature[0]["ortho"])
set_tps=set(tps_signature[0]["ortho"])
set_puddle=set(puddle_signature[0]["ortho"])

set_dibs & set_ngrams
set_dibs & set_tps
set_dibs & set_puddle 

set_tps & set_ngrams 
set_puddle & set_ngrams 

set_tps & set_puddle

##### bad segmented token
set_dibs=set(dibs_signature[0]['wrong_segmentation'])
set_ngrams=set(ngrams_signature[0]['wrong_segmentation'])
set_tps=set(tps_signature[0]["wrong_segmentation"])
set_puddle=set(puddle_signature[0]["wrong_segmentation"])

set_dibs & set_ngrams
set_dibs & set_tps
set_dibs & set_puddle 

set_tps & set_ngrams 
set_puddle & set_ngrams 

set_tps & set_puddle


#### for one sub : sub0
dibs_ngrams=intersection_btw_algo[0]["ngrams"]
dibs_tps=intersection_btw_algo[0]["tps"]
dibs_puddle=intersection_btw_algo[0]["puddle"]

### across all sub

dibs_ngrams_o=[]
dibs_ngrams_ws=[]
for i in range(len(SUBS)): 
    dibs_ngrams_o.append(len(intersection_btw_algo[i]["ngrams"].values()[0]))
    dibs_ngrams_ws.append(len(intersection_btw_algo[i]["ngrams"].values()[1]))
print(sum(dibs_ngrams_o)/len(dibs_ngrams_o))
print(sum(dibs_ngrams_ws)/len(dibs_ngrams_ws))

dibs_tps_o=[]
dibs_tps_ws=[]
for i in range(len(SUBS)): 
    dibs_tps_o.append(len(intersection_btw_algo[i]["tps"].values()[0]))
    dibs_tps_ws.append(len(intersection_btw_algo[i]["tps"].values()[1]))
print(sum(dibs_tps_o)/len(dibs_tps_o))
print(sum(dibs_tps_ws)/len(dibs_tps_ws))

dibs_p_o=[]
dibs_p_ws=[]
for i in range(len(SUBS)): 
    dibs_p_o.append(len(intersection_btw_algo[i]["puddle"].values()[0]))
    dibs_p_ws.append(len(intersection_btw_algo[i]["puddle"].values()[1]))
print(sum(dibs_p_o)/len(dibs_p_o))
print(sum(dibs_p_ws)/len(dibs_p_ws))


intersection_btw_algo_ngrams=compare_token_btw_algo(path_res,dic_corpus,SUBS,ALGOS,"ngrams","/freq-top.txt",)
intersection_btw_algo_puddle=compare_token_btw_algo(path_res,dic_corpus,SUBS,ALGOS,"puddle","/freq-top.txt",)
ngrams_p_o=[]
ngrams_p_ws=[]
for i in range(len(SUBS)): 
    ngrams_p_o.append(len(intersection_btw_algo_ngrams[i]["puddle"].values()[0]))
    ngrams_p_ws.append(len(intersection_btw_algo_ngrams[i]["puddle"].values()[1]))
print(sum(ngrams_p_o)/len(ngrams_p_o))
print(sum(ngrams_p_ws)/len(ngrams_p_ws))

ngrams_tp_o=[]
ngrams_tp_ws=[]
for i in range(len(SUBS)): 
    ngrams_tp_o.append(len(intersection_btw_algo_ngrams[i]["tps"].values()[0]))
    ngrams_tp_ws.append(len(intersection_btw_algo_ngrams[i]["tps"].values()[1]))
print(sum(ngrams_tp_o)/len(ngrams_tp_o))
print(sum(ngrams_tp_ws)/len(ngrams_tp_ws))

puddle_tp_o=[]
puddle_tp_ws=[]
for i in range(len(SUBS)): 
    puddle_tp_o.append(len(intersection_btw_algo_puddle[i]["tps"].values()[0]))
    puddle_tp_ws.append(len(intersection_btw_algo_puddle[i]["tps"].values()[1]))
print(sum(puddle_tp_o)/len(puddle_tp_o))
print(sum(puddle_tp_ws)/len(puddle_tp_ws))


inter_all_algo_ortho=set(dibs_ngrams["ortho"]) & set(dibs_tps["ortho"]) & set(dibs_puddle["ortho"])
inter_all_algo_wrong_seg=set(dibs_ngrams["wrong_segmentation"]) & set(dibs_tps["wrong_segmentation"]) & set(dibs_puddle["wrong_segmentation"])


#### across all sub
dibs_all=intersection_all_sub["dibs"]
ngrams_all=intersection_all_sub["ngrams"]
tps_all=intersection_all_sub["tps"]
puddle_all=intersection_all_sub["puddle"]

ortho_all=set(dibs_all["ortho"]) & set(ngrams_all["ortho"]) & set(tps_all["ortho"]) & set(puddle_all["ortho"])
wrong_seg_all=set(dibs_all['bag segmented']) & set(ngrams_all['bag segmented']) & set(tps_all['bag segmented']) & set(puddle_all['bag segmented'])

def average_signature_per_sub(signature):
    n=len(signature)
    ref_ortho=signature[n-1].values()[0]
    ref_ws=signature[n-1].values()[1]
    for i in range(n):
        ref_ortho=set(signature[i].values()[0]).intersection(set(ref_ortho))
        ref_ws=set(signature[i].values()[1]).intersection(set(ref_ws))
    return[ref_ortho,ref_ws]
    
def average_len_signature_per_sub(signature):
    n=len(signature)
    len_o=[]
    len_ws=[]
    res={}
    for i in range(n):
        len_o.append(len(signature[i].values()[0]))
        len_ws.append(len(signature[i].values()[1]))
    res["ortho"]=sum(len_o)/len(len_o)
    res["ws"]=sum(len_ws)/len(len_ws)
    return res
    
    
mean_dibs_signature=average_signature_per_sub(dibs_signature)
mean_tps_signature=average_signature_per_sub(tps_signature)
mean_puddle_signature=average_signature_per_sub(puddle_signature)

set(mean_tps_signature["ortho"]) & set(mean_ngrams_signature["ortho"])

average_len_dibs=average_len_signature_per_sub(dibs_signature)
average_len_ngrams=average_len_signature_per_sub(ngrams_signature)
average_len_tps=average_len_signature_per_sub(tps_signature)
average_len_puddle=average_len_signature_per_sub(puddle_signature)

var_len_dibs=variance_len_signature_per_sub(dibs_signature)
var_len_ngrams=variance_len_signature_per_sub(ngrams_signature)
var_len_tps=variance_len_signature_per_sub(tps_signature)
var_len_puddle=variance_len_signature_per_sub(puddle_signature)

set(dibs_signature[0]["ortho"])& set(dibs_signature[1]["ortho"]) & set() & set() & set() & set() & set() & set()