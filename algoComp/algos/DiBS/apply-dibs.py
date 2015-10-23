#!/usr/bin/python
# this DiBS was written by Robert Daland <r.daland@gmail.com>



import argparse
import codecs
import dibs

parser = argparse.ArgumentParser(description='Train and test a dibs model')
parser.add_argument('trainfile', help='filename to train model on')
parser.add_argument('testfile', help='filename to test model on')
parser.add_argument('outputfile', help='filename to write test output to')
parser.add_argument('diphonefile', help='filename to write diphones to')
args = parser.parse_args()

training = dibs.summary(multigraphemic = True, wordsep = ';eword')
with codecs.open(args.trainfile, encoding='utf8') as fin: training.readstream(fin)
phrasalDiBS = dibs.phrasal(training)

with codecs.open(args.testfile, encoding='utf8') as fin:
    with codecs.open(args.outputfile, 'w', encoding='utf8') as fout:
        	phrasalDiBS.test(fin, fout)


with codecs.open(args.diphonefile, 'w', encoding='utf8') as fdiph:
	phrasalDiBS.save(fdiph)





