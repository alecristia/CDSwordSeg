from itertools import izip
from sys import argv


seg = argv[1]  # 'br-phono-mbr.seg'
gold = argv[2]  # 'br-phono.gold'


def words_stringpos(ws):
    stringpos = set()
    left = 0
    for w in ws:
        right = left+len(w)
        stringpos.add((left, right))
        left = right
    return stringpos


with open(seg) as s, open(gold) as g:
    res = list()
    for i, (segline, goldline) in enumerate(izip(s, g)):
        segpos = words_stringpos(segline)
        goldpos = words_stringpos(goldline)
        if set.intersection(segpos, goldpos) == segpos:
            res.append(i)
    print(res)
    print len(res)
