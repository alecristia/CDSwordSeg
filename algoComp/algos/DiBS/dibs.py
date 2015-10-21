# this DiBS was written by Robert Daland <r.daland@gmail.com>

import sys

class counter(dict):
    def increment(self, key, value=1): self[key] = self.get(key,0)+value
    def __getitem__(self, key): return(self.get(key,0))

class summary:
    def __init__(self, multigraphemic = False, wordsep = '##'):
        self.wordsep = wordsep
        self.multigraphemic = multigraphemic
        self.summary = counter()

        self.phraseinitial = counter()
        self.phrasefinal = counter()
        self.lexicon = counter()

        self.internaldiphones = counter()
        self.spanningdiphones = counter()

    def readstream(self, instream):
        iLine = 0
        for line in instream:
            if self.multigraphemic: wordseq = [tuple(word.split()) for word in line.split(self.wordsep) if word.split()]
            else: wordseq = line.split()
            if not wordseq: continue

            self.summary.increment('nLines')
            self.summary.increment('nTokens', len(wordseq))
            self.summary.increment('nPhones', sum([len(word) for word in wordseq]))

            if self.multigraphemic: self.phraseinitial.increment((wordseq[0][0],))
            else: self.phraseinitial.increment(wordseq[0][0])
            if self.multigraphemic: self.phrasefinal.increment((wordseq[-1][-1],))
            else: self.phrasefinal.increment(wordseq[-1][-1])

            for iWord in range(len(wordseq)):
                word = wordseq[iWord]
                self.lexicon.increment(word)

                for iPos in range(len(word)-1): self.internaldiphones.increment(word[iPos:iPos+2])
                if iWord < len(wordseq)-1:
                    if self.multigraphemic: self.spanningdiphones.increment(tuple([word[-1],wordseq[iWord+1][0]]))
                    else: self.spanningdiphones.increment(word[-1]+wordseq[iWord+1][0])

    def diphones(self):
        alldiphones = counter(self.internaldiphones)
        for diphone in self.spanningdiphones: alldiphones.increment(diphone,self.spanningdiphones[diphone])
        return(alldiphones)

    def save(self, outstream):
        if self.multigraphemic: outdic = lambda d: '\t'.join(['-'.join(item[0])+' '+str(item[1]) for item in d.items()])
        else: outdic = lambda d: '\t'.join([str(item[0])+' '+str(item[1]) for item in d.items()])

        print >> outstream, 'multigraphemic\t'+str(self.multigraphemic)+'\twordsep\t'+self.wordsep
        for data in ['summary', 'phraseinitial', 'phrasefinal', 'internaldiphones', 'spanningdiphones', 'lexicon']:
            print >> outstream, data+'\t'+outdic(self.__dict__[data])

class dibs(counter):
    def __init__(self, multigraphemic = False, thresh = .5, wordsep = '##'):
        self.multigraphemic, self.wordsep = multigraphemic, wordsep
        self.thresh = thresh

    def test(self, instream, outstream):
        bdry = self.wordsep*self.multigraphemic + ' '*(not self.multigraphemic)
        for line in instream:
            if self.multigraphemic: phoneseq = tuple(line.replace(self.wordsep, ' ').split())
            else: phoneseq = ''.join(line.split())
            if not phoneseq: continue

            out = [phoneseq[0]]
            for iPos in range(len(phoneseq)-1):
                if self.get(phoneseq[iPos:iPos+2],1.0) > self.thresh: out.append(bdry)
                out.append(phoneseq[iPos+1])

            print >> outstream, line.rstrip() + '\t' + (' '*self.multigraphemic).join(out)

    def save(self, outstream):
        if self.multigraphemic:
            rows = sorted(dict([((key[0],),1) for key in self]).keys())
            cols = sorted(dict([((key[1],),1) for key in self]).keys())
        else: 
            rows = '#$123456789@DEHIJNPQRSTUVZ_bdfghijklmnprstuvwxz{~'
            cols = '#$123456789@DEHIJNPQRSTUVZ_bdfghijklmnprstuvwxz{~'
        print >> outstream, '\t'+'\t'.join([str(y) for y in cols])
        for x in rows:
            try: print >> outstream, str(x) + '\t' + '\t'.join([str(self[x+y]) for y in cols])
            except KeyError: print >> outstream, str(x) + '\t' + '\t'.join([str(self.get(x+y,None)) for y in cols])

def norm2pdf(fdf):
    s = sum(fdf.values())
    return(counter([(item[0], float(item[1])/s) for item in fdf.items()]))

def baseline(speech, lexicon = None, pwb = None):
    dib = dibs(multigraphemic = speech.multigraphemic, wordsep = speech.wordsep)
    within, across = speech.internaldiphones, speech.spanningdiphones
    for diphone in speech.diphones(): dib[diphone] = float(across[diphone])/(within[diphone]+across[diphone])
    return(dib)

def phrasal(speech, lexicon = None, pwb = None):
    px2_, p_2y, pxy = norm2pdf(speech.phrasefinal), norm2pdf(speech.phraseinitial), norm2pdf(speech.diphones())
    p_ = pwb or float(speech.summary['nTokens']-speech.summary['nLines'])/(speech.summary['nPhones']-speech.summary['nLines'])
    print >> sys.stderr, 'phrasal\tpwb = '+str(p_)

    dib = dibs(multigraphemic = speech.multigraphemic, wordsep = speech.wordsep)
    for diphone in speech.diphones():
        if speech.multigraphemic: x,y = (diphone[0],), (diphone[1],)
        else: x,y = diphone[0], diphone[1]
        num, denom = px2_[x] * p_ * p_2y[y], pxy[diphone]
        if num >= denom: dib[diphone] = 1
        else: dib[diphone] = num/denom
    return(dib)

def lexical(speech, lexicon = None, pwb = None):
    wordinitial, wordfinal, lex = counter(), counter(), lexicon or speech.lexicon
    for word in lex:
        if speech.multigraphemic:
            wordinitial.increment((word[0],))
            wordfinal.increment((word[-1],))
        else:
            wordinitial.increment(word[0])
            wordfinal.increment(word[-1])

    px2_, p_2y, pxy = norm2pdf(wordfinal), norm2pdf(wordinitial), norm2pdf(speech.diphones())
    p_ = pwb or float(speech.summary['nTokens']-speech.summary['nLines'])/(speech.summary['nPhones']-speech.summary['nLines'])
    print >> sys.stderr, 'lexical\tpwb = '+str(p_)

    dib = dibs(multigraphemic = speech.multigraphemic, wordsep = speech.wordsep)
    for diphone in speech.diphones():
        if speech.multigraphemic: x,y = (diphone[0],), (diphone[1],)
        else: x,y = diphone[0], diphone[1]
        num, denom = px2_[x] * p_ * p_2y[y], pxy[diphone]
        if denom == 0 or num > denom: dib[diphone] = 1
        else: dib[diphone] = num/denom
    return(dib)

