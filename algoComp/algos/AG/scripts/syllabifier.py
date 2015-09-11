import sys
import re
import numpy as np


dict_br_file = sys.argv[1]
dict_celex_file = sys.argv[2]
match_file = sys.argv[3]
out_file = sys.argv[4]

# match = [['@'], ['6']]
# match_br = ['6']
# match_ce = ['@']
"""
Try to match two phonemic dictionaries given a list of correspondance, apply
the syllable slicing of a dictionary to the other one

br_dict: list of "word phons"
celex_dict: list of "word [syll1][syll2] with syll1 = phon1phon2
correspondance: list of phon1_br/phon2_br phon1_ce/phon2_ce
output: multiple transcriptions, single matches, unmatched words, words not
found in the celex dictionary, errors
"""


def process(br_dict, celex_dict, match_br, list_br, out):
    res = {}
    res['errors'] = ''
    res['matched'] = {}
    res['unmatched'] = ''
    res['notfound'] = ''
    n_nfound = 0
    n_nmatch = 0
    for br_line in br_dict:
        try:
            (br_word, br_phon) = br_line.split()
            found = False
            for celex_line in celex_dict:
                if celex_line[0] == br_word:
                    found = True
                    c = compare(br_phon, celex_line[1], match_br, list_br)
                    if c:
                        # print('found ' + br_word, [p.split(':') for p in c],
                        #       celex_line[1])
                        addMatch(res['matched'], br_word, c)
            if found:
                if br_word not in res['matched']:
                    n_nmatch += 1
                    res['unmatched'] += br_word + '\t' + br_phon
                    for celex_line in celex_dict:
                        if celex_line[0] == br_word:
                            res['unmatched'] += '\t[' + ']['.join(celex_line[1]) + ']'
                    res['unmatched'] += '\n'
            else:
                n_nfound += 1
                res['notfound'] += br_line
        except ValueError:
            res['errors'] += br_line
    out.write('multiple matched words:\n')
    n_mult = 0
    for word, segs in res['matched'].iteritems():
        aux = word + '\t'
        if len(segs) > 1:
            n_mult += 1
            for seg in segs:
                # aux += '[' + ']['.join(seg.split(':')) + ']\t'
                aux += '[' + seg.replace(':', '][') + ']\t'
            out.write(aux + '\n')
    out.write('\nmatched words:\n')
    n_match = 0
    for word, segs in res['matched'].iteritems():
        aux = word + '\t'
        if len(segs) == 1:
            n_match += 1
            for seg in segs:
                # aux += '[' + ']['.join(seg.split(':')) + ']\t'
                aux += '[' + seg.replace(':', '][') + ']\t'
            out.write(aux + '\n')
    out.write('\nunmatched (but found) words:\n')
    out.write(res['unmatched'])
    out.write('\nnot found words:\n')
    out.write(res['notfound'])
    out.write('\nerrors\n')
    out.write(res['errors'])
    print 'multiple transcriptions: ' + str(n_mult)
    print 'number of single matches: ' + str(n_match)
    print 'number of umatched: ' + str(n_nmatch)
    print 'number of not found: ' + str(n_nfound)


def addMatch(match_list, word, matches):
    if word in match_list:
        for match in matches:
            if match not in match_list[word]:
                match_list[word] += [match]
    else:
        match_list[word] = [matches[0]]
        addMatch(match_list, word, matches)


def find_phon(phon, word):
    return phon == word[:len(phon)]


def compare(word_br, word_celex, match_br, list_br, verbose=False):
    newres = []
    # if not word_br and not word_celex:
    #     # print 'ok'
    #     return True
    # if not word_br or not word_celex:
    #     return False
    if word_br == 'kold':
        verbose = True
    for br_phon in list_br:
        if find_phon(br_phon, word_br):
            br_subwd = word_br[len(br_phon):]
            syll = word_celex[0]
            for ce_phon in match_br[br_phon]:
                if find_phon(ce_phon, syll):
                    # print ce_phon, syll
                    subsyll = syll[len(ce_phon):]
                    if subsyll:
                        ce_subwd = [subsyll] + word_celex[1:]
                        # if subsyll and word_celex[1:]:
                        #     print subsyll, ce_subwd
                    else:
                        ce_subwd = word_celex[1:]
                    # print ce_subwd, br_subwd
                    # if type(res) == str:
                    #     return word_br, br_phon + res[1]
                    # else:
                    #     if res:
                    #         return word_br, br_phon
                    #     else:
                    #         return False
                    if not br_subwd and not ce_subwd:
                        newres.append(br_phon)
                    elif not br_subwd or not ce_subwd:
                        continue
                    else:
                        res = compare(br_subwd, ce_subwd, match_br, list_br,
                                      verbose)
                        if subsyll:
                            newres += [br_phon + br_phons
                                       for br_phons in res]
                        else:
                            newres += [br_phon + ':' + br_phons
                                       for br_phons in res]
                        # else:
                        #     newres.append((br_phon, ce_phon))
                    # else:
                    #     return False
    # if len(newres) > 1:
    #     print newres
    # if verbose:
    #     print newres
    return newres


def decompose_celex(celex_dict_file):
    with open(dict_celex_file) as dict_celex_f:
        res = []
        for celex_line in dict_celex_f:
            aux = celex_line.split()
            if len(aux) == 2:
                aux[1] = aux[1].replace('[', '').split(']')[:-1]
                res.append(aux)
    return res


def process_matchlist(match_file):
    match = []
    match_br = {}
    with open(match_file) as match_f:
        match_f.readline()
        for line in match_f:
            aux = line.split()[:2]
            aux[0] = aux[0].split('/')
            aux[1] = aux[1].split('/')
            match.append(aux)
    list_br = np.unique([phon for phons in match for phon in phons[1]])
    # list_ce = np.unique([phon for phons in match for phon in phons[0]])
    for phon in list_br:
        aux = []
        for l in match:
            for phon_br in l[1]:
                if phon_br == phon:
                    aux += l[0]
        match_br[phon] = np.unique(aux)
    return match_br, list_br


with open(dict_br_file) as dict_br:
    (match_br, list_br) = process_matchlist(match_file)
    splitted_dict = decompose_celex(dict_celex_file)
    with open(match_file) as match_f:
        match = match_f.read()
        with open(out_file, 'w') as out:
            process(dict_br, splitted_dict, match_br, list_br, out)
