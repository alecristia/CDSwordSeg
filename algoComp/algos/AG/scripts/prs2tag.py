import re
import argparse
import tb2 as tb
import os


def incr(word, label):
    if not word in label:
        label[word] = 1
    else:
        label[word] += 1


def readparses(inf):
    parses = ""
    for line in inf:
        line = line.strip()
        if len(line) == 0:
            if len(parses) > 0:
                yield parses
                parses = ""
        else:
            parses += line + '\n'
    if len(parses) > 0:
        yield parses


def convert(line):
    pass


def searchTree(l, regex, tree):
    if tb.is_terminal(tree):
        return
    else:
        label = tb.tree_label(tree).split('#')[0]
        if regex.match(label):
            word = ''.join(tb.terminals(tree)).replace("\\", "")
            if label[-1] == '1' or label[-1] == '2' or label[-1] == '3':
                label = label[:-1]
            l.append([(label, word)])
            l = l[-1]
        for subtree in tb.tree_children(tree):
            searchTree(l, regex, subtree)


def searchFiles(regex, files):
    pattern = re.compile(regex)
    data = [parses for f in files for parses in readparses(open(f, "rU"))]
    print len(data)
    for f in data:
        trees = tb.read_string_tree(f)
        for tree in trees:
            l = []
            searchTree(l, pattern, tree)
            print displayList(l)
        print '\n'


def displayList(l):
    res = ""
    for elt in l:
        if type(elt) == tuple:
            res += elt[0] + ":" + elt[1] + " "
        else:
            res += displayList(elt)
    return res


def parse_args():
    parser = argparse.ArgumentParser(
        prog='prs2tag',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description="""tag the words that belong to the syntaxic unit described
        in the regex. tag:word""",
        epilog="""Example usage:
python list_words.py -c 'Word$' -d res_colloc3_syll_fct_br \
br-phono[0-9]\.prs > list.txt""")
    parser.add_argument('-c', metavar='SYN_REGEX',
                        nargs=1,
                        help='regex defining syntaxic units to match')
    parser.add_argument('files', metavar='FILES',
                        nargs='+',
                        help='files names')
    return vars(parser.parse_args())


if __name__ == '__main__':
    args = parse_args()
    files = args['files']
    for file in files:
        assert os.path.isfile(file), "cannot find file " + file
    searchFiles(args['c'][0], files)
