#!/usr/bin/env python
#
# Copyright 2015 Amanda Saksida <amanda.saksida@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

"""Transitional Probabilities word segmentation"""

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
    parser.add_argument(
        '-t', '--threshold-type', type=str,
        choices=['relative', 'absolute'], default='relative',
        help='''use a relative or absolute threshold on transition
        probabilities. When absolute, the threshold is set to the mean
        transition probability over the input corpus''')


@utils.catch_exceptions
def main():
    """Entry point of the 'wordseg-tp' command"""
    # define the commandline parser
    parser = argparse.ArgumentParser(description=__doc__)
    argument_groups.add_input_output(parser)
    argument_groups.add_separators(parser, phone=False)
    add_options(parser)

    # parse the command line arguments
    args = parser.parse_args()

    # open the input and output streams
    streamin, streamout = utils.prepare_streams(args.input, args.output)

    # segment it and output the result
    segmented_text = segment(
        streamin.readlines(),
        threshold=args.threshold_type)
    streamout.write('\n'.join(segmented_text) + '\n')


if __name__ == '__main__':
    main()
