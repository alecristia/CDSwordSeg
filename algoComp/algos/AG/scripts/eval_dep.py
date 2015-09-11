import sys
import re

depfile = sys.argv[1]
segfile = sys.argv[2]
goldfile = sys.argv[3]

# store the word and translate it ? may be safer


def incr(res, rule, score):
    if rule not in res:
        res[rule] = (0, 0)

    res[rule] = (res[rule][0] + score, res[rule][1] + 1)


with open(depfile) as depf, open(segfile) as segf, open(goldfile) as goldf:

    # dictionnary mapping a dependency rule to a tuple (score, total)
    rules = {}

    for segline, goldline in zip(segf, goldf):

        # storing dependencies
        dependency = depf.readline()
        deps = []
        while dependency and dependency != '\n':
            aux = dependency.split('(')
            aux2 = aux[1].split(', ')
            i1 = int(re.search('(?<=-)\d+', aux2[0]).group(0))
            i2 = int(re.search('(?<=-)\d+', aux2[1]).group(0))
            deps.append((aux[0], i1, i2))
            if i1 == i2:
                print dependency
            if not aux[0] in rules:
                rules[aux[0]] = (0, 0)
            dependency = depf.readline()

        enum = goldline.split()
        enum.insert(0, 'ROOT')

        #TODO remove len check, when neg and all that will be splitted
        #TODO add verification of index in the seg sentence
        for colloc in segline.split():
            for rule, id1, id2 in deps:
                if max(id1, id2) < len(enum) and enum[id1] in colloc and enum[id2] in colloc:
                    incr(rules, rule, 1)
                    # if id1 != id2:
                    #     print 'ok'
                    # print(rule + " {0} {1} {2}"
                    #       .format(enum[id1], enum[id2], colloc))
                elif (id1 < len(enum) and enum[id1] in colloc) or (id2 < len(enum) and enum[id2] in colloc):
                    incr(rules, rule, 0)

    for rule, (score, total) in rules.iteritems():
        print('{0}: {1}'.format(rule, float(score)/float(total)))
    # print(rules)
