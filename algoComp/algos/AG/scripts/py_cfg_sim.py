#! /bin/env python

description = """
py-cfg-sim.py version of 15th December, 2013

py-cfg-sim.py reads the .wlt and .trace files produced by
py-cfg, and calculates probabilities of various terminals
"""

import argparse, collections, csv, re, sys
import tb2 as tb

pyparent = collections.namedtuple('pyparent', 'pym pyn pya pyb')

rule = collections.namedtuple('rule', 'count parent children')

tracefile_header0_rex = re.compile("^# .+, n = (\d+), .+, s = ([0-9.]+(?:e[-0-9]+)?), ")
tracefile_header1_rex = re.compile("^# (\d+) tokens in (\d+) sentences$")

wltfile_node_rex = re.compile("^([^#]+)#(\d+)$")

class pyyield:
    def __init__(self):
        self.m = 0
        self.n = 0

class info:
    def __init__(self):
        self.rules = collections.defaultdict(list)
        self.trees = collections.defaultdict(list)
        self.yield_info = collections.defaultdict(pyyield)

    def read_tracefile(self):
        inf = file(self.tracefilename, "rU")
        lines = inf.read().split("\n")
        mo = tracefile_header0_rex.match(lines[0])
        assert(mo)
        self.n = int(mo.group(1))
        mo = tracefile_header1_rex.match(lines[1])
        assert(mo)
        self.ntokens = int(mo.group(1))
        self.nsentences = int(mo.group(2))
        lastline = lines[-1]
        if len(lastline) <= 1:
            lastline = lines[-2]
        fields = lastline.split()
        self.temp = float(fields[1])
        self.time = float(fields[2])
        self.logP = float(fields[3])
        self.tables = int(fields[6])
        self.same = int(fields[7])
        self.changed = int(fields[8])
        self.reject = int(fields[9])
        self.parent_info = dict()
        for i in xrange(11, len(fields), 5):
            self.parent_info[fields[i]] = pyparent(int(fields[i+1]), int(fields[i+2]),
                                                   float(fields[i+3]), float(fields[i+4]))
            
    def read_wltfile(self, nonterm_rex):
        for line in file(self.wltfilename, "rU"):
            if len(line) == 0:
                continue
            if line[0] == '(':
                cat = line[1:line.find('#',1)]
                if nonterm_rex.match(cat):
                    trees = tb.string_trees(line)
                    assert(len(trees) == 1)
                    tree = trees[0]
                    for node in tb.subtrees(tree):
                        if not tb.is_terminal(node):
                            label = node[0]
                            mo = wltfile_node_rex.match(label)
                            if mo:
                                node[0] = (mo.group(1), int(mo.group(2)))
                    cat = tree[0][0]
                    self.trees[cat].append(tree)
            else:
                fields = line.split()
                self.rules[fields[1]].append(rule(count=int(fields[0]), 
                                                  parent=fields[1],
                                                  children=fields[3:]))

    def parse_trees(self, nonterm_rex, terminals_rex, parents, ylds):
        for cat,trees in self.trees.iteritems():
            for tree in trees:
                assert isinstance(tree[0], tuple), tree
                parent = tree[0][0]
                count = tree[0][1]
                if nonterm_rex.match(parent):
                    parents.add(parent)
                    yld = ''.join(tb.terminals(tree))
                    mo = terminals_rex.match(yld)
                    if mo:
                        yld = mo.group(1)
                        ylds.add(yld)
                        info = self.yield_info[parent,yld]
                        info.m += 1
                        info.n += count

    def write_yield_probs(self, parents, ylds, os):
        for parent in parents:
            pinfo = self.parent_info[parent]
            for yld in ylds:
                yinfo = self.yield_info[parent,yld]
                os.writerow((str(self.nsentences), str(self.ntokens),
                             parent, pinfo.pyn, pinfo.pym, pinfo.pya, pinfo.pyb,
                             yld, yinfo.n, yinfo.m))

            
if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=description)
    
    parser.add_argument("filenames", nargs='+',
                        help="trace and rule prob files produced by py-cfg")
    parser.add_argument("--abbrev-re", dest="abbrev_re", default=r"_G([^_]+)_",
                        help="regex mapping trace filename to abbreviation")
    parser.add_argument("--fullname-re", dest="fullname_re", default=r"([^/]+)\.[a-z]+$",
                        help="regex mapping trace filename to full identifier")
    parser.add_argument("--nonterm-re", dest="nonterm_re", default=r'^Word',
                        help="calculate probability of nonterminals matching this regex")
    parser.add_argument("--nterminals", dest="nterminals", default=0, type=int,
                        help="include the most frequent nterminals from each sample group")
    parser.add_argument("--output,-o", dest="output", 
                        help="write output to this file")
    parser.add_argument("--output-field-separator,-f", dest="output_field_separator", 
                        default=",",
                        help="separator between output fields")
    parser.add_argument("--size-re", dest="size_re", default=r'_s([0-9.]+)_',
                        help="regex extracting sample size from file name")
    parser.add_argument("--terminals-re", dest="terminals_re", 
                        default=r'^(yu|want|tu|si|D6|bUk|WAt|WAts)$',
                        help="regex identifying terminals to calculate probability for")
    parser.add_argument("--wlt-re", dest="wlt_re", default=r'(\d)+\.wlt$',
                        help="regex matching py-cfg rule weight file name")
    parser.add_argument("--trace-re", dest="trace_re", default=r'(\d)+\.trace$',
                        help="regex matching py-cfg trace file name")

    args = parser.parse_args()

    fname_abbrev_rex = re.compile(args.abbrev_re)
    fname_fullname_rex = re.compile(args.fullname_re)
    nonterm_rex = re.compile(args.nonterm_re)
    size_rex = re.compile(args.size_re)
    terminals_rex = re.compile(args.terminals_re)
    wlt_rex = re.compile(args.wlt_re)
    trace_rex = re.compile(args.trace_re)

    size_info = collections.defaultdict(info)

    for filename in args.filenames:
        size = 1
        mo = wlt_rex.search(filename)
        if mo:
            size_info[size,int(mo.group(1))].wltfilename = filename
        mo = trace_rex.search(filename)
        if mo:
            size_info[size,int(mo.group(1))].tracefilename = filename

    parents = set()
    ylds = set()
    for sv in sorted(size_info.keys()):
        info = size_info[sv]
        info.s = sv[0]
        info.version = sv[1]
        assert(info.wltfilename)
        assert(info.tracefilename)
        # print sv, size_info[sv].wltfilename, size_info[sv].tracefilename
        info.read_tracefile()
        info.read_wltfile(nonterm_rex)
        info.parse_trees(nonterm_rex, terminals_rex, parents, ylds)
        # print info.parent_info
        # print info.rules
        # print info.trees
        # print

    parents = sorted(list(parents))
    ylds = sorted(list(ylds))

    if args.nterminals > 0:
        parent_yld_n = collections.defaultdict(collections.Counter)
        for info in size_info.itervalues():
            for parent_yld,yinfo in info.yield_info.iteritems():
                parent_yld_n[parent_yld[0]][parent_yld[1]] += yinfo.n
        most_frequent_ylds = set()
        for yld_n in parent_yld_n.itervalues():
            most_frequent_ylds.update(y for y,n in yld_n.most_common(args.nterminals))
        ylds = sorted(list(most_frequent_ylds))

    if args.output:
        os = file(args.output, 'w')
    else:
        os = sys.stdout
    
    os = csv.writer(os, delimiter=args.output_field_separator, lineterminator='\n')
                          
    os.writerow(('filename','grammar', 
                 'sentences','segments','parent','pn','pm','pa','pb',
                 'yield','n','m'))

    for sv in sorted(size_info.keys()):
        info = size_info[sv]
        info.write_yield_probs(fname_fullname_rex, fname_abbrev_rex, parents, ylds, os)
 
            
 
        
