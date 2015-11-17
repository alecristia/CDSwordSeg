#!/usr/bin/env python3

import os

DIRECTORY = ('/run/user/1000/gvfs/sftp:host=oberon'
             '/fhgfs/bootphon/scratch/xcao/Alex_CDS_ADS/res_Childes_Eng-NA_cds')

def ortholines_files(directory=DIRECTORY):
    """Return a list of ortholines files recusrsively found in `directory`"""
    if not os.path.isdir(directory):
        raise OSError('{} is not a valid directory'.format(dircetory))

    ortholist = []
    for (dir, _, files) in os.walk(directory):
        for f in files:
#            if 'ortholines' in f:
            ortholist += [os.path.join(dir, f)]
    return ortholist
