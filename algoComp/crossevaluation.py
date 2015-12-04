#!/usr/bin/env python
"""This script is used for cross-evaluation of iterative algos in CDSwordSeg.

From bash, this script must be used in this general framework:

.. codeblock:: bash

    ./crossevaluation.py fold input.txt
    for FOLD in input-fold*.txt
    do
      # do your computation on each fold here
      # here we just rename input to output
      cp $FOLD ${FOLD/input/output}
    done
    ./crossevaluation.py unfold output-fold*.txt --index input-index.txt

See test/crossevaluation-exemple.sh for a working exemple.

Exit 0 on normal operation. Exit 1 and print an error message on
stdout if anything goes wrong.

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
    >>> l = permute(l)
    >>> l
    [4, 0, 1, 2, 3]
    >>> l = permute(l)
    >>> l
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
    """Create `nfolds` versions of input `lines`.

    `lines` is list of strings to be folded, `nfolds` is the number of
    folds to create.

    This function first divides `lines` in `nfolds` blocks. From these
    blocks, it then reorder these blocks to form folds. In order to
    serve the unfold operation, this functions also build the index of
    the beginning of the last block in each fold. Returns a tuple
    (index, folds), where index is a list of int and folds a list of
    equal length lists.

    >>> fold([1, 2, 3], 3)     # Each group have 1 element
    ([2, 2, 2], [[1, 2, 3], [3, 1, 2], [2, 3, 1]])
    >>> fold([1, 2, 3, 4], 3)  # Here the last group is [3, 4]
    ([2, 3, 3], [[1, 2, 3, 4], [3, 4, 1, 2], [2, 3, 4, 1]])

    """
    if len(lines) < nfolds:
        raise ValueError('Not enought lines to make {} folds'.format(nfolds))

    # split the input in `nfolds` blocks of equal size...
    size = len(lines)/nfolds
    blocks = [lines[i*size:(i+1)*size] for i in range(nfolds-1)]
    # ...excepted the last block that can be longer
    blocks.append(lines[(nfolds-1)*size:])

    # build the folds from the blocks and store index of the last
    # block in each fold
    folds = []
    index = []
    idx = range(nfolds)
    for i in range(nfolds):
        folds += [flatten([blocks[idx[j]] for j in range(nfolds)])]
        index += [np.cumsum([len(blocks[idx[j]]) for j in range(nfolds)])[-2]]
        idx = permute(idx)

    return index, folds


def main_fold():
    # specify and parse input arguments
    parser = argparse.ArgumentParser(
        prog=sys.argv[0] + ' fold',
        description='Create folded versions of an input file')
    parser.add_argument('file', type=str,
                        help='input text file')
    parser.add_argument('-n', '--nfolds', type=int, default=5,
                        help='number of folds to create, default is 5')
    parser.add_argument('-v', '--verbose', action='store_true',
                        help='increase verbosity')
    args = parser.parse_args()

    # compute the folds
    if args.verbose:
        print('Folding {}'.format(args.file))
    lines = open(args.file, 'r').readlines()
    lasts, folds = fold(lines, args.nfolds)

    # write each fold to an output file and the index file
    base, ext = os.path.splitext(args.file)
    index = ''
    for i, indiced_fold in enumerate(zip(lasts, folds)):
        index += str(indiced_fold[0]) + ' '
        outfile = base + '-fold{}'.format(i) + ext
        open(outfile, 'w').write(''.join(indiced_fold[1]))
        if args.verbose:
            print('Write {}'.format(outfile))

    # write the index file
    indexfile = base + '-index' + ext
    open(indexfile, 'w').write(str(len(lines)) + ' ' + index[:-1] + '\n')
    if args.verbose:
        print('Write {}'.format(indexfile))


def main_unfold():
    # specify and parse input arguments
    parser = argparse.ArgumentParser(
        prog=sys.argv[0] + ' unfold',
        description='Concatenate last blocks of each input file')
    parser.add_argument('files', type=str, nargs='+',
                        help='folded files to concatenate')
    parser.add_argument('-i', '--index', type=str, required=True,
                        help='the index file generated during the fold step')
    parser.add_argument('-o', '--output', type=str, default=None,
                        help='the output file to write')
    parser.add_argument('-v', '--verbose', action='store_true',
                        help='increase verbosity')
    args = parser.parse_args()

    # load the index as a list of ints
    if args.verbose:
        print('Unfolding from {}'.format(args.index))
    index = [int(s) for s in open(args.index, 'r').read().strip().split(' ')]
    length = index[0]
    index = index[1:]

    # load the last block of each input files from the index
    last_blocks = []
    for i, f in enumerate(sorted(args.files)):
        # TODO Optimize, no need to load entire files, tail is enought
        lines = open(f, 'r').readlines()
        if not len(lines) == length:
            raise ValueError('{} must have {} lines but have {}'
                             .format(f, length, len(lines)))
        last_blocks += [lines[index[i]:]]
        if args.verbose:
            print('Read {}'.format(f))

    # get output file name
    if args.output is None:
        # guess name of the output file from basename
        base, ext = os.path.splitext(args.files[0])
        fileout = base[:base.find('-fold')] + '-unfolded' + ext
    else:
        fileout = args.output

    # collapse the last blocks to form the unfolded data
    unfolded = flatten(last_blocks[::-1])
    if not len(unfolded) == length:
        raise ValueError('Unfolded data have {} lines but {} expected'
                         .format(len(unfolded), length))

    # write results to the output file
    open(fileout, 'w').write(''.join(unfolded))


def main():
    """Entry point of the script when used in command-line.

    Consume the first argument, which must be 'fold' or 'unfold', and
    call main_fold() or main_unfold().

    """
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
        print('Error in crossevaluation.py {} : {}'.format(arg, err))
        exit(1)

if __name__ == '__main__':
    main()
