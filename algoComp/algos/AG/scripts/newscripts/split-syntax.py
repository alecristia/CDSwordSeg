import re


F = 'br-text-syntax.txt'
parse = 'br-text-syntax-parse.txt'
dep = 'br-text-syntax-dep.txt'

with open(F) as f, open(parse, 'w+') as p, open(dep, 'w+') as d:
    for line in f:
        if line[0] == '(':
            out = p
        if line[0].isalpha():
            out = d
        out.write(line)
