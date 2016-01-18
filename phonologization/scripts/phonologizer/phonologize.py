"""Phonologize text utterances with **festival**

Copyright 2015, 2016 Mathieu Bernard.

"""

import os
import subprocess
import tempfile
import shlex

# from . import lispy
import lispy


def default_script():
    return os.path.join(os.path.dirname(os.path.realpath(__file__)),
                        'template.scm')


def festival_is_here():
    """Return True is the festival binary is in the PATH"""
    try:
        subprocess.check_output(shlex.split('which festival'))
        return True
    except:
        return False


def is_double_quoted(line):
    """Return True is the string *line* begin and end whith double quotes."""
    if len(line) < 3:
        return False
    return line[0] == line[-2] == '"'  # line[-1] is '\n'


def preprocess(streamin):
    """Returns the contents of *streamin* formatted for festival input.

    This function adds double quotes to begining and end of each line
    in text, if not already presents. The returned result is a
    multiline string.

    """
    res = ''
    for line in streamin:
        # line = line.strip()
        line = (line if is_double_quoted(line)
                else '"' + line[:-1] + '"\n')
        res += line
    return res


def process(text, script='scripts/template.scm', verbose=False):
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
        if verbose:
            print('loading festival script from {}'.format(script))
        scm_script = open(script, 'r').read().format(tmpdata.name)

        with tempfile.NamedTemporaryFile('w+', delete=False) as tmpscm:
            tmpscm.write(scm_script)
            tmpscm.close()
            cmd = 'festival -b ' + tmpscm.name
            if verbose:
                print('running ' + cmd)
            res = subprocess.check_output(shlex.split(cmd))

        os.remove(tmpdata.name)
        os.remove(tmpscm.name)

        # festival seems to use latin1 and not utf8
        return res.decode('latin1')


def _postprocess_syll(syll):
    res = ''
    for phone in syll[1:]:
        # remove the "" quoting each phoneme
        res += phone[0][0].replace('"', '') + ' '
    if not res == '':
        res += ';esyll'
    return res


def _postprocess_word(word):
    res = ''
    for syll in word[1:]:
        res += _postprocess_syll(syll) + ' '
    if not res == '':
        res += ';eword'
    return res


def _postprocess_line(line):
    res = ''
    for word in lispy.parse(line):
        res += _postprocess_word(word) + ' '
    # remove the last space
    return res[:-1]


def postprocess(text):
    """Conversion from festival output format to desired format."""
    output = []
    for line in text.splitlines():
        res = _postprocess_line(line)
        if not res == '':
            output += res + '\n'
    return ''.join(output)


def phonologize(streamin, streamout, script=None, verbose=False):
    """This function provides an easy wrapper to phonologization facilities."""
    # load and format input for festival
    text = preprocess(streamin)

    # get the syllabe structure of the input
    if not script:
        script = default_script()
    text = process(text, script, verbose)

    # parse it to the output format
    text = postprocess(text)

    # Write the result on the output stream
    streamout.write(text)
