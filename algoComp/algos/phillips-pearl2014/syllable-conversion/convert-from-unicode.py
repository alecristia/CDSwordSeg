#!/usr/bin/env python3

"""Convert a list of unicode chars to syllables

This script is a perl to python simplified transcription of the
original convert-from-unicode-flexible.pl

Copyright 2015 Mathieu Bernard

"""

import argparse
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

    with open(args.output, 'w') as out:
        # convert each syllable of each line
        for line in read_lines(args.input):
            for syl in line.replace(' ', ''):
                if not syl == '':
                    out.write(c.convert(syl) + ' ')
            out.write('\n')


if __name__ == '__main__':
    main()
