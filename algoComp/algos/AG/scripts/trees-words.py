
usage = """%prog -- map py-cfg parse trees to words

Version of 17th August, 2010

(c) Mark Johnson

usage: %prog [options]

"""

import lx, tb
import optparse, re, sys

def tree_string(tree):

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
    return ' '.join(wordssofar)
    
def read_write(inf, outf=sys.stdout, nskip=0):
    "Reads data from inf in tree format"
    for line in inf:
        line = line.strip()
        if len(line) > 0:
            if nskip <= 0:
                trees = tb.string_trees(line)
                trees.insert(0, 'ROOT')
                outf.write(tree_string(trees).strip())
                outf.write('\n')
        else:
            if nskip <= 0:
                outf.write('\n')
                outf.flush()
            nskip -= 1
        trees = tb.string_trees(line)
        trees.insert(0, 'ROOT')

if __name__ == '__main__':
    parser = optparse.OptionParser(usage=usage)
    parser.add_option("-n", "--nepochs", type="int", dest="nepochs", default=0, help="total number of epochs")
    parser.add_option("-s", "--skip", type="float", dest="skip", default=0, help="initial fraction of epochs to skip")
    parser.add_option("-r", "--rate", type="int", dest="rate", default=1, help="input provides samples every rate epochs")
    parser.add_option("-c", "--score-cat-re", dest="score_cat_re", default=r"Word\b",
                      help="score categories in tree input that match this regex")
    parser.add_option("-i", "--ignore-terminal-re", dest="ignore_terminal_re", default=r"^[$]{3}$",
                      help="ignore terminals that match this regex")
    (options,args) = parser.parse_args()
    word_rex = re.compile(options.score_cat_re)
    ignore_terminal_rex = re.compile(options.ignore_terminal_re)
    assert(len(args) <= 2)
    inf = sys.stdin
    outf = sys.stdout
    if len(args) >= 1:
        inf = file(args[0], "rU")
        if len(args) >= 2:
            outf = file(args[1], "w")
    nskip = int(options.skip*options.nepochs/options.rate)
    read_write(inf, outf, nskip)
