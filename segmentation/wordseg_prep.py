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

# punct, special chars

# TODO once defined write a checker (check the input format is valid
# and, if not, say where and why)

import argparse

from segmentation import utils, argument_groups


@utils.catch_exceptions
def main():
    """Entry point of the 'wordseg-prep' command"""
    # define the commandline parser
    parser = argparse.ArgumentParser(description=__doc__)
    argument_groups.add_input_output(parser)
    argument_groups.add_separators(parser)

    parser.add_argument(
        '-u', '--unit', type=str,
        choices=['phoneme', 'syllable'], default='phoneme',
        help="Representation unit to segment, must be 'phoneme' or 'syllable'")

    # parse the command line arguments
    args = parser.parse_args()

    # open the input and output streams
    streamin, streamout = utils.prepare_streams(args.input, args.output)

    # compute the gold version of the text
    prep = utils.unit_text(
        streamin.readlines(),
        unit=args.unit,
        syll_sep=args.syllable_separator,
        word_sep=args.word_separator)

    # write prepared text, one utterance a line, ending with a newline
    streamout.write('\n'.join(prep) + '\n')


if __name__ == '__main__':
    main()
