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

"""Provide facilities for parsing common options in wordseg commands"""

import sys


def add_input_output(parser):
    """Add input and output arguments to the `parser`"""
    parser.add_argument(
        'input', default=sys.stdin, nargs='?', metavar='<input-file>',
        help='input text file to read, if not specified read from stdin')

    parser.add_argument(
        '-o', '--output', default=sys.stdout, metavar='<output-file>',
        help='output text file to write, if not specified write to stdout')

    return parser


def add_separators(parser, phone=' ', syllable=';esyll', word=';eword'):
    """Add token separators options to the `parser`

    Set `phone`, `syllable` and `word` to the default value you want
    they have in the parser, or set to False to disable them.

    """
    if not phone and not syllable and not word:
        return parser

    if phone:
        parser.add_argument(
            '-p', '--phone-separator', metavar='<str>', default=phone,
            help='phone separator, default is "%(default)s"')
    if syllable:
        parser.add_argument(
            '-s', '--syllable-separator', metavar='<str>', default=syllable,
            help='''syllable separator, default is "%(default)s"''')
    if word:
        parser.add_argument(
            '-w', '--word-separator', metavar='<str>', default=word,
            help='word separator, default is "%(default)s"')

    return parser
