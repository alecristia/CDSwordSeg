# -*- coding: utf-8 -*-
"""
extract basic info from Childes corpora
@author: Xuan-Nga Cao
"""

import os
import sys
import re

first_arg = sys.argv[1]
second_arg = sys.argv[2]

def list_cha(input_dir=first_arg):
    file_list = []
    for dirpath, dirs, files in os.walk(input_dir):
        for f in files:
              m_file = re.match("(.*)\.cha$", f)
              if m_file:
                  file_list.append(os.path.join(dirpath, f))
    return file_list
    #return glob.glob(path.join(corpus_dir, '**/*/*.wrd'))


def extract_info(cha_files, out=second_arg):
    outfile = open(out, "w")
    outfile.write('dir path\tfilename\tchild age\t# adults\tadult type\n')
    participant_list = []
    for inp in cha_files:
        infile = open(inp, 'r')
        dirpath = os.path.dirname(inp)
        bname = os.path.basename(inp)
        bname = bname.replace('.cha', '')
        for line in infile:
            line.strip()
            marker_match = re.match("@ID:.*", line)
            if marker_match:
                format_match = re.match("(.*)\|(.*)\|(CHI)\|([0-9;.]+)\|(.*)", line)
                if format_match:
                    child_age = format_match.group(4)
                else:
                    adult_format_match = re.match("(.*)\|\|\|(.*)\|\|\|", line)
                    if adult_format_match:
                        adult_ID = adult_format_match.group(2)
                        participant_list.append(adult_ID)
        outfile.write(dirpath + '\t' + bname + '\t' + str(child_age) + '\t' + str(len(participant_list)) + '\t')
        for i in participant_list:
            outfile.write(i + ';')
        outfile.write('\n')
        participant_list[:] = []

"""
extract info from corpora
"""
cha_files = list_cha()
extract_info(cha_files)
