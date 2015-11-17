#!/usr/bin/env python3
"""This script is used to check and optionnaly correct utterances files.

Copyright 2015 Mathieu Bernard.

"""

import argparse

def check_text(text, on_error='raise'):
    """This function checks if the `text` is well formatted.

    Following checks are performed:

    * presence of empty lines
    * presence of '\r' for end of lines
    * presence of multiple contiguous spaces
    * presence of beginning/ending spaces on lines.

    :param str on_error: Can be either 'raise' or 'correct'.
        If 'raise' then raises an exception on the first detected error.
        If 'correct' then corrects errors and return the corrected file.

    """
    if not on_error in ['raise', 'correct']:
        raise ValueError("`on_error` must be either 'raise' or 'correct'")

    res = '' # will append corrected lines here

    # we keep EOL characters to look for '\r'
    lines = text.splitlines(keepends=True)
    for line_nb, line in enumerate(lines):
        line_nb += 1

        # look for '\r'
        if '\r' in line and on_error == 'raise':
            raise RuntimeError("'\r' found on line {} in {}".format(line_nb))
        line = line.replace('\r', '')

        # look for empty line
        if len(line) < 2:
            if on_error == 'raise':
                raise RuntimeError('line {} is empty'.format(line_nb))
        else: # the line is not empty, performs other checks
            # look for begin or end spaces
            striped = line.strip(' ')
            if not striped == line and on_error == 'raise':
                raise RuntimeError('beginning/ending spaces on line {}'
                                   .format(line_nb))
            line = striped

            # look for multiple contiguous spaces
            if '  ' in line and on_error == 'raise':
                raise RuntimeError('multiple contiguous spaces on line {}'
                                   .format(line_nb))
            while '  ' in line:
                line = line.replace('  ', ' ')

            # finally append the corrected line
            res += line

    return res

def check_file(filename, on_error='raise'):
    return check_text(open(filename, 'r').read(), on_error)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('input',
                        help='input text file to be checked')
    parser.add_argument('-o', '--output',
                        help='output corrected file. If not specifed, '
                        'do not correct anything and raise on the first error.',
                        default=None)
    args = parser.parse_args()

    on_error = 'raise' if args.output is None else 'correct'
    if on_error == 'raise':
        check_file(args.input, on_error)
    else:
        open(args.output, 'w').write(check_file(args.input, on_error))

def check_childes():
    """Check all files in the childes database"""

    # The ortholines file contains the list of all input files in the
    # childes database.
    # $ find test/childes -name '*ortholines.txt' > ortholines
    for f in open('ortholines').read().splitlines():
        try:
            check_file(f)
        except RuntimeError as err:
            print('{} : {}'.format(f, str(err)))

if __name__ == '__main__':
    #main()
    check_childes()
