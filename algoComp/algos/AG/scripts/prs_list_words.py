import re
import argparse
import tb
import os


def incr(word, label):
    if not word in label:
        label[word] = 1
    else:
        label[word] += 1


def searchTree(labels, regex, tree):
    if tb.is_terminal(tree):
        return
    else:
        label = tb.tree_label(tree).split('#')[0]
        if regex.match(label):
            if not label in labels:
                labels[label] = {}
            word = ''.join(tb.terminals(tree)).replace("\\", "")
            incr(word, labels[label])
        for subtree in tb.tree_subtrees(tree):
            searchTree(labels, regex, subtree)


def searchFiles(regex, files):
    pattern = re.compile(regex)
    labels = {}
    for file in files:
        trees = tb.read_file(file)
        for tree in trees:
            searchTree(labels, pattern, tree)

    for dictionary in labels.iteritems():
        print dictionary[0]
        for word in sorted(dictionary[1],
                           key=dictionary[1].get,
                           reverse=True):
            print word, dictionary[1][word]
        print '\n'


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
