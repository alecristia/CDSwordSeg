#!/usr/bin/env python
#
# Copyright 2017 Alex Cristia, Elin Larsen, Mathieu Bernard
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

"""Prepare an input text for word segmentation

The input text must be in a phonologized from

"""

# TODO define clearly the format of the input (maybe as a formal grammar?)
# utterances -> utterance utterances
# utterance -> words
# words -> word words
# word -> syllables ;eword
# syllables -> syllable syllables
# syllable -> phones ;esyll
# phones -> phone ' ' phones
# phone -> 'p'

import string
import re

from segmentation import utils


log = utils.get_logger('wordseg-prep')

punctuation_re = re.compile('[%s]' % re.escape(string.punctuation))


def format_utterance(utt, word_sep=';eword'):
    """Return `utt` correctly formated for word segmentation

    Raise ValueError if any error is detected on `utt`:
      * not a string
      * empty string
      * found any punctuation
      * not ending with word separator

    """
    # remove begin/end/multiple spaces in the utterance
    utt = re.sub('\s+', ' ', utt.strip())

    # bad format detection
    if not utt or not isinstance(utt, str):
        raise ValueError('not a string')
    if not len(utt):
        raise ValueError('empty string')
    if punctuation_re.match(utt):
        raise ValueError('punctuation found')
    if not utt.endswith(word_sep):
        raise ValueError('not ending with word separator')

    return utt


def prepare_text(
        text, unit='syllable', syll_sep=';esyll', word_sep=';eword'):
    """Return a text prepared for word segmentation from a tagged text

    Remove syllable and word separators from a sequence of tagged
    utterances. Marks boundaries at a unit level defined by `unit`.

    Return the text with separators removed, prepared for segmentation
    at a syllable or phoneme representation level (separated by space)

    `text` (sequence of str) is the input text to process, each
      string in the sequence is an utterance

    :param str unit: the unit representation level, must be 'syllable'
      or 'phoneme'. This put space between syllables or phonemes
      respectively
    :param str syll_sep: syllable separation string in `tags`
    :param str word_sep: word separation string in `tags`
    :return sequence(str):

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


@utils.CatchExceptions
def main():
    """Entry point of the 'wordseg-prep' command"""
    # add a command-specific argument
    def add_arguments(parser):
        parser.add_argument(
            '-u', '--unit', type=str,
            choices=['phoneme', 'syllable'], default='phoneme', help='''
            Output level representation, must be 'phoneme' or 'syllable'.''')

    # command initialization
    streamin, streamout, separator, log, args = utils.prepare_main(
        name='wordseg-gold',
        description=__doc__,
        separator=utils.Separator(False, ';esyll', ';eword'),
        add_arguments=add_arguments)

    # check all the utterances are correctly formatted
    text = (format_utterance(utt) for utt in streamin)

    # prepare the input text for word segmentation
    prep = prepare_text(text, unit=args.unit,
                        syll_sep=separator.syllable,
                        word_sep=separator.word)

    # write prepared text, one utterance a line, ending with a newline
    streamout.write('\n'.join(prep) + '\n')


if __name__ == '__main__':
    main()
