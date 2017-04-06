#!/usr/bin/env python
#
# Copyright 2017 Elin Larsen
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

"""Puddle word segmentation algorithm

'Translation' of the puddle philosophy developped by P. Monaghan in a
python language Monaghan, P., & Christiansen, M. H. (2010). Words in
puddles of sound: modelling psycholinguistic effects in speech
segmentation. Journal of child language, 37(03), 545-564.

The fonction update_line is a function that takes as input a list of
phonemes (ie character separated by space) defining all together an
utterance

Invariant : each time the lexicon is updated, we are segmenting
(printing on the text file)

"""

from collections import Counter
from segmentation import utils


lexicon = Counter()
beginning = Counter()
ending = Counter()


def filter_by_frequency(phonemes, i, j):
    all_candidates = []
    for k in range(j, len(phonemes)):
        try:
            all_candidates.append((k, lexicon[''.join(phonemes[i:k+1])]))
        except KeyError:
            pass

    j, _ = sorted(all_candidates, key=lambda x: x[1])[-1]

    return j


def filter_by_boundary_condition(phonemes, i, j, found, window):
    if found:
        previous_biphone = ''.join(phonemes[i - window:i])
        # previous must be word-end
        if i != 0 and previous_biphone not in ending:
            return False

        following_biphone = ''.join(phonemes[j + 1:j + 1 + window])
        if len(phonemes) != j - i and following_biphone not in beginning:
            return False

        return True


def update_counters(segmented, phonemes, i, j, window,
                    log=utils.null_logger()):
    lexicon.update([''.join(phonemes[i:j+1])])
    segmented.append(''.join(phonemes[i:j+1]))

    if len(phonemes[i:j+1]) == len(phonemes):
        log.debug('Utterance %s added in lexicon', ''.join(phonemes[i:j+1]))
    else:
        log.debug('Match %s added in lexicon', ''.join(phonemes[i:j+1]))

    if len(phonemes[i:j+1]) >= 2:
        beginning.update([''.join(phonemes[i:i+window])])
        ending.update([''.join(phonemes[j+1-window:j+1])])
        log.debug(
            'Bi-phonemes %s added in beginning',
            ''.join(phonemes[i:i+window]))
        log.debug(
            'Bi-phonemes %s added in ending',
            ''.join(phonemes[j+1-window:j+1]))

    return segmented


def update_line(phonemes, window, log=utils.null_logger(), segmented=[]):
    # check if the list of phonemes is not null
    if not len(phonemes):
        raise NotImplementedError

    found = False

    # index of start of word candidate
    i = 0
    while i < len(phonemes):
        j = i
        while j < len(phonemes):
            candidate_word = ''.join(phonemes[i:j+1])
            log.debug('word candidate: %s', candidate_word)

            if candidate_word in lexicon:
                found = True

                # j=filter_by_frequency(phonemes,i,j) # choose the
                # best candidate by looking at the frequency of
                # different candidates

                # check if the boundary conditions are respected
                found = filter_by_boundary_condition(
                    phonemes, i, j, found, window)

                if found:
                    log.info('match found : %s', candidate_word)
                    if i != 0:
                        # add the word preceding the word found in
                        # lexicon; update beginning and ending
                        # counters and segment
                        segmented = update_counters(
                            segmented, phonemes, 0, i-1, window, log=log)

                    # update the lexicon, beginning and ending counters
                    segmented = update_counters(
                        segmented, phonemes, i, j, window, log=log)

                    if j != len(phonemes) - 1:
                        # recursion
                        return update_line(
                            phonemes[j+1:], window,
                            log=log, segmented=segmented)

                    # go to the next chunk and apply the same condition
                    log.info('go to next chunk : %s ', phonemes[j+1:])
                    break

                else:
                    j += 1
            else:
                j += 1

        i += 1  # or go to the next phoneme

    if not found:
        update_counters(segmented, phonemes, 0, len(phonemes) - 1, window)

    return segmented


def segment(text, window=2, log=utils.null_logger()):
    # TODO docstring
    for line in text:
        segmented_line = update_line(
            line.strip().split(), window=window, log=log, segmented=[])

        yield ' '.join(segmented_line)


def add_arguments(parser):
    """Add algorithm specific options to the parser"""
    parser.add_argument(
       '-w', '--window', type=int, default=2, help='''
       Number of phonemes to be taken into account for boundary constraint,
       default is %(default)s.''')

    # parser.add_argument(
    #     '-d', '--decay', action='store_true',
    #     help='Decrease the size of lexicon, modelize memory of lexicon.')


@utils.CatchExceptions
def main():
    """Entry point of the 'wordseg-puddle' command"""
    streamin, streamout, _, log, args = utils.prepare_main(
        name='wordseg-puddle',
        description=__doc__,
        add_arguments=add_arguments)

    segmented = segment(streamin, window=args.window, log=log)
    streamout.write('\n'.join(segmented) + '\n')


if __name__ == '__main__':
    main()
