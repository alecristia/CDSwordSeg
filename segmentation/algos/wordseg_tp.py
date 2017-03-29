#!/usr/bin/env python
#
# Copyright 2015 Amanda Saksida <amanda.saksida@gmail.com>, original code
# Copyright 2017 Mathieu Bernard,

"""Transitional Probabilities word segmentation."""

import argparse
import collections
import re

from segmentation import utils, argument_groups


def _threshold_relative(syls, tps):
    """Relative threshold segmentation method"""
    prelast = syls[0]
    last = syls[1]
    syl = syls[2]

    cword = [prelast, last]
    cwords = [cword]  # initialisation
    for _next in syls[3:]:
        # relative threshold condition
        cond = (tps[prelast, last] > tps[last, syl]
                and tps[last, syl] < tps[syl, _next])

        if cond or last == "UB" or syl == "UB":
            cword = []
            cwords.append(cword)

        cword.append(syl)
        prelast = last
        last = syl
        syl = _next

    return cwords


def _absolute_threshold(syls, tps):
    """Absolute threshold segmentation method"""
    last = syls[0]
    last_word = [last]

    tp_mean = sum(tps.values()) / len(tps) if len(tps) != 0 else 0

    cwords = [last_word]
    for syl in syls[1:]:
        if tps[last, syl] <= tp_mean or last == "UB" or syl == "UB":
            last_word = []
            cwords.append(last_word)

        last_word.append(syl)
        last = syl

    return cwords


def segment(text, threshold='relative'):
    """Return a word-segmented version of an input `text`

    :param sequence(str) text: a sequence of lines with syllable
      boundaries marked by spaces and no word boundaries. Each string
      in the sequence corresponds to an utterance in the corpus.

    :param str threshold: type of threshold to use, must be 'relative'
      or 'absolute'.

    Raise ValueError if threshold is not 'relative' or 'absolute'

    Return the corpus with estimated words boundaries, as a sequence(str)

    """
    # raise on invalid threshold type
    if threshold != 'relative' and threshold != 'absolute':
        raise ValueError(
            "invalid threshold, must be 'relative' or 'absolute', it is '{}'"
            .format(threshold))

    # join all the utterances together, seperated by ' UB '
    syls = [syl for syl in ' UB '.join(line.strip() for line in text).split()]

    # dictionary of bigram and its forward transition probability
    # (bigram[0] is the first syllable of the bigram)
    tps = dict(
        (bigram, float(freq) / collections.Counter(syls)[bigram[0]])
        for bigram, freq in collections.Counter(
                zip(syls[0:-1], syls[1:])).items())

    # segment the input given the transition probalities
    cwords = (_threshold_relative(syls, tps) if threshold == 'relative'
              else _absolute_threshold(syls, tps))

    # format the segment text for output (' UB ' -> '\n', remove
    # multiple spaces)
    segtext = ' '.join(''.join(c) for c in cwords)
    return re.sub(' +', ' ', segtext).split(' UB ')


def add_options(parser):
    """Add algorithm specific options to the parser"""
    group = parser.add_argument_group('algorithm parameters')
    group.add_argument(
        '-u', '--unit', type=str,
        choices=['phoneme', 'syllable'], default='phoneme',
        help="Representation unit to segment, must be 'phoneme' or 'syllable'")

    group.add_argument(
        '-t', '--threshold-type', type=str,
        choices=['relative', 'absolute'], default='relative',
        help='''use a relative or absolute threshold on transition
        probabilities. When absolute, the threshold is set to the mean
        transition probability over the input corpus''')


@utils.catch_exceptions
def main():
    # define the commandline parser
    parser = argparse.ArgumentParser(description=__doc__)
    argument_groups.add_input_output(parser)
    argument_groups.add_separators(parser, phone=False)
    add_options(parser)

    # parse the command line arguments
    args = parser.parse_args()

    # open the input and output streams
    streamin, streamout = utils.prepare_streams(args.input, args.output)

    # prepare the text for segmentation
    input_text = utils.unit_text(
        streamin.readlines(),
        unit=args.unit,
        syll_sep=args.syllable_separator,
        word_sep=args.word_separator)

    # segment it and output the result
    segmented_text = segment(input_text, threshold=args.threshold_type)
    streamout.write('\n'.join(segmented_text) + '\n')


if __name__ == '__main__':
    main()
