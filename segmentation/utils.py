# Copyright 2017 Mathieu Bernard
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

"""Provide utility functions to the wordseg package"""

import codecs
import collections
import itertools
import pkg_resources
import re
import sys


class catch_exceptions(object):
    """A decorator wrapping 'function' in a try/except block

    When an exception occurs, display a user friendly message before
    exiting with error code 1.

    """
    def __init__(self, function):
        self.function = function

    @staticmethod
    def _exit(msg):
        """Write `msg` on stderr and exit with 1"""
        sys.stderr.write(msg + '\n')
        sys.exit(1)

    def __call__(self):
        try:
            self.function()

        except (ValueError, OSError, RuntimeError, AssertionError) as err:
            self._exit('fatal error: {}'.format(err))

        except pkg_resources.DistributionNotFound:
            self._exit(
                'fatal error: wordseg package not found\n'
                'please install wordseg on your platform')

        except KeyboardInterrupt:
            self._exit('keyboard interruption, exiting')


def prepare_streams(input=sys.stdin, output=sys.stdout):
    """Open input and output streams from files or standart output

    Return a pair (streamin, streamout) that can be accessed through
    streamin.read()/readlines() and streamout.write() respectively.

    If `input` and `output` are strings, they are opened as regular
    files for reading/writing.

    """
    # configure input as a readable stream
    streamin = input
    if isinstance(streamin, str):
        streamin = codecs.open(streamin, 'r', 'utf8')

    # configure output as a writable stream
    streamout = output
    if isinstance(streamout, str):
        streamout = codecs.open(streamout, 'w', 'utf8')

    return streamin, streamout


def unit_text(
        text, unit='syllable', syll_sep=';esyll', word_sep=';eword'):
    """Return a text prepared for word segmentation from a tagged text

    Remove syllable and word separators from a sequence of tagged
    utterances. Marks boundaries at a unit level defined by `unit`.
    The returned text is ready to be fed as input of word segmentation
    algorithms.

    :param sequence(str) text: the input text data to process,
      each string in the sequence is an utterance
    :param str unit: the unit representation level, must be 'syllable'
      or 'phoneme'. This put space between syllables or phonemes
      respectively
    :param str syll_sep: syllable separation string in `tags`
    :param str word_sep: word separation string in `tags`
    :return sequence(str): text with separators removed, prepared for
      segmentation at a syllable or phoneme representation level

    """
    # raise an error if unit is not valid
    if unit != 'phoneme' and unit != 'syllable':
        raise ValueError(
            "unit must be 'phoneme' or 'syllable', it is '{}'".format(unit))

    if unit == 'phoneme':
        def func(line):
            return line.replace(syll_sep, '')\
                       .replace(word_sep, '')
    else:  # syllable
        def func(line):
            return line.replace(word_sep, '')\
                       .replace(' ', '')\
                       .replace(syll_sep, ' ')

    return (re.sub(' +', ' ', func(line).strip()) for line in text)


def gold_text(text, syll_sep=';esyll', word_sep=';eword'):
    """Return a gold text from a phonologized one

    Remove syllable and word separators from a sequence of tagged
    utterances. The returned text is the gold version, against which
    the algorithms are evaluated.

    :param sequence(str) text: the input sequence to process, each
      string in the sequence is an utterance
    :param str syll_sep: syllable separation string in `tags`
    :param str word_sep: word separation string in `tags`
    :return sequence(str): text with separators removed, with word
      separated by spaces

    """
    # delete syllable and word separators
    gold = (line.replace(syll_sep, '').replace(' ', '').replace(word_sep, ' ')
            for line in text)

    # delete any duplicate, begin or end spaces
    return (re.sub(' +', ' ', g).strip() for g in gold)


def top_frequency_units(text, n=10000, sep=' '):
    # t = itertools.chain(line.split(sep) for line in text)

    # TODO translate that from bash to Python
    # cat $text | tr ' ' '\n' |
    # sort | uniq -c | awk '{print $1" "$2}' | sort -n -r |
    # head -n 10000 > $RESFOLDER/freq-top.txt
    return [('', 0)]
