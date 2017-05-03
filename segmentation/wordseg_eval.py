#!/usr/bin/env python
#
# Copyright 2012 Mark Johnson
# Copyright 2017 Mathieu Bernard, Elin Larsen
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

"""Word segmentation evaluation"""

import codecs
import collections

from segmentation import utils, Separator


DEFAULT_SEPARATOR = Separator(None, None, ' ')


class PrecRec:
    def __init__(self):
        self.test = 0
        self.gold = 0
        self.correct = 0
        self.n = 0
        self.n_exactmatch = 0

    def precision(self):
        return self.correct / (self.test + 1e-100)

    def recall(self):
        return self.correct / (self.gold + 1e-100)

    def fscore(self):
        return 2 * self.correct / (self.test + self.gold + 1e-100)

    def exact_match(self):
        return self.n_exactmatch / (self.n + 1e-100)

    def update(self, testset, goldset):
        self.n += 1
        if testset == goldset:
            self.n_exactmatch += 1
        self.test += len(testset)
        self.gold += len(goldset)
        self.correct += len(testset & goldset)

    def __str__(self):
        return ("%.4g\t%.4g\t%.4g" % (
            self.fscore(), self.precision(), self.recall()))


def words_stringpos(ws):
    stringpos = set()
    left = 0
    for w in ws:
        right = left + len(w)
        stringpos.add((left, right))
        left = right
    return stringpos


# TODO yield (segment, stringpos) here
def read_data(text, separator):
    words = [list(separator.split(line.strip(), level='word'))
             for line in text]

    segments = [''.join(ws) for ws in words]
    stringpos = [words_stringpos(ws) for ws in words]
    return segments, stringpos


def data_precrec(train_words, gold_words):
    if len(train_words) != len(gold_words):
        raise ValueError(
            '#words different in train and gold: {} != {}'
            .format(len(train_words), len(gold_words)))

    pr = PrecRec()
    for t, g in zip(train_words, gold_words):
        pr.update(t, g)
    return pr


def stringpos_boundarypos(stringpos):
    return [set(left for left, right in line if left > 0)
            for line in stringpos]


# TODO a bug here: must return the same size for train and gold...
def stringpos_typepos(stringpos):
    dic_type = collections.Counter()
    for line in stringpos:
        for word in line:
            dic_type.update(word)  # build a dictionnary of vocabulary
    return dic_type.keys()


def evaluate(train, gold, separator=DEFAULT_SEPARATOR,
             log=utils.null_logger()):
    gold_words, gold_stringpos = read_data(gold, separator)
    train_words, train_stringpos = read_data(train, separator)

    if gold_words != train_words:
        log.error(
            'gold and train terminal words don\'t match'
            ': len(goldwords) = %s, len(trainwords) = %s',
            len(gold_words), len(train_words))

        for i in range(min(len(gold_words), len(train_words))):
            if gold_words[i] != train_words[i]:
                log.error("first difference at line %s", i)
                log.error('gold:i = "%s"', gold_words[i])
                log.error('train:i = "%s"', train_words[i])
                raise RuntimeError

    # type_eval = data_precrec(
    #     stringpos_typepos(train_stringpos),
    #     stringpos_typepos(gold_stringpos))

    token_eval = data_precrec(
        train_stringpos,
        gold_stringpos)

    boundary_eval = data_precrec(
        stringpos_boundarypos(train_stringpos),
        stringpos_boundarypos(gold_stringpos))

    return {
        # 'type_f-score': type_eval.fscore(),
        # 'type_precision': type_eval.precision(),
        # 'type_recall': type_eval.recall(),
        'token_f-score': token_eval.fscore(),
        'token_precision': token_eval.precision(),
        'token_recall': token_eval.recall(),
        'bound_f-score': boundary_eval.fscore(),
        'bound_precision': boundary_eval.precision(),
        'bound_recall': boundary_eval.recall()}


def add_arguments(parser):
    parser.add_argument(
        'gold', metavar='<gold-file>',
        help='gold file to evaluate the input data on')


@utils.CatchExceptions
def main():
    """Entry point if the 'wordseg-eval' command"""
    streamin, streamout, separator, log, args = utils.prepare_main(
        name='wordseg-eval',
        description=__doc__,
        separator=DEFAULT_SEPARATOR,
        add_arguments=add_arguments)

    # load the gold text
    gold = codecs.open(args.gold, 'r', encoding='utf8').readlines()

    # evaluation returns a dict of 'score name' -> float
    results = evaluate(gold, streamin, log=log)

    streamout.write('\n'.join(
        # display scores with 4-digit float precision
        '{}\t{}'.format(k, '%.4g' % v) for k, v in results.items()) + '\n')


if __name__ == '__main__':
    main()
