F = 'data/br-text-gold.txt'
enum = 'br-text-enum.txt'

with open(F) as f, open(enum, 'w+') as out:
    for line in f:
        splitted = line.split()
        newline = 'ROOT-0 '
        for index, word in enumerate(splitted):
            newline += word + '-' + str(index + 1) + ' '
        newline += '\n'
        out.write(newline)
