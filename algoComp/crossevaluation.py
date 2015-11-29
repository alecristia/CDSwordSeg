#!/usr/bin/env python
"""This script is used for cross-evaluation of the iterative algos

Copyright 2015 Mathieu Bernard

"""

import argparse
from itertools import chain
import numpy as np
import os
import sys


def permute(l):
    """Pop the last element of a list an push it at beginning.

    >>> l = range(5)
    [0, 1, 2, 3, 4]
    >>> l = permute(l)
    [4, 0, 1, 2, 3]
    >>> l = permute(l)
    [3, 4, 0, 1, 2]

    """
    return [l[-1]] + l[0:-1]


def flatten(l):
    """Flatten a list of lists in a single list.

    >>> flatten([[0], [1], [2, 3]])
    [0, 1, 2, 3]

    """
    return list(chain(*l))


def fold(lines, nfolds=5):
    # split the input in `nfolds` blocks of equal size...
    size = len(lines)/nfolds
    blocks = [lines[i*size:(i+1)*size] for i in range(nfolds-1)]
    # ...excepted the last block that can be longer
    blocks.append(lines[(nfolds-1)*size:])

    # build the folds from the blocks
    idx = range(nfolds)
    folds = []
    lasts = []
    for i in range(nfolds):
        folds += [flatten([blocks[idx[j]] for j in range(nfolds)])]
        lasts += [np.cumsum([len(blocks[idx[j]]) for j in range(nfolds)])[-2]]
        idx = permute(idx)

    return lasts, folds


def main_fold():
    parser = argparse.ArgumentParser(
        prog=sys.argv[0] + ' fold',
        description='Create folded versions of an input file')

    parser.add_argument('file', type=str,
                        help='input text file')
    parser.add_argument('-n', '--nfolds', type=int, default=5,
                        help='number of folds to create, default is 5')
    args = parser.parse_args()

    # compute the folds
    lines = open(args.file, 'r').readlines()
    lasts, folds = fold(lines, args.nfolds)

    # write each fold to an output file and the index file
    base, ext = os.path.splitext(args.file)
    indexfile = base + '-index' + ext
    with open(indexfile, 'w') as idxf:
        for i, indiced_fold in enumerate(zip(lasts, folds)):
            idxf.write(str(indiced_fold[0]) + ' ')
            outfile = base + '-fold{}'.format(i) + ext
            open(outfile, 'w').write(''.join(indiced_fold[1]))
        idxf.write('\n')


def main_unfold():
    parser = argparse.ArgumentParser(
        prog=sys.argv[0] + ' unfold',
        description='Concatenate last block of each input file')

    # TODO fix this
    parser.add_argument('files', type=str, nargs='+',
                        help='folded files to concatenate, each have file '
                        'must have the same number of lines.\n'
                        'ATTENTION !!!  You must provide the fold files in '
                        'increasing order (i.e. base-fold0.txt base-fold1.txt '
                        '... base-fold$n.txt)')

    parser.add_argument('-i', '--index', type=str, required=True,
                        help='the index file generated during the fold step')

    args = parser.parse_args()

    # load the index as a list of ints
    index = [int(s) for s in open(args.index, 'r').read().strip().split(' ')]

    # open the fold files, load their last blocks
    last_blocks = []
    for i, f in enumerate(args.files):
        lines = open(f, 'r').readlines()
        last_blocks += [lines[index[i]:]]

    # guess name of the output file from basename
    base, ext = os.path.splitext(args.files[0])
    fileout = base[:base.find('-fold')] + '-unfolded' + ext

    with open(fileout, 'w') as f:
        f.write(''.join(flatten(last_blocks[::-1])))


if __name__ == '__main__':
    try:
        arg = sys.argv[1]
        sys.argv = [sys.argv[0]] + sys.argv[2:]
        if arg == 'fold':
            main_fold()
        elif arg == 'unfold':
            main_unfold()
        else:
            print('Please specify fold or unfold.\n'
                  'Type "{} fold --help" or "{} unfold --help".'
                  .format(sys.argv[0], sys.argv[0]))
    except Exception as err:
        print(err)
