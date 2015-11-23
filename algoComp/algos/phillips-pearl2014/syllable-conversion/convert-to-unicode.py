#!/usr/bin/env python3

"""Convert a list of syllables to unicode mapping

This script is a perl to python simplified transcription of the
original convert-to-unicode-flexible.pl

Copyright 2015 Mathieu Bernard

"""

import argparse
<<<<<<< HEAD

def load_dict(filename):
    res = {}
    for line in open(filename, 'r').read().splitlines():
=======
import os


def read_lines(filename):
    """Return a list of lines in the file"""
    if not os.path.isfile(filename):
        raise OSError('{} is not a file'.format(filename))
    return open(filename, 'r').read().splitlines()


class Converter(object):
    def __init__(self, dict_file):
        self._dict = {}

        for line in read_lines(dict_file):
            l = line.split('\t')
            self._dict[l[0]] = l[1]

    def convert(self, syllable):
        try:
            return self._dict[syllable]
        except KeyError:
            raise ValueError(
                '{}: {} is not a valid syllable'.format(__file__, syllable))
>>>>>>> 151ff412db042803afcb6b251b51338975415fa8


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('input')
    parser.add_argument('dictionary')
    parser.add_argument('output')
    args = parser.parse_args()

<<<<<<< HEAD
    dictionary = load_dict(args.dictionary)
=======
    # load the syllables/unicode converter
    c = Converter(args.dictionary)

    with open(args.output, 'w') as out:
        # convert each syllable of each line
        for line in read_lines(args.input):
            for syl in line.split(' '):
                if not syl == '':
                    out.write(c.convert(syl))
            out.write('\n')

>>>>>>> 151ff412db042803afcb6b251b51338975415fa8

if __name__ == '__main__':
    main()
