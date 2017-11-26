#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Wed Jul  5 19:56:51 2017

@author: elinlarsen
"""

import os 
from os import listdir
from os.path import isfile, join
import csv
import speechcoco.speechcoco as sp
import amdtk # lucas' library that open htk file

path_mfcc=""
path_output=""

def from_htk_file_to_hdf5(path_mfcc, path_output, extension_file):

    files = [f for f in listdir(path_mfcc) if isfile(join(path_mfcc, f))]

    for f in files: 
        mfcc_array=amdtk.read_htk(f)
        

