import re
import argparse
import tb
import os


def incr(word, label):
    if not word in label:
        label[word] = 1
    else:
        label[word] += 1


def convert(line):
    pass


def searchTree(l, regex, tree):
    if tb.is_terminal(tree):
        return
    else:
        label = tb.tree_label(tree).split('#')[0]
        if regex.match(label):
            word = ''.join(tb.terminals(tree)).replace("\\", "")
            l.append([(label, word)])
            l = l[-1]
        for subtree in tb.tree_subtrees(tree):
            searchTree(l, regex, subtree)


def searchFiles(regex, files):
    pattern = re.compile(regex)
    for file in files:
        trees = tb.read_file(file)
        for tree in trees:
            l = []
            searchTree(l, pattern, tree)
            print displayList(l)


def displayList(l):
    res = ""
    for elt in l:
        if type(elt) == tuple:
            res += elt[0] + ": " + elt[1] + " "
        else:
            res += "{ " + displayList(elt) + "} "
    return res


def parse_args():
    parser = argparse.ArgumentParser(
        prog='list_words',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description="""For each syntaxic unit described in the regex, list the
words corresponding and its number of appearance in the files""",
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
