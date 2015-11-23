#!/usr/bin/env python3

"""Convert a list of syllables to unicode mapping

This script is a perl to python simplified transcription of the
original convert-to-unicode-flexible.pl

Copyright 2015 Mathieu Bernard

"""

import argparse

def load_dict(filename):
    res = {}
    for line in open(filename, 'r').read().splitlines():


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('input')
    parser.add_argument('dictionary')
    parser.add_argument('output')
    args = parser.parse_args()

    dictionary = load_dict(args.dictionary)

if __name__ == '__main__':
    main()
