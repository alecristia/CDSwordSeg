#!/usr/bin/env python

"""Create a unicode mapping of a list of syllables.

This script is a perl to python simplified transcription of the
original create-unicode-dict-flexible.pl

Assumptions on input are:

* on syllable per line
* each syllable appears only once

The output format is:

* one syllable/unicode mapping per line
* line per line mapping of input

Copyright 2015 Mathieu Bernard

"""

import argparse
import codecs

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('input')
    parser.add_argument('output')
    args = parser.parse_args()

    base = 3001
    current = 0

    with codecs.open(args.output, 'w', encoding='utf-8') as out:
        # process input file line per line
        for syl in codecs.open(args.input, 'r', encoding='utf-8').read().splitlines():
            # As in the original script, this ensures the syllable is
            # not encoded as a space (not sure it's really usefull).
            encoded = ' '
            while ' ' in encoded:
                encoded = unichr(base + current)
                current += 1
            out.write(syl + ' ' + encoded + '\n')

if __name__ == '__main__':
    main()
