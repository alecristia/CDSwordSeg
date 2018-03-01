#!/usr/bin/env python2
#
# This is a little trick to deals with a bug in the dpseg program.
#
# Bug description: If the 1st utterence (i.e. line) of the input
# is composed of a single syllable, the program fails with a
# segmentation fault.
#
# Bug solution: If the 1st is a single syllable, merge it with the
# next line. Because of the cross-evaluation context, we also need to
# update the xval index when first two lines have been merged.
#
# Mathieu Bernard -- mmathieubernardd@gmail.com

import argparse
import codecs


def join(l, n, isgold=False):
    """Join the lines `n` and `n+1` in the list `l`"""
    assert n+1 < len(l), 'want to read line {} of {}'.format(n+1, len(l)-1)
    l[n+1] = l[n] + ' ' + l[n+1] if isgold else l[n] + l[n+1]
    del l[n]


def join_if_singles(tags, gold, lines=[0]):
    """Join two consecutive lines in `tags` and `gold` if the first
    one contains only one char.

    This method modify `tags` and `gold` in place.

    :param list tags: The tags list where to look for singles
    :param list gold: The gold list to modify according to tags
    :param list lines: The list of line numbers where to look for
        singles. By default look only the first line.

    """
    assert len(tags) == len(gold), 'tags and gold have different length'
    updated_lines = []
    offset = 0
    for n in sorted(lines):
        m = n - offset
        updated_lines.append(m)
        assert m < len(tags), \
            'want to read line {} of {}'.format(m, len(tags)-1)
        print 'line {} is made of {} syllables'.format(m, len(tags[m]))
        if len(tags[m]) == 1:
            print 'dmcmc bugfix: joined lines {} and {}'.format(n, n+1)
            join(tags, m)
            join(gold, m, True)
            offset += 1
    return updated_lines


def bugfix(input_tags, input_gold,
           output_tags=None, output_gold=None,
           lines=[0]):
    print 'DMCMC bugfix from {} and {}'.format(input_tags, input_gold)
    # setup default values for output files
    if output_tags == None:
        output_tags = input_tags
    if output_gold == None:
        output_gold = input_gold

    #print 'dmcmc bugfix: load tags {}'.format(input_tags)
    with codecs.open(input_tags, encoding='utf8', mode='r') as tags:
        tags_lines = [l.strip() for l in tags.readlines()]

    #print 'dmcmc bugfix: load gold {}'.format(input_gold)
    with codecs.open(input_gold, encoding='utf8', mode='r') as gold:
        gold_lines = [l.strip() for l in gold.readlines()]

    # merge lines as required
    updated_lines = join_if_singles(tags_lines, gold_lines, lines)

    #print 'dmcmc bugfix: write tags {}'.format(output_tags)
    with codecs.open(output_tags, encoding='utf8', mode='w') as tags:
        tags.write('\n'.join(tags_lines)+'\n')

    #print 'dmcmc bugfix: write gold {}'.format(output_gold)
    with codecs.open(output_gold, encoding='utf8', mode='w') as gold:
        gold.write('\n'.join(gold_lines)+'\n')

    return updated_lines

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('input_tags')
    parser.add_argument('input_gold')
    parser.add_argument('-t', '--output-tags', default=None)
    parser.add_argument('-g', '--output-gold', default=None)
    parser.add_argument('-l', '--lines', type=int, nargs='+', default=[0])
    args = parser.parse_args()

    print 'lines index: ', args.lines
    l = bugfix(args.input_tags, args.input_gold,
               args.output_tags, args.output_gold,
               args.lines)
    print 'updated lines index:', l

if __name__ == '__main__':
    main()
