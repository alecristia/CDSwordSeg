#!/usr/local/bin/python


usage = """%prog Version of 11th October 2008

Minimum Bayes Risk decoder for words/syllables

(c) Mark Johnson

usage: %prog [options]"""

import lx
import optparse, re, string, sys

def readparses(inf):
    parses = []
    for line in inf:
        line = line.strip()
        if len(line) == 0:
            if len(parses) > 0:
                yield parses
                parses = []
        else:
            parses.append(line)
    if len(parses) > 0:
        yield parses

def argmax(keyvals):
    maxval = None
    maxkey = None
    for key,val in keyvals:
        if maxval == None or val >= maxval:
            maxval = val
            maxkey = key
    return maxkey

mbr_ttable = string.maketrans("", "")

def most_frequent_parse(*parses):
    """Counts the number of times each parse appears, and returns the
    one that appears most frequently"""
    parsecounts = lx.count_elements(parses).iteritems()
    return argmax(parsecounts)

if __name__ == "__main__":
    parser = optparse.OptionParser(usage=usage)
    parser.add_option("-s", "--syllables", dest="syllables_flag", action="store_true",
                      help="produce MBR syllables")

    (options,args) = parser.parse_args()
    data = [parses for fname in args for parses in readparses(file(fname, "rU"))]
    # print "len(data) =", len(data), " sum(len(parses)) =", sum((len(parses) for parses in data))

    for p in map(most_frequent_parse, *data):
        print(p)
    print
