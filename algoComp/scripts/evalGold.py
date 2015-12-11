#!/usr/bin/python

usage = """%prog -- evaluate word segmentation

  (c) Mark Johnson, 27th July 2012

usage: %prog [options]

"""

import optparse
import tb
import re
import sys


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
            return wordssofar,segssofar
        for child in tb.tree_children(node):
            wordssofar,segssofar = visit(child, wordssofar, segssofar)
        if word_rex.match(tb.tree_label(node)):
            if segssofar != []:
                wordssofar.append(''.join(segssofar))
                segssofar = []
        return wordssofar,segssofar

    wordssofar,segssofar = visit(tree, [], [])
    # assert(segssofar == [])
    if segssofar:           # append any unattached segments as a word
        wordssofar.append(''.join(segssofar))
    return wordssofar

def words_stringpos(ws):
    stringpos = set()
    left = 0
    for w in ws:
        right = left+len(w)
        stringpos.add((left,right))
        left = right
    return stringpos

def read_data(lines, tree_flag, score_cat_rex=None,
              ignore_terminal_rex=None, word_split_rex=None,
              debug_level=0):
    "Reads data either in tree format or in flat format"

    if tree_flag:
        words = []
        for line in lines:
            if line.count("lexentry")>0:
                continue
            trees = tb.string_trees(line)
            trees.insert(0, 'ROOT')
            words.append(tree_string(trees, score_cat_rex, ignore_terminal_rex))
            if debug_level >= 1000:
                sys.stderr.write("# line = %s,\n# words = %s\n"%(line, words[-1]))
    else:
        words = [[w for w in word_split_rex.split(line) if w != '' and
                  not ignore_terminal_rex.match(w)] for line in lines if
                 line.count("lexentry") == 0]

    segments = [''.join(ws) for ws in words]
    if debug_level >= 10000:
        sys.stderr.write("lines[0] = %s\n"%lines[0])
        sys.stderr.write("words[0] = %s\n"%words[0])
        sys.stderr.write("segments[0] = %s\n"%segments[0])
    stringpos = [words_stringpos(ws) for ws in words]
    return (segments,stringpos)

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
    # def __str__(self):
    #    return ("%.4g\t%.4g\t%.4g\t%.4g" % (self.fscore(), self.precision(), self.recall(), self.exact_match()))
    def __str__(self):
        return ("%.4g\t%.4g\t%.4g" % (self.fscore(), self.precision(), self.recall()))

def data_precrec(trainwords, goldwords):
    if len(trainwords) != len(goldwords):
        sys.stderr.write("## ** len(trainwords) = %s, len(goldwords) = %s\n" % (len(trainwords), len(goldwords)))
        sys.exit(1)
    pr = PrecRec()
    for (t,g) in zip(trainwords, goldwords):
        pr.update(t, g)
    return pr

def stringpos_boundarypos(stringpos):
    return [set(left for left,right in line
                if left > 0)
            for line in stringpos]

def evaluate(options, trainwords, trainstringpos, goldwords, goldstringpos):

    if options.debug >= 1000:
        for (tw, tsps, gw, gsps) in zip(trainwords, trainstringpos, goldwords, goldstringpos):
            sys.stderr.write("Gold: ")
            for l,r in sorted(list(gsps)):
                sys.stderr.write(" %s"%gw[l:r])
            sys.stderr.write("\nTrain:")
            for l,r in sorted(list(tsps)):
                sys.stderr.write(" %s"%tw[l:r])
            sys.stderr.write("\n")

    if goldwords != trainwords:
        sys.stderr.write("## ** gold and train terminal words don't match (so results are bogus)\n")
        sys.stderr.write("## len(goldwords) = %s, len(trainwords) = %s\n" % (len(goldwords), len(trainwords)))
        for i in range(min(len(goldwords), len(trainwords))):
            if goldwords[i] != trainwords[i]:
                sys.stderr.write("# first difference at goldwords[%s] = %s\n# first difference at trainwords[%s] = %s\n"%
                                 (i,goldwords[i],i,trainwords[i]))
                break

    pr = str(data_precrec(trainstringpos, goldstringpos))
    sys.stdout.write(pr)

    pr = str(data_precrec(stringpos_boundarypos(trainstringpos),
                          stringpos_boundarypos(goldstringpos)))
    sys.stdout.write('\t')
    sys.stdout.write(pr)

    if options.extra:
        sys.stdout.write('\t')
        sys.stdout.write(options.extra)

    if options.levelname:
        sys.stdout.write("\t(" + options.levelname + ")")
    sys.stdout.write('\n')
    sys.stdout.flush()


def main():
    parser = optparse.OptionParser(usage=usage)
    parser.add_option("-n", "--name", dest="levelname", help="name of the adaptor being evaluated")
    parser.add_option("-g", "--gold", dest="goldfile", help="gold file")
    parser.add_option("-t", "--train", dest="trainfile", help="train file")
    parser.add_option("--gold-trees", dest="goldtree_flag", default=False,
                      action="store_true", help="gold data is in tree format")
    parser.add_option("--train-trees", dest="traintree_flag", default=False,
                      action="store_true", help="train data is in tree format")
    parser.add_option("-c", "--score-cat-re", dest="score_cat_re", default=r"^Word$",
                      help="score categories in tree input that match this regex")
    parser.add_option("-i", "--ignore-terminal-re", dest="ignore_terminal_re", default=r"^[$]{3}$",
                      help="ignore terminals that match this regex")
    parser.add_option("-w", "--word-split-re", dest="word_split_re", default=r"[ \t]+",
                      help="regex used to split words with non-tree input")
    parser.add_option("--extra", dest="extra", help="suffix to print at end of evaluation line")
    parser.add_option("-d", "--debug", dest="debug", help="print debugging information", default=0, type="int")
    (options,args) = parser.parse_args()

    if options.goldfile == options.trainfile:
        sys.stderr.write("## ** gold and train both read from same source\n")
        sys.exit(2)
    if options.goldfile:
        goldf = open(options.goldfile, "rU")
    else:
        goldf = sys.stdin
    if options.trainfile:
        trainf = open(options.trainfile, "rU")
    else:
        trainf = sys.stdin

    if options.debug > 0:
        sys.stderr.write('# score_cat_re = "%s"\n# ignore_terminal_re = "%s"\n# word_split_re = "%s"\n'
                         %(options.score_cat_re, options.ignore_terminal_re, options.word_split_re))

    score_cat_rex = re.compile(options.score_cat_re)
    ignore_terminal_rex = re.compile(options.ignore_terminal_re)
    word_split_rex = re.compile(options.word_split_re)

    (goldwords,goldstringpos) = read_data([line.strip() for line in goldf],
                                          tree_flag=options.goldtree_flag,
                                          score_cat_rex=score_cat_rex,
                                          ignore_terminal_rex=ignore_terminal_rex,
                                          word_split_rex=word_split_rex)

    # print PrecRecHeader
    sys.stdout.write("token_f-score\ttoken_precision\ttoken_recall\tboundary_f-score\tboundary_precision\tboundary_recall\n");
    sys.stdout.flush()

    trainlines = []
    for trainline in trainf:
        trainline = trainline.strip()
        if trainline != "":
            trainlines.append(trainline)
            continue

        (trainwords,trainstringpos) = read_data(trainlines, tree_flag=options.traintree_flag,
                                                score_cat_rex=score_cat_rex,
                                                ignore_terminal_rex=ignore_terminal_rex,
                                                word_split_rex=word_split_rex,
                                                debug_level=options.debug)
        evaluate(options, trainwords, trainstringpos, goldwords, goldstringpos)
        trainlines = []

    if trainlines != []:
        (trainwords,trainstringpos) = read_data(trainlines, tree_flag=options.traintree_flag,
                                                score_cat_rex=score_cat_rex,
                                                ignore_terminal_rex=ignore_terminal_rex,
                                                word_split_rex=word_split_rex,
                                                debug_level=options.debug)
        evaluate(options, trainwords, trainstringpos, goldwords, goldstringpos)


if __name__ == '__main__':
    try:
        main()
    except Exception as err:
        print >> sys.stderr, 'Error in {}: {}'.format(__file__, err)
        exit(1)
    except:
        print >> sys.stderr, 'Error in {}'.format(__file__)
        exit(1)
