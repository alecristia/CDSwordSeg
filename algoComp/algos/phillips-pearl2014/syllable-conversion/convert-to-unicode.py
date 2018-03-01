#!/usr/bin/env python2

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


    def convert_word(self, word, sylsep=';esyll'):
        res = ''
        # for each syllable
        for syl in word.split(sylsep):
            phon = ''.join(syl.split(' '))
            # convert the syllable to unicode
            if not phon in ['']:
                res += self.convert_syl(phon)
        return res


    def convert_syl(self, syllable):
        try:
            return self._dict[syllable]
        except KeyError:
            raise ValueError(
                '{}: {} is not a valid syllable'.format(__file__, syllable))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('input', type=str,
                        help='input tags file. Words separated by ;eword.'
                        ' Syllables separated by ;esyll')
    parser.add_argument('dictionary', type=str,
                        help='output syllable/unicode dictionary file')
    parser.add_argument('output', type=str,
                        help='output converted file')
    args = parser.parse_args()

    # load the syllables/unicode converter
    c = Converter(args.dictionary)

    with codecs.open(args.output, 'w', encoding='utf-8') as out:
        # for each utterance
        for line in readlines(args.input):
            # for each word
            res = ' '.join([c.convert_word(w) for w in line.split(';eword')])
            out.write(res.strip() + '\n')


if __name__ == '__main__':
    main()
