#!/usr/bin/env python
#
# Copyright  (c) Mark Johnson, 27th July 2012

"""Word segmentation evaluation"""

import argparse
import codecs
import re
import sys

from segmentation import tb, utils, argument_groups


def tree_string(tree, word_rex, ignore_terminal_rex):
    def simplify_terminal(t):
        if len(t) > 0 and t[0] == '\\':
            return t[1:]
        else:
            return t

    def visit(node, wordssofar, segssofar):
        """Does a preorder visit of the nodes in the tree"""
        if tb.is_terminal(node):
            if not ignore_terminal_rex.match(node):
                segssofar.append(simplify_terminal(node))
            return wordssofar, segssofar

        for child in tb.tree_children(node):
            wordssofar, segssofar = visit(child, wordssofar, segssofar)

        if word_rex.match(tb.tree_label(node)):
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
              debug_level=0):
    """Reads data either in tree format or in flat format"""
    if tree_flag:
        words = []
        for line in lines:
            if line.count("lexentry") > 0:
                continue
            trees = tb.string_trees(line)
            trees.insert(0, 'ROOT')
            words.append(
                tree_string(trees, score_cat_rex, ignore_terminal_rex))

            if debug_level >= 1000:
                sys.stderr.write(
                    "# line = %s,\n# words = %s\n" % (line, words[-1]))
    else:
        words = [[w for w in word_split_rex.split(line) if w != '' and
                  not ignore_terminal_rex.match(w)] for line in lines if
                 line.count("lexentry") == 0]

    segments = [''.join(ws) for ws in words]

    if debug_level >= 10000:
        sys.stderr.write("lines[0] = %s\n" % lines[0])
        sys.stderr.write("words[0] = %s\n" % words[0])
        sys.stderr.write("segments[0] = %s\n" % segments[0])

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
        return self.correct/(self.test+1e-100)

    def recall(self):
        return self.correct/(self.gold+1e-100)

    def fscore(self):
        return 2*self.correct/(self.test+self.gold+1e-100)

    def exact_match(self):
        return self.n_exactmatch/(self.n+1e-100)

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


def data_precrec(trainwords, goldwords):
    if len(trainwords) != len(goldwords):
        sys.stderr.write(
            "## ** len(trainwords) = %s, len(goldwords) = %s\n" %
            (len(trainwords), len(goldwords)))
        sys.exit(1)

    pr = PrecRec()
    for t, g in zip(trainwords, goldwords):
        pr.update(t, g)
    return pr


def stringpos_boundarypos(stringpos):
    return [set(left for left, right in line if left > 0)
            for line in stringpos]


def evaluate(args, outputf, trainwords, trainstringpos, goldwords, goldstringpos):
    if args.debug >= 1000:
        for (tw, tsps, gw, gsps) in zip(
                trainwords, trainstringpos, goldwords, goldstringpos):
            sys.stderr.write("Gold: ")
            for l, r in sorted(list(gsps)):
                sys.stderr.write(" %s" % gw[l:r])
            sys.stderr.write("\nTrain:")
            for l, r in sorted(list(tsps)):
                sys.stderr.write(" %s" % tw[l:r])
            sys.stderr.write("\n")

    if goldwords != trainwords:
        sys.stderr.write(
            "## ** gold and train terminal words don't match "
            "(so results are bogus)\n")
        sys.stderr.write(
            "## len(goldwords) = %s, len(trainwords) = %s\n" %
            (len(goldwords), len(trainwords)))

        for i in range(min(len(goldwords), len(trainwords))):
            if goldwords[i] != trainwords[i]:
                sys.stderr.write(
                    "# first difference at goldwords[%s] = %s\n"
                    "# first difference at trainwords[%s] = %s\n" %
                    (i, goldwords[i], i, trainwords[i]))
                break

    pr = str(data_precrec(trainstringpos, goldstringpos))
    outputf.write(pr)

    pr = str(data_precrec(
        stringpos_boundarypos(trainstringpos),
        stringpos_boundarypos(goldstringpos)))

    outputf.write('\t')
    outputf.write(pr)

    if args.extra:
        outputf.write('\t')
        outputf.write(args.extra)

    if args.levelname:
        outputf.write("\t(" + args.levelname + ")")
    outputf.write('\n')
    outputf.flush()


def add_options(parser):
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
        '-w', '--word-split-re', default=r'[ \t]+', metavar='<regexp>',
        help='regex used to split words with non-tree input')

    parser.add_argument(
        '--extra', type=str, metavar='<str>',
        help='suffix to print at end of evaluation line')

    parser.add_argument(
        '-d', '--debug', type=int, default=0,
        help='print debugging information')


@utils.catch_exceptions
def main():
    parser = argparse.ArgumentParser(description=__doc__)
    argument_groups.add_input_output(parser)
    add_options(parser)

    args = parser.parse_args()

    goldf = codecs.open(args.gold, 'rU', 'utf8')
    trainf, outputf = utils.prepare_streams(args.input, args.output)

    if args.debug > 0:
        sys.stderr.write(
            '# score_cat_re = "%s"\n' % args.score_cat_re
            + '# ignore_terminal_re = "%s"\n' % args.ignore_terminal_re
            + '# word_split_re = "%s"\n' % args.word_split_re)

    score_cat_rex = re.compile(args.score_cat_re)
    ignore_terminal_rex = re.compile(args.ignore_terminal_re)
    word_split_rex = re.compile(args.word_split_re)

    goldwords, goldstringpos = read_data(
        [line.strip() for line in goldf],
        tree_flag=args.gold_trees,
        score_cat_rex=score_cat_rex,
        ignore_terminal_rex=ignore_terminal_rex,
        word_split_rex=word_split_rex)

    outputf.write('\t'.join(
        ('token_f-score', 'token_precision', 'token_recall',
         'boundary_f-score', 'boundary_precision', 'boundary_recall'))
                  + '\n')
    outputf.flush()

    trainlines = []
    for trainline in trainf:
        trainline = trainline.strip()
        if trainline != "":
            trainlines.append(trainline)
            continue

        trainwords, trainstringpos = read_data(
            trainlines, tree_flag=args.train_trees,
            score_cat_rex=score_cat_rex,
            ignore_terminal_rex=ignore_terminal_rex,
            word_split_rex=word_split_rex,
            debug_level=args.debug)

        evaluate(
            args, outputf,
            trainwords, trainstringpos,
            goldwords, goldstringpos)

        trainlines = []

    if trainlines != []:
        trainwords, trainstringpos = read_data(
            trainlines, tree_flag=args.train_trees,
            score_cat_rex=score_cat_rex,
            ignore_terminal_rex=ignore_terminal_rex,
            word_split_rex=word_split_rex,
            debug_level=args.debug)

        evaluate(
            args, outputf,
            trainwords, trainstringpos,
            goldwords, goldstringpos)


if __name__ == '__main__':
    main()
