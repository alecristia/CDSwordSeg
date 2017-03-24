#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Created on Thu Feb 23 19:00:05 2017

@author: elinlarsen
"""

import os
import argparse

def create_input_file(unit_input, res_folder, path_tags):
    '''
    unity_input= string  'phoneme' or 'syllable'
    res_folder is the absolute path of the folder where results are put
    path_tags is the folder containing the tags file
    '''
    
    try : 
        unit_input=='phoneme' or unit_input=='syllable'
    except ValueError : 
        print('unity_input has to be either a string phoneme or syllable')
    
    with open(path_tags,'r') as f:
        filedata = f.read()
        if unit_input=='phoneme': 
            filedata = filedata.replace(';esyll', '') # to join phonemes between ';esyll' if the unity of input wanted is syllable
            filedata = filedata.replace(';eword', '')
            filedata = filedata.replace('  ', ' ')
            filedata = filedata.replace('  ', ' ')
        elif unit_input== 'syllable': 
            filedata = filedata.replace(';eword', '')
            filedata = filedata.replace(' ', '')
            filedata = filedata.replace(';esyll', ' ')
        #filedata = filedata.replace('  ', ' ')
        
    #write the input of algo
    directory=res_folder
    if not os.path.exists(directory):
        os.makedirs(directory)
    with open(directory+ '/input.txt', 'w') as file:
        file.write(filedata)
        
        
if __name__=="__main__":
     parser = argparse.ArgumentParser(description='Divide your corpus in k sub corpus linearly.')
     parser.add_argument('-u','--unit_input', help='string  phoneme or syllable ')
     parser.add_argument('-r', '--res_folder', help='absolute path of the folder of results')
     parser.add_argument('-p', '--path_tags', help='the absolute path of your tags file')
     args=parser.parse_args()
     create_input_file(unit_input=args.unit_input, res_folder=args.res_folder, path_tags=args.path_tags)

        
#test 
#tags='/Users/elinlarsen/Documents/puddle_test/Test/tags.txt'
#res='/Users/elinlarsen/Documents/puddle_test/Test/'
#create_input_file('syllable', res, tags)