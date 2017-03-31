#!/usr/bin/env python
#
# Copyright 2015 - 2017 Alex Cristia, Mathieu Bernard
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

"""Build a gold text from a phonologized one

Remove syllable and word separators from a sequence of tagged
utterances. The returned text is the gold version, against which the
algorithms are evaluated.

"""

import argparse

from segmentation import utils, argument_groups


@utils.catch_exceptions
def main():
    """Entry point of the 'wordseg-gold' command"""
    # define the commandline parser
    parser = argparse.ArgumentParser(description=__doc__)
    argument_groups.add_input_output(parser)
    argument_groups.add_separators(parser, phone=False)

    # parse the command line arguments
    args = parser.parse_args()

    # open the input and output streams
    streamin, streamout = utils.prepare_streams(args.input, args.output)

    # compute the gold version of the text
    gold = utils.gold_text(
        streamin.readlines(),
        syll_sep=args.syllable_separator,
        word_sep=args.word_separator)

    # write gold, one utterance per line, add a newline at the end
    streamout.write('\n'.join(gold) + '\n')


if __name__ == '__main__':
    main()
