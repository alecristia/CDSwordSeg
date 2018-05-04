#!/usr/bin/env python2

"""Convert a list of unicode chars to syllables

This script is a perl to python simplified transcription of the
original convert-from-unicode-flexible.pl

Copyright 2015 Mathieu Bernard

"""

import argparse
import codecs
import os


def read_lines(filename):
    """Return a list of lines in the file"""
    if not os.path.isfile(filename):
        raise OSError('{} is not a file'.format(filename))
    return codecs.open(filename, 'r', encoding='utf-8').read().splitlines()


class Converter(object):
    def __init__(self, dict_file):
        self._dict = {}

        for line in read_lines(dict_file):
            l = line.split(' ')
            self._dict[l[1]] = l[0]

    def convert(self, syllable):
        try:
            return self._dict[syllable]
        except KeyError:
            raise ValueError(
                '{}: {} is not a valid syllable'.format(__file__, syllable))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('input')
    parser.add_argument('dictionary')
    parser.add_argument('output')
    args = parser.parse_args()

    # load the syllables/unicode converter
    c = Converter(args.dictionary)
    c._dict[' '] = ' '

    with codecs.open(args.output, 'w', encoding='utf-8') as out:
        # convert each syllable of each line
        for line in read_lines(args.input):
            out.write(''.join(c.convert(syl) for syl in line) + '\n')

if __name__ == '__main__':
    main()
