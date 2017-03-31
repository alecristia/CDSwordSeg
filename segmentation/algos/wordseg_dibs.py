#!/usr/bin/env python
#
# Copyright Robert Daland <r.daland@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.


"""Train and test a dibs model"""

import argparse
import codecs
import os
import sys

from segmentation import utils, argument_groups


class Counter(dict):
    def increment(self, key, value=1):
        self[key] = self.get(key, 0) + value

    def __getitem__(self, key):
        return self.get(key, 0)


class Summary(object):
    def __init__(self, multigraphemic=False, wordsep='##'):
        self.wordsep = wordsep
        self.multigraphemic = multigraphemic
        self.summary = Counter()

        self.phraseinitial = Counter()
        self.phrasefinal = Counter()
        self.lexicon = Counter()

        self.internaldiphones = Counter()
        self.spanningdiphones = Counter()

    def readstream(self, instream):
        for line in instream:
            if self.multigraphemic:
                wordseq = [
                    tuple(word.split()) for word in line.split(self.wordsep)
                    if word.split()]
            else:
                wordseq = line.split()

            if not wordseq:
                continue

            self.summary.increment('nLines')
            self.summary.increment('nTokens', len(wordseq))
            self.summary.increment(
                'nPhones', sum([len(word) for word in wordseq]))

            if self.multigraphemic:
                self.phraseinitial.increment((wordseq[0][0],))
                self.phrasefinal.increment((wordseq[-1][-1],))
            else:
                self.phraseinitial.increment(wordseq[0][0])
                self.phrasefinal.increment(wordseq[-1][-1])

            for i_word in range(len(wordseq)):
                word = wordseq[i_word]
                self.lexicon.increment(word)

                for i_pos in range(len(word)-1):
                    self.internaldiphones.increment(word[i_pos:i_pos+2])

                if i_word < len(wordseq)-1:
                    if self.multigraphemic:
                        self.spanningdiphones.increment(
                            tuple([word[-1], wordseq[i_word+1][0]]))
                    else:
                        self.spanningdiphones.increment(
                            word[-1]+wordseq[i_word+1][0])

    def diphones(self):
        alldiphones = Counter(self.internaldiphones)
        for diphone in self.spanningdiphones:
            alldiphones.increment(diphone, self.spanningdiphones[diphone])
        return(alldiphones)

    def save(self, outstream):
        if self.multigraphemic:
            def outdic(d):
                lambda d: '\t'.join(
                    ['-'.join(item[0])+' '+str(item[1]) for item in d.items()])
        else:
            def outtdic(d):
                '\t'.join(
                    [str(item[0])+' '+str(item[1]) for item in d.items()])

        print >> outstream, (
            'multigraphemic\t' + str(self.multigraphemic) +
            '\twordsep\t' + self.wordsep)

        for data in ['summary', 'phraseinitial', 'phrasefinal',
                     'internaldiphones', 'spanningdiphones', 'lexicon']:
            print >> outstream, data + '\t' + outdic(self.__dict__[data])


class Dibs(Counter):
    def __init__(self, multigraphemic=False, thresh=0.5, wordsep='##'):
        super(Dibs, self).__init__()

        self.multigraphemic, self.wordsep = multigraphemic, wordsep
        self.thresh = thresh

    def test(self, instream, outstream):
        bdry = self.wordsep*self.multigraphemic + ' '*(not self.multigraphemic)
        for line in instream:
            if self.multigraphemic:
                phoneseq = tuple(line.replace(self.wordsep, ' ').split())
            else:
                phoneseq = ''.join(line.split())

            if not phoneseq:
                continue

            out = [phoneseq[0]]
            for iPos in range(len(phoneseq)-1):
                if self.get(phoneseq[iPos:iPos+2], 1.0) > self.thresh:
                    out.append(bdry)
                out.append(phoneseq[iPos+1])

            print >> outstream, (
                line.rstrip() + '\t' + (' ' * self.multigraphemic).join(out))

    def save(self, outstream):
        if self.multigraphemic:
            rows = sorted(dict([((key[0],), 1) for key in self]).keys())
            cols = sorted(dict([((key[1],), 1) for key in self]).keys())
        else:
            rows = '#$123456789@DEHIJNPQRSTUVZ_bdfghijklmnprstuvwxz{~'
            cols = '#$123456789@DEHIJNPQRSTUVZ_bdfghijklmnprstuvwxz{~'
        print >> outstream, '\t'+'\t'.join([str(y) for y in cols])
        for x in rows:
            try:
                print >> outstream, (
                    str(x) + '\t' + '\t'.join([str(self[x+y]) for y in cols]))
            except KeyError:
                print >> outstream, (
                    str(x) + '\t' + '\t'.join(
                        [str(self.get(x + y, None)) for y in cols]))


def norm2pdf(fdf):
    return Counter(
        [(item[0], float(item[1]) / sum(fdf.values())) for item in fdf.items()]
    )


def baseline(speech, lexicon=None, pwb=None):
    dib = Dibs(multigraphemic=speech.multigraphemic, wordsep=speech.wordsep)
    within, across = speech.internaldiphones, speech.spanningdiphones
    for diphone in speech.diphones():
        dib[diphone] = float(across[diphone]) / (
            within[diphone] + across[diphone])
    return dib


def phrasal(speech, pwb=None):
    px2_ = norm2pdf(speech.phrasefinal)
    p_2y = norm2pdf(speech.phraseinitial)
    pxy = norm2pdf(speech.diphones())
    pwb = pwb or (
        float(speech.summary['nTokens'] - speech.summary['nLines']) /
        (speech.summary['nPhones'] - speech.summary['nLines']))

    print >> sys.stderr, 'phrasal\tpwb = ' + str(pwb)

    dib = Dibs(multigraphemic=speech.multigraphemic, wordsep=speech.wordsep)
    for diphone in speech.diphones():
        if speech.multigraphemic:
            x, y = (diphone[0],), (diphone[1],)
        else:
            x, y = diphone[0], diphone[1]

        num, denom = px2_[x] * pwb * p_2y[y], pxy[diphone]
        dib[diphone] = 1 if num >= denom else num / denom
    return dib


def lexical(speech, lexicon=None, pwb=None):
    wordinitial = Counter()
    wordfinal = Counter()
    lexicon = lexicon or speech.lexicon

    for word in lexicon:
        if speech.multigraphemic:
            wordinitial.increment((word[0],))
            wordfinal.increment((word[-1],))
        else:
            wordinitial.increment(word[0])
            wordfinal.increment(word[-1])

    px2_ = norm2pdf(wordfinal)
    p_2y = norm2pdf(wordinitial)
    pxy = norm2pdf(speech.diphones())
    p_ = pwb or (
        float(speech.summary['nTokens'] - speech.summary['nLines']) /
        (speech.summary['nPhones'] - speech.summary['nLines']))

    print >> sys.stderr, 'lexical\tpwb = ' + str(p_)

    dib = Dibs(multigraphemic=speech.multigraphemic, wordsep=speech.wordsep)
    for diphone in speech.diphones():
        if speech.multigraphemic:
            x, y = (diphone[0],), (diphone[1],)
        else:
            x, y = diphone[0], diphone[1]

        num, denom = px2_[x] * p_ * p_2y[y], pxy[diphone]
        dib[diphone] = 1 if num >= denom else num / denom
    return dib


def get_options(parser):
    """Add Dibs command specific options to the `parser`"""
    parser.add_argument(
        '-t', '--train', metavar='<int or file>', type=str, default='200',
        help='''Dibs requires a little train corpus to compute some statistics.
        If the argument is a file, read this file as a train corpus. If
        the argument is a positive integer N, take the N first lines of the
        <input-file> (train) file for testing, default is %(default)s''')

    parser.add_argument(
        '-d', '--diphone', metavar='<output-file>',
        help='''optional filename to write diphones,
        ignore diphones if this argument is not specified''')

# TODO add pwb as argument

@utils.catch_exceptions
def main():
    """Entry point of the 'wordseg-dibs' command"""
    # define the commandline parser
    parser = argparse.ArgumentParser(description=__doc__)
    argument_groups.add_input_output(parser)
    argument_groups.add_separators(parser, phone=False, syllable=False)
    get_options(parser)

    # parse the command line arguments
    args = parser.parse_args()

    # open the input and output streams
    streamin, streamout = utils.prepare_streams(args.input, args.output)

    # load the test input
    test_text = streamin.readlines()

    # prepare the train input according to --train: try to open the
    # file first, if file not found cast to int
    if os.path.isfile(args.train):
        train_text = codecs.open(
            args.train, 'r', encoding='utf8').readlines()
    else:
        try:
            ntrain = int(args.train)
        except ValueError:
            raise ValueError(
                '--train option must be an int or an existing file, '
                'it is: {}'.format(args.train))

        if ntrain <= 0:
            raise ValueError(
                '--train option must be positive, it is: {}'.format(ntrain))

        train_text = test_text[:ntrain]

    training = Summary(multigraphemic=True, wordsep=args.word_separator)
    training.readstream(train_text)

    phrasal_dibs = phrasal(train_text)
    phrasal_dibs.test(test_text, streamout)
    if args.diphones:
        phrasal_dibs.save(codecs.open(args.diphone, 'w', encoding='utf8'))


if __name__ == '__main__':
    main()
