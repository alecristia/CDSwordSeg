# Copyright 2017 Mathieu Bernard
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

"""Provide utility functions to the wordseg package"""

import argparse
import codecs
import collections
import logging
import pkg_resources
import sys


Separator = collections.namedtuple('Separator', ['phone', 'syllable', 'word'])

default_separator = Separator(phone=' ', syllable=';esyll', word=';eword')


def null_logger():
    """Return a logger going to nowhere"""
    log = logging.getLogger()
    log.addHandler(logging.NullHandler())
    return log


class CatchExceptions(object):
    """Decorator wrapping a function in a try/except block

    When an exception occurs, log a critical message before
    exiting with error code 1.

    """
    def __init__(self, function):
        self.function = function

    def __call__(self):
        try:
            self.function()

        except (ValueError, OSError, RuntimeError, AssertionError) as err:
            self.exit('fatal error: {}'.format(err))

        except pkg_resources.DistributionNotFound:
            self.exit(
                'fatal error: wordseg package not found\n'
                'please install wordseg on your system')

        except KeyboardInterrupt:
            self.exit('keyboard interruption, exiting')

    def exit(self, msg):
        """Write `msg` on stderr and exit with error code 1"""
        sys.stderr.write(msg.strip() + '\n')
        sys.exit(1)


def get_logger(name=None):
    log = logging.getLogger(name)
    log.setLevel(logging.WARNING)

    formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
    handler = logging.StreamHandler(sys.stderr)
    handler.setFormatter(formatter)

    log.addHandler(handler)
    return log


def get_parser(description=None, separator=default_separator):
    """Add token separators options to the `parser`

    Set `phone`, `syllable` and `word` to the default value you want
    they have in the parser, or set to False to disable them.

    """
    parser = argparse.ArgumentParser(description=description)

    # add input and output arguments to the parser
    parser.add_argument(
        'input', default=sys.stdin, nargs='?', metavar='<input-file>',
        help='Input text file to read, if not specified read from stdin.')

    # add verbose/quiet options to control log level
    group = parser.add_mutually_exclusive_group()
    group.add_argument(
        '-v', '--verbose', action='count', default=0, help='''
        Increase the amount of logging on stderr.  By default only
        warnings and errors are displayed, a single '-v' adds info
        messages and '-vv' adds debug messages.  Use '--quiet' to
        disable logging.''')

    group.add_argument(
        '-q', '--quiet', action='store_true',
        help='Do not output anything on stderr.')

    # add token separation arguments
    if separator.phone or separator.syllable or separator.word:
        if separator.phone:
            parser.add_argument(
                '-p', '--phone-separator', metavar='<str>',
                default=separator.phone,
                help='Phone separator, default is "%(default)s".')

        if separator.syllable:
            parser.add_argument(
                '-s', '--syllable-separator', metavar='<str>',
                default=separator.syllable,
                help='Syllable separator, default is "%(default)s".')

        if separator.word:
            parser.add_argument(
                '-w', '--word-separator', metavar='<str>',
                default=separator.word,
                help='Word separator, default is "%(default)s".')

    parser.add_argument(
        '-o', '--output', default=sys.stdout, metavar='<output-file>',
        help='Output text file to write, if not specified write to stdout.')

    return parser


def parse_args(parser, log):
    """Open input and output streams from files or standard input/output

    Return a pair (streamin, streamout) that can be accessed through
    streamin.read()/readlines() and streamout.write() respectively.

    If `input` and `output` are strings, they are opened as regular
    files for reading/writing.

    """
    pass


def prepare_main(name=None, description=None,
                 separator=default_separator, add_arguments=None):
    log = get_logger(name=name)

    parser = get_parser(description=description, separator=separator)
    if add_arguments:
        add_arguments(parser)

    args = parser.parse_args()

    if args.quiet:
        level = logging.CRITICAL
    elif args.verbose == 0:
        level = logging.WARNING
    elif args.verbose == 1:
        level = logging.INFO
    else:  # verbose >= 2
        level = logging.DEBUG

    log.setLevel(level)
    log.debug('log level set to %s', logging.getLevelName(level))

    separator = Separator(
        phone=args.phone_separator if separator.phone else None,
        syllable=args.syllable_separator if separator.syllable else None,
        word=args.word_separator if separator.word else None)

    streamin = args.input
    if isinstance(streamin, str):
        streamin = codecs.open(streamin, 'r', encoding='utf8')

    streamout = args.output
    if isinstance(streamout, str):
        streamout = codecs.open(streamout, 'w', encoding='utf8')

    return streamin, streamout, separator, log, args
