import os
import sys

consonnants = {'D', 'G', 'N', 'S', 'T', 'W', 'Z', 'b', 'c', 'd', 'f', 'g', 'h', 'k', 'l', 'm', 'n', 'p', 'r', 's', 't', 'v', 'w', 'y', 'z', 'l'}
vowels = {'#', '%', '&', '(', ')', '*', '3', '6', '7', '9', 'A', 'E', 'I', 'O', 'Q', 'R', 'U', 'a', 'e', 'i', 'o', 'u', '~', 'M', 'L'}

assert not (consonnants & vowels)

onsets = {''}
nuclei = {''}
codas = {''}

non_syll = []

for line in sys.stdin:
    # taking the syllables, splitting and removing the brackets
    sylls = line.split()[1]
    sylls = sylls.split('][')
    sylls[0] = sylls[0][1:]
    sylls[-1] = sylls[-1][:-1]

    for syll in sylls:
        onset = ""
        i = 0

        # searching onset
        while (i < len(syll)) and (syll[i] in consonnants):
            onset += syll[i]
            i += 1
        onsets.add(onset)
        
        # searching nucleus
        if (i == len(syll)) or (syll[i] not in vowels):
            non_syll.append((line, sylls,syll))
        nucleus = ""
        while (i < len(syll)) and (syll[i] in vowels):
            nucleus += syll[i]
            i += 1
        nuclei.add(nucleus)

        # searching coda
        coda = ""
        while (i < len(syll)) and (syll[i] in consonnants):
            coda += syll[i]
            i += 1
        codas.add(coda)
        assert i == len(syll), '{} {} {} {} {}'.format(i, syll, onset, nucleus, coda)


for onset in onsets:
    print "1 1 Onset --> {}".format(onset)
for nucleus in nuclei:
    print "1 1 Nucleus --> {}".format(nucleus)
for coda in codas:
    print "1 1 Coda --> {}".format(coda)
