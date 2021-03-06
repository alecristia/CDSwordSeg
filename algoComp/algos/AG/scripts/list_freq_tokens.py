import os
import sys
import glob


file_regex = sys.argv[1]


for f in glob.glob(file_regex):
    output = os.path.abspath(f) + '.freq'
    res = {}
    with open(f) as fin:
        for line in fin:
            aux = line.split()
            for token in aux:
                if token in res:
                    res[token] += 1
                else:
                    res[token] = 1
    with open(output, 'w+') as fout:
        for token in sorted(res, key=res.get, reverse=True):
            fout.write('{0}\t{1}\n'.format(token, res[token]))
