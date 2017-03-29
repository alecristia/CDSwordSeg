#!/usr/bin/env python
#
# Copyright 2015, 2016 Mathieu Bernard
#
# This file is part of wordseg: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# wordseg is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with wordseg. If not, see <http://www.gnu.org/licenses/>.
"""Setup script for the wordseg package"""

from setuptools import setup, find_packages

VERSION = '0.2'

setup(
    name='wordseg',
    version=VERSION,
    packages=find_packages(),
    zip_safe=True,

    # python package dependancies
    install_requires=['joblib'],

    # define the command-line script to use
    entry_points={'console_scripts': [
        'wordseg-launcher = segmentation.wordseg_launcher:main',
        'wordseg-gold = segmentation.wordseg_gold:main',
        'wordseg-eval = segmentation.wordseg_eval:main',
        'wordseg-tp = segmentation.algos.wordseg_tp:main']},

    # metadata for upload to PyPI
    author='Alex Cristia',
    description='word segmentation from phonological-like text transcriptions',
    license='GPL3',
    url='https://github.com/alecrisita/CDSWordSeg',
    long_description=open('README.md').read()
)
