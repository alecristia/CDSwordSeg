# DiBS was written by Robert Daland
# If considering using this code, please contact him at r.daland@gmail.com
# A relevant publication is Daland, R., & Pierrehumbert, J. B. (2011). Learning Diphone‐Based Segmentation. Cognitive science, 35(1), 119-155.

#!/usr/bin/python

import argparse
import codecs
import dibs

parser = argparse.ArgumentParser(description='Train and test a dibs model')
parser.add_argument('trainfile', help='filename to train model on')
parser.add_argument('testfile', help='filename to test model on')
parser.add_argument('outputfile', help='filename to write test output to')
args = parser.parse_args()

training = dibs.summary(multigraphemic = True, wordsep = ';eword')
with codecs.open(args.trainfile, encoding='utf8') as fin: training.readstream(fin)
phrasalDiBS = dibs.phrasal(training)

with codecs.open(args.testfile, encoding='utf8') as fin:
    with codecs.open(args.outputfile, 'w', encoding='utf8') as fout:
        phrasalDiBS.test(fin, fout)








