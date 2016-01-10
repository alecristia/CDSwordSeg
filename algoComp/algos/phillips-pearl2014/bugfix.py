#!/usr/bin/env python
#
# This is a little trick to deals with a bug in the dpseg program...
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


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('input')
    parser.add_argument('output')
    parser.add_argument('-v', '--verbose', action='store_true')
    args = parser.parse_args()

    with codecs.open(args.input, encoding='utf8', mode='r') as fin:
        with codecs.open(args.output, encoding='utf8', mode='w') as fout:
            # TODO silly, don't need to load entire file !
            lines = [l.strip() for l in fin.readlines()]
            assert len(lines) >= 1

            if len(lines[0]) == 1:
                if args.verbose:
                    print 'Single utterance merged in', args.input
                lines[1] = lines[0] + lines[1]
                del lines[0]

            for line in lines:
                fout.write(line + '\n')

if __name__ == '__main__':
    main()
