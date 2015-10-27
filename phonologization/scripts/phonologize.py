#!/usr/bin/env python3
"""This script allows the phonologization of text utterances.

Dependancies
------------

To run this you need **festival** installed on your system.  See
http://www.cstr.ed.ac.uk/projects/festival/
On Debian simply run 'apt-get install festival'. Otherwise,
visit http://www.festvox.org/docs/manual-2.4.0/festival_6.html#Installation
For example http://www.cstr.ed.ac.uk/downloads/festival/2.4/
One doc is in
http://pkgs.fedoraproject.org/repo/pkgs/festival/festdoc-1.4.2.tar.gz/md5/faabc25a6c1b11854c41adc257c47bdb/
And the voices for instance in 
http://www.cstr.ed.ac.uk/downloads/festival/2.4/voices/

Examples
--------

$ echo "hello world" > hello.txt
$ python phonologize.py hello.txt
hh ax l ;esyll ow ;esyll ;eword w er l d ;esyll ;eword
$ python phonologize.py hello.txt -o hello.phon
$ cat hello.phon
hh ax l ;esyll ow ;esyll ;eword w er l d ;esyll ;eword

Potential problems
------------------

The program may print on stderr something like:

  UniSyn: using default diphone ax-ax for y-pau

This is related to wave synthesis (done by festival during
phonologization). It should be useful to overload this configuration
if the phonologization takes too long (I began this but it seems a bit
tricky and time consuming).


Copyright 2015 Mathieu Bernard.

"""

import argparse
import os
import subprocess
import sys
import tempfile
import lispy


def parse_args():
    """Argument parser for the phonologization script."""
    parser = argparse.ArgumentParser()
    parser.add_argument('input',
                        help='input text file to be processed')
    parser.add_argument('-o', '--output',
                        help='output text file (default is to write on stdout)',
                        default=sys.stdout)
    return parser.parse_args()


def is_festival_compliant(line):
    """Return True is the string *line* begin and end whith double quotes."""
    if len(line) < 3:
        return False
    return line[0] == line[-2] == '"'


def preprocess(filein):
    """Returns the contents of *filein* formatted for festival input.

    This function adds double quotes to begining and end of each line
    in text, if not already presents. The returned result is a
    multiline string.

    """
    res = ''
    with open(filein, 'r') as fin:
        for line in fin:
            line = (line if is_festival_compliant(line)
                    else '"' + line[:-1] + '"\n')
            res += line
    return res


def process(text, script='scripts/template.scm'):
    """Return the syllabic structure of *text* as parsed by a festival *script*.

    This function delegates to **festival** the *text* analysis and
    syllabic structure extraction.

    Parameters:

    - *text* is the input string to be processed.
    - *script* is the festival script template to be called (optional).

    Return a string containing the "SylStructure" relation tree of
    the *text*.

    """
    with tempfile.NamedTemporaryFile('w+', delete=False) as tmpdata:
        # save the text as a tempfile
        tmpdata.write(text)
        tmpdata.close()

        # the Scheme script to be send to festival
        scm_script = open(script, 'r').read().format(tmpdata.name)

        with tempfile.NamedTemporaryFile('w+', delete=False) as tmpscm:
            tmpscm.write(scm_script)
            tmpscm.close()
            res = subprocess.check_output(['festival', '-b', tmpscm.name])

        os.remove(tmpdata.name)
        os.remove(tmpscm.name)

        # festival seems to use latin1 and not utf8
        return res.decode('latin1')


def postprocess(text):
    """Conversion from festival output format to desired format."""
    res = ''
    # iterate on utterances
    for utt in text.split('\n')[:-1]:
        # iterate on words
        for word in lispy.parse(utt):
        # itererate on syllabes
            for syllabe in word[1:]:
                #iterate on phoneme
                for phone in syllabe[1:]:
                    # remove the "" quoting each phoneme
                    res += phone[0][0].replace('"', '') + ' '
                res += ';esyll '
            res += ';eword '
        res += '\n'
    return res


def phonologize(filein, fileout):
    """This function provides an easy wrapper to phonologization facilities."""
    # load and format input for festival
    text = preprocess(filein)

    # get the syllabe structure of the input
    text = process(text)

    # parse it to the output format
    text = postprocess(text)

    # Write the result on the output file
    if fileout == sys.stdout:
        fileout.write(text)
    else:
        with open(fileout, 'w') as f:
            f.write(text)


def main():
    """Compute the phonologization of an input text through *festival*."""
    args = parse_args()
    phonologize(args.input, args.output)


if __name__ == '__main__':
    main()
