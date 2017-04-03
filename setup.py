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

import os
from setuptools import setup, find_packages


VERSION = '0.2'

# On Reads The Docs we don't install any package (for online
# documentation)
ON_RTD = os.environ.get('READTHEDOCS', None) == 'True'
REQUIREMENTS = [] if ON_RTD else [
    'joblib',
    'pandas',
    'phonemizer>=0.3'
]

setup(
    name='wordseg',
    version=VERSION,
    packages=find_packages(),
    zip_safe=True,

    # install some dependencies directly from github
    dependency_links=[
        'https://github.com/bootphon/phonemizer/tarball/master'
        '#egg=phonemizer-0.3'
    ],

    # python package dependancies
    install_requires=REQUIREMENTS,

    # define the command-line script to use
    entry_points={'console_scripts': [
        'wordseg-launcher = segmentation.wordseg_launcher:main',
        'wordseg-prep = segmentation.wordseg_prep:main',
        'wordseg-gold = segmentation.wordseg_gold:main',
        'wordseg-eval = segmentation.wordseg_eval:main',
        'wordseg-dibs = segmentation.algos.wordseg_dibs:main',
        'wordseg-tp = segmentation.algos.wordseg_tp:main',
        'wordseg-puddle = segmentation.algos.wordseg_puddle:main',
        ]
        },

    # metadata for upload to PyPI
    author='Alex Cristia',
    description='word segmentation from phonological-like text transcriptions',
    license='GPL3',
    url='https://github.com/alecrisita/CDSWordSeg',
    long_description=open('README.md').read()
)
