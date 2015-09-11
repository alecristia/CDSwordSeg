import eval
import sys
import glob
import os
from cStringIO import StringIO
import sys
import re


class Object(object):
    pass


class Capturing(list):
    def __enter__(self):
        self._stdout = sys.stdout
        sys.stdout = self._stringio = StringIO()
        return self
    def __exit__(self, *args):
        self.extend(self._stringio.getvalue().splitlines())
        sys.stdout = self._stdout


def sort(l, order):
    index = 0
    newindexes = []
    matched = set()
    for cat in order:
        first = index
        matches = []
        for i, elt in enumerate(l):
            if cat in os.path.basename(elt):
                matches.append((elt, i))
        matches = sorted(matches, key=lambda x: x[0])
        for m in matches:
            newindexes.append(m[1])
            assert m[0] not in matched
            matched.add(m[0])

    res = []
    for i in range(len(newindexes)):
        res.append(l[newindexes[i]])
    res += l[len(newindexes)+1:]
    res += l[len(res):]
    return res
        # for match in matches:
        #     l[index], l[match[1]] = l[match[1]], l[index]
        #     index += 1
    # l[index+1:].sort()


# Arguments
usage = 'python eval_all.py goldfolder [testfolder] outfile'
if len(sys.argv) == 4:
    goldfolder = sys.argv[1]
    testfolder = sys.argv[2]
    outfile = sys.argv[3]
    goldlist = glob.glob(os.path.join(goldfolder, '*.gold'))
    trainlist = glob.glob(os.path.join(testfolder, '*mbr*.seg'))

elif len(sys.argv) == 3:
    goldfolder = sys.argv[1]
    outfile = sys.argv[2]
    goldlist = glob.glob(os.path.join(goldfolder, '*.gold'))
    trainlist = glob.glob(os.path.join(goldfolder, '*.gold'))

else:
    print usage
    exit()

assert goldlist, 'no goldfiles found\n' + usage
assert trainlist, 'no testfiles found\n' + usage

evals = ['token f-score', 'token precision', 'token recall',
         'bound f-score', 'bound precision', 'bound recall',]
order = ['syll', 'morph', 'word', 'colloc']
res = [['x']]
goldlist = sort(goldlist, order)
#TODO, better sort.
trainlist = sort(trainlist, order)

for j, goldf in enumerate(goldlist):
    res[0].append(os.path.basename(goldf))
for i, trainf in enumerate(trainlist):
    res.append([os.path.basename(trainf)])
    for j, goldf in enumerate(goldlist):
        word_split_rex = re.compile(' ')
        ignore_terminal_rex = re.compile(r"^[$]{3}$")
        options = Object()
        options.debug = 0
        options.extra = False
        options.levelname = False

        with open(goldf) as g:
            (goldwords,goldstringpos) = eval.read_data([line.strip() for line in g if line.strip()], False,
                                                       word_split_rex=word_split_rex,
                                                       ignore_terminal_rex=ignore_terminal_rex)

        # print PrecRecHeader
        # sys.stdout.write("token_f-score\ttoken_precision\ttoken_recall\tboundary_f-score\tboundary_precision\tboundary_recall\n");
        # sys.stdout.flush()
        
        with open(trainf) as t:
            # trainlines = []
            # for trainline in t:
            #     trainline = trainline.strip()
            #     if trainline != "":
            #         trainlines.append(trainline)
            #         continue

            (trainwords,trainstringpos) = eval.read_data([line.strip() for line in t if line.strip()], False,
                                                         word_split_rex=word_split_rex,
                                                         ignore_terminal_rex=ignore_terminal_rex)
        with Capturing() as output:
            eval.evaluate(options, trainwords, trainstringpos, goldwords, goldstringpos)
            trainlines = []
        r = output[0].split('\t')
        assert len(r) == len(evals), ('missing evaluation for files {} and {}'
                                      .format(goldf, trainf))
        res[i+1].append(r)

with open(outfile, 'w+') as out:
    for i, measure in enumerate(evals):
        out.write(', '.join([measure] + res[0][1:]) + '\n')
        for l in res[1:]:
            out.write(', '.join([l[0]] + [e[i] for e in l[1:]]) + '\n')
