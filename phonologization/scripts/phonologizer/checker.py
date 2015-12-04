"""Checks and corrects utterances files before phonologization.

Copyright 2015 Mathieu Bernard.

"""


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
    if on_error not in ['raise', 'correct']:
        raise ValueError("`on_error` must be either 'raise' or 'correct'")

    res = ''  # will append corrected lines here

    # we keep EOL characters to look for '\r'
    lines = text.splitlines(True)
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
        else:  # the line is not empty, performs other checks
            # look for begin or end spaces
            striped = line.strip(' \t')
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
            line = line.strip()
            if not line == '':
                res += line + '\n'
    return res


def check_file(filename, on_error='raise'):
    return check_text(open(filename, 'r').read(), on_error)
