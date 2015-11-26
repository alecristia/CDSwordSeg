"""Phonologize text utterances with **festival**

Copyright 2015 Mathieu Bernard.

"""

import os
import subprocess
import sys
import tempfile

from . import lispy

def default_script():
    return os.path.join(os.path.dirname(os.path.realpath(__file__)),
                        'template.scm')

def is_double_quoted(line):
    """Return True is the string *line* begin and end whith double quotes."""
    if len(line) < 3:
        return False
    return line[0] == line[-2] == '"' # line[-1] is '\n'


def preprocess(filein):
    """Returns the contents of *filein* formatted for festival input.

    This function adds double quotes to begining and end of each line
    in text, if not already presents. The returned result is a
    multiline string.

    """
    res = ''
    with open(filein, 'r') as fin:
        for line in fin:
            # line = line.strip()
            line = (line if is_double_quoted(line)
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
            # TODO Check the word is not empty
            # itererate on syllabes
            for syllabe in word[1:]:
                # iterate on phoneme
                for phone in syllabe[1:]:
                    # remove the "" quoting each phoneme
                    res += phone[0][0].replace('"', '') + ' '
                res += ';esyll '
            res += ';eword '
        # remove the last space before new line
        res = res[:-1] + '\n'
    return res


def phonologize(filein, fileout, script):
    """This function provides an easy wrapper to phonologization facilities."""
    # load and format input for festival
    text = preprocess(filein)

    # get the syllabe structure of the input
    text = process(text, script)

    # parse it to the output format
    text = postprocess(text)

    # Write the result on the output file
    if fileout == sys.stdout:
        fileout.write(text)
    else:
        open(fileout, 'w').write(text)
