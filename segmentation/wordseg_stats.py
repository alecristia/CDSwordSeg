#!/usr/bin/env python
#
# Copyright 2017 Elin Larsen, Mathieu Bernard
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

"""Extract statistics about gold or segmented text"""

import argparse
import collections

from segmentation import utils


def top_frequency_tokens(text, n=1000, sep=' '):
    """Return the `n` most common tokens in `text`

    :param sequence(str) text: the input sequence to process, each
      string in the sequence is an utterance
    :param int n: the most common tokens to return
    :param str sep: tokens separation string in `text`
    :return list((token, count)): the `n` most common tokens in text
      and their occurence count

    """
    return collections.Counter(
        word for line in text for word
        in line.strip().split(sep)).most_common(n)


@utils.CatchExceptions
def main():
    """Entry point of the 'wordseg-prep' command"""
    # initiliaze the command
    # command initialization
    streamin, streamout, separator, log, args = utils.prepare_main(
        name='wordseg-stats',
        description=__doc__,
        separator=utils.Separator(False, False, ' '))

    top = top_frequency_tokens(streamin)
    streamout.write(
        '{} top frequency tokens:\n'.format(len(top))
        + '\n'.join('{} {}'.format(t[0], t[1]) for t in top)
        + '\n')


if __name__ == '__main__':
    main()
