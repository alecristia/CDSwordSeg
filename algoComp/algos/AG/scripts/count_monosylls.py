import os
import sys
import io

dict_syll = sys.argv[1]
text = sys.argv[2]

n_sylls = {}
res = 0

with io.open(dict_syll, encoding="utf8") as d:
    d.readline()
    d.readline()
    d.readline()
    for line in d:
        aux = line.split()
        n = aux[1].split('-')
        n_sylls[aux[0]] = len(n)
print n_sylls
with io.open(text, encoding="utf8") as t:
    for n, line in enumerate(t):
        words = line.split()
        for word in words:
            if word not in n_sylls:
                print n
            if n_sylls[word] == 1:
                res += 1

sys.stdout.write('{}\n'.format(res))
