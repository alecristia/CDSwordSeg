#!/usr/bin/env python
#
# Copyright 2012 Mark Johnson
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
#
# April 2017 : 
# Modified by Mathieu Bernard : create parser for arguments and logger
# and byb Elin Larsen : add Type F-score, recall and precision

"""Word segmentation evaluation"""

import codecs
import re
import sys
from collections import Counter

from segmentation import utils


def is_terminal(subtree):
    """True if this subtree consists of a single terminal node
    (i.e., a word or an empty node)."""
    return not isinstance(subtree, list)


def tree_children(tree):
    """Returns a list of the child subtrees of tree."""
    return tree[1:] if isinstance(tree, list) else []


def tree_label(tree):
    """Returns the label on the root node of tree."""
    return tree[0] if isinstance(tree, list) else tree


def string_trees(s):
    """Returns a list of the trees in PTB-format string s"""
    trees = []
    _string_trees(trees, s)
    return trees


def _string_trees(trees, s, pos=0):
    """Reads a sequence of trees in string s[pos:].

    Appends the trees to the argument trees.  Returns the ending
    position of those trees in s.

    """
    _openpar_re = re.compile(r"\s*\(\s*([^ \t\n\r\f\v()]*)\s*")
    _closepar_re = re.compile(r"\s*\)\s*")
    _terminal_re = re.compile(r"\s*((?:[^ \\\t\n\r\f\v()]|\\.)+)\s*")

    while pos < len(s):
        closepar_mo = _closepar_re.match(s, pos)
        if closepar_mo:
            return closepar_mo.end()
        openpar_mo = _openpar_re.match(s, pos)
        if openpar_mo:
            tree = [openpar_mo.group(1)]
            trees.append(tree)
            pos = _string_trees(tree, s, openpar_mo.end())
        else:
            terminal_mo = _terminal_re.match(s, pos)
            trees.append(terminal_mo.group(1))
            pos = terminal_mo.end()
    return pos


def tree_string(tree, word_rex, ignore_terminal_rex):
    def simplify_terminal(t):
        if len(t) > 0 and t[0] == '\\':
            return t[1:]
        else:
            return t

    def visit(node, wordssofar, segssofar):
        """Does a preorder visit of the nodes in the tree"""
        if is_terminal(node):
            if not ignore_terminal_rex.match(node):
                segssofar.append(simplify_terminal(node))
            return wordssofar, segssofar

        for child in tree_children(node):
            wordssofar, segssofar = visit(child, wordssofar, segssofar)

        if word_rex.match(tree_label(node)):
            if segssofar != []:
                wordssofar.append(''.join(segssofar))
                segssofar = []

        return wordssofar, segssofar

    wordssofar, segssofar = visit(tree, [], [])
    # assert(segssofar == [])
    if segssofar:  # append any unattached segments as a word
        wordssofar.append(''.join(segssofar))
    return wordssofar


def words_stringpos(ws):
    stringpos = set()
    left = 0
    for w in ws:
        right = left+len(w)
        stringpos.add((left, right))
        left = right
    return stringpos


def read_data(lines, tree_flag, score_cat_rex=None,
              ignore_terminal_rex=None, word_split_rex=None,
              log=utils.null_logger()):
    """Reads data either in tree format or in flat format"""
    if tree_flag:
        words = []
        for line in lines:
            if line.count("lexentry") > 0:
                continue
            trees = string_trees(line)
            trees.insert(0, 'ROOT')
            words.append(
                tree_string(trees, score_cat_rex, ignore_terminal_rex))

            log.debug('line = %s', line)
            log.debug('words = %s', words[-1])
    else:
        words = [[w for w in word_split_rex.split(line) if w != '' and
                  not ignore_terminal_rex.match(w)] for line in lines if
                 line.count("lexentry") == 0]

    segments = [''.join(ws) for ws in words]

    log.debug('lines[0] = %s', lines[0])
    log.debug('words[0] = %s', words[0])
    log.debug('segments[0] = %s', segments[0])

    stringpos = [words_stringpos(ws) for ws in words]
    return segments, stringpos


PrecRecHeader = "# f-score precision recall exact-match"


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


def data_precrec(trainwords, goldwords, log=utils.null_logger()):
    if len(trainwords) != len(goldwords):
        log.critical('#words different in train and gold: %s != %s',
                     len(trainwords), len(goldwords))
        sys.exit(1)

    pr = PrecRec()
    for t, g in zip(trainwords, goldwords):
        pr.update(t, g)
    return pr


def stringpos_boundarypos(stringpos):
    return [set(left for left, right in line if left > 0)
            for line in stringpos]

def stringpos_typepos(stringpos):
    dic_type=Counter()
    for line in stringpos : 
        for word in line : 
            dic_type.update(word) # build a dictionnary of vocabulary
    return(dic_type.keys())

def evaluate(args, outputf, trainwords, trainstringpos,
             goldwords, goldstringpos, log=utils.null_logger()):
    if log.getEffectiveLevel() <= 10:  # log level is DEBUG or below
        for (tw, tsps, gw, gsps) in zip(
                trainwords, trainstringpos, goldwords, goldstringpos):
            s = "Gold: "
            for l, r in sorted(list(gsps)):
                s += " %s" % gw[l:r]
            log.debug(s)

            s = "Train: "
            for l, r in sorted(list(tsps)):
                s += " %s" % tw[l:r]
                log.debug(s)

    if goldwords != trainwords:
        log.warning(
            "gold and train terminal words don't match (so results are bogus)")
        log.warning(
            "len(goldwords) = %s, len(trainwords) = %s",
            len(goldwords), len(trainwords))

        for i in range(min(len(goldwords), len(trainwords))):
            if goldwords[i] != trainwords[i]:
                log.warning("first difference at goldwords[%s] = %s",
                            i, goldwords[i])
                log.warning("first difference at trainwords[%s] = %s",
                            i, trainwords[i])
                break

    pr = str(data_precrec(
        stringpos_typepos(trainstringpos), 
        stringpos_typepos(goldstringpos), 
        log=log))
    outputf.write(pr)
    
    pr = str(data_precrec(trainstringpos, goldstringpos, log=log))
    outputf.write('\t')
    outputf.write(pr)

    pr = str(data_precrec(
        stringpos_boundarypos(trainstringpos),
        stringpos_boundarypos(goldstringpos),
        log=log))
    outputf.write('\t')
    outputf.write(pr)
    

    if args.extra:
        outputf.write('\t')
        outputf.write(args.extra)

    if args.levelname:
        outputf.write("\t(" + args.levelname + ")")
    outputf.write('\n')
    outputf.flush()


def add_arguments(parser):
    parser.add_argument(
        '-n', '--levelname', help='name of the adaptor being evaluated')

    parser.add_argument(
        '-g', '--gold', required=True, type=str, metavar='<file>',
        help='gold file to evaluate the input data on')

    parser.add_argument(
        '--gold-trees', action='store_true',
        help='gold data is in tree format')

    parser.add_argument(
        '--train-trees', action='store_true',
        help='train data is in tree format')

    parser.add_argument(
        '-c', '--score-cat-re', default=r'^Word$', metavar='<regexp>',
        help='score categories in tree input that match this regex')

    parser.add_argument(
        '-i', '--ignore-terminal-re', default=r'^[$]{3}$', metavar='<regexp>',
        help='ignore terminals that match this regex')

    parser.add_argument(
        '-W', '--word-split-re', default=r'[ \t]+', metavar='<regexp>',
        help='regex used to split words with non-tree input')

    parser.add_argument(
        '--extra', type=str, metavar='<str>',
        help='suffix to print at end of evaluation line')


@utils.CatchExceptions
def main():
    """Entry point if the 'wordseg-eval' command"""
    # command initialization
    trainf, outputf, separator, log, args = utils.prepare_main(
        name='wordseg-eval',
        description=__doc__,
        separator=utils.Separator(False, ';esyll', ';eword'),
        add_arguments=add_arguments)

    log.debug('score_cat_re = "%s"', args.score_cat_re)
    log.debug('ignore_terminal_re = "%s"', args.ignore_terminal_re)
    log.debug('word_split_re = "%s"', args.word_split_re)

    score_cat_rex = re.compile(args.score_cat_re)
    ignore_terminal_rex = re.compile(args.ignore_terminal_re)
    word_split_rex = re.compile(args.word_split_re)

    with codecs.open(args.gold, 'r', encoding='utf8') as goldf:
        goldwords, goldstringpos = read_data(
            [line.strip() for line in goldf],
            tree_flag=args.gold_trees,
            score_cat_rex=score_cat_rex,
            ignore_terminal_rex=ignore_terminal_rex,
            word_split_rex=word_split_rex, log=log)

    outputf.write('\t'.join(
        ('type_f-score', 'type_precision', 'type_recall', 'token_f-score', 'token_precision', 'token_recall',
         'boundary_f-score', 'boundary_precision', 'boundary_recall'))
                  + '\n')
    outputf.flush()

    trainlines = []
    for trainline in trainf:
        trainline = trainline.strip()
        if trainline != '':
            trainlines.append(trainline)
            continue

        trainwords, trainstringpos = read_data(
            trainlines, tree_flag=args.train_trees,
            score_cat_rex=score_cat_rex,
            ignore_terminal_rex=ignore_terminal_rex,
            word_split_rex=word_split_rex, log=log)

        evaluate(
            args, outputf,
            trainwords, trainstringpos,
            goldwords, goldstringpos, log=log)

        trainlines = []

    if trainlines != []:
        trainwords, trainstringpos = read_data(
            trainlines, tree_flag=args.train_trees,
            score_cat_rex=score_cat_rex,
            ignore_terminal_rex=ignore_terminal_rex,
            word_split_rex=word_split_rex, log=log)

        evaluate(
            args, outputf, trainwords, trainstringpos,
            goldwords, goldstringpos, log=log)


if __name__ == '__main__':
    main()
