#!/usr/bin/env python

"""Convert a list of syllables to unicode mapping

This script is a perl to python simplified transcription of the
original convert-to-unicode-flexible.pl

Copyright 2015 Mathieu Bernard

"""

import argparse
import codecs
import os


def readlines(filename):
    """Return a list of lines in the file"""
    if not os.path.isfile(filename):
        raise OSError('{} is not a file'.format(filename))
    return codecs.open(filename, 'r', encoding='utf-8').read().splitlines()


class Converter(object):
    def __init__(self, dict_file):
        self._dict = {}

        for line in readlines(dict_file):
            l = line.split(' ')
            self._dict[l[0]] = l[1]

    def convert(self, syllable):
        try:
            return self._dict[syllable]
        except KeyError:
            raise ValueError(
                '{}: {} is not a valid syllable'.format(__file__, syllable))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('input', type=str,
                        help='input tags file')
    parser.add_argument('dictionary', type=str,
                        help='output syllable/unicode dictionary file')
    parser.add_argument('output', type=str,
                        help='output converted file')
    args = parser.parse_args()

    # load the syllables/unicode converter
    c = Converter(args.dictionary)

    with codecs.open(args.output, 'w', encoding='utf-8') as out:
        # convert each syllable of each line
        for line in readlines(args.input):
            for syl in line.split(' '):
                if not syl == '':
                    out.write(c.convert(syl))
            out.write('\n')


if __name__ == '__main__':
    main()