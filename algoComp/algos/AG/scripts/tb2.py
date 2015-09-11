"""tb.py reads, searches and displays trees from Penn Treebank (PTB) format
treebank files.

(c) Mark Johnson, 30th August, 2005, modified 2nd July 2011

Trees are represented in Python as nested list structures in the following
format:

  Terminal nodes are represented by strings.

  Nonterminal nodes are represented by lists.  The first element of
  the list is the node's label (a string), and the remaining elements
  of the list are lists representing the node's children.

This module also defines two regular expressions.

nonterm_re matches Penn treebank nonterminal labels, and parses them into
their various parts.

empty_re matches empty elements (terminals), and parses them into their
various parts.
"""

import re

_header_re = re.compile(r"(\*x\*.*\*x\*[ \t]*\n)*\s*")
_openpar_re = re.compile(r"\s*\(\s*([^ \t\n\r\f\v()]*)\s*")
_closepar_re = re.compile(r"\s*\)\s*")
_terminal_re = re.compile(r"\s*((?:[^ \\\t\n\r\f\v()]|\\.)+)\s*")

def read_file(filename):

    """Return a list of the trees in the PTB file filename."""
    
    filecontents = file(filename, "rU").read()
    print len(filecontents)
    pos = _header_re.match(filecontents).end()
    trees = []
    _string_trees(trees, filecontents, pos)
    return trees

def read_string_tree(string):
    pos = _header_re.match(string).end()
    trees = []
    _string_trees(trees, string, pos)
    return trees

def string_trees(s):
    
    """Returns a list of the trees in PTB-format string s"""
    
    trees = []
    _string_trees(trees, s)
    return trees

def _string_trees(trees, s, pos=0):
    
    """Reads a sequence of trees in string s[pos:].
    Appends the trees to the argument trees.
    Returns the ending position of those trees in s."""
    
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

def is_terminal(subtree):
    
    """True if this subtree consists of a single terminal node
    (i.e., a word or an empty node)."""
    
    return not isinstance(subtree, list)


def is_preterminal(subtree):
    
    """True if the treebank subtree is rooted in a preterminal node
    (i.e., is an empty node or dominates a word)."""

    return isinstance(subtree, list) and len(subtree) > 1 and reduce(lambda x,y: x and is_terminal(y), subtree[1:], True)


def is_phrasal(subtree):
    
    """True if this treebank subtree is not a terminal or a preterminal node."""
    
    return isinstance(subtree, list) and \
           (len(subtree) == 1 or isinstance(subtree[1], list))

def tree_children(tree):

    """Returns a list of the child subtrees of tree."""

    if isinstance(tree, list):
        return tree[1:]
    else:
        return []

def tree_label(tree):

    """Returns the label on the root node of tree."""

    if isinstance(tree, list):
        return tree[0]
    else:
        return tree

    
def terminals(tree):
    
    """Returns a list of the terminal strings in tree"""

    def _terminals(node, terms):
        if isinstance(node, list):
            for child in node[1:]:
                _terminals(child, terms)
        else:
            terms.append(node)

    terms = []
    _terminals(tree, terms)
    return terms

def preterminals(tree):

    """Generates all the preterminal nodes in the tree"""
    
    if is_preterminal(tree):
        yield tree
    else:
        for child in tree_children(tree):
            for s in preterminals(child):
                yield s

def subtrees(tree):

    """Generates all the subtrees of tree"""

    yield tree
    for child in tree_children(tree):
        for s in subtrees(child):
            yield s

