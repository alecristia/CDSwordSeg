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
import shutil
import site
import subprocess
import sys

from setuptools import setup, find_packages


PACKAGE_NAME = 'wordseg'
PACKAGE_VERSION = '0.2'


# On Reads The Docs we don't install any package (for online
# documentation)
REQUIREMENTS = [] if os.environ.get('READTHEDOCS', None) else [
    'joblib',
    'numpy',
    'pandas',
    'phonemizer>=0.3'
]

# a dict of wordseg scripts mapped to the C++ binary they are
# calling. We must have './segmentation/algos/wordseg_dmcmc/Makefile'
# that produces './segmentation/algos/wordseg_dmcmc/build/dpseg'
CPP_TARGETS = {'wordseg_dmcmc': 'dpseg'}


for cwd in CPP_TARGETS.keys():
    build_dir = os.path.join('segmentation', 'algos', cwd, 'build')
    print('compiling C++ dependencies for', cwd, 'in', build_dir)

    if not os.path.exists(build_dir):
        os.makedirs(build_dir)

    subprocess.call(['make'], cwd=os.path.join('segmentation', 'algos', cwd))


setup(
    name=PACKAGE_NAME,
    version=PACKAGE_VERSION,
    description='word segmentation from phonological-like text transcriptions',
    long_description=open('README.md').read(),
    author='Alex Cristia',
    url='https://github.com/alecrisita/CDSWordSeg',
    license='GPL3',

    packages=find_packages(),
    zip_safe=True,
    install_requires=REQUIREMENTS,
    setup_requires=['pytest-runner'],
    tests_require=['pytest'],

    dependency_links=[
        'https://github.com/bootphon/phonemizer/tarball/master#egg=phonemizer-0.3'
    ],

    entry_points={'console_scripts': [
        'wordseg-launcher = segmentation.wordseg_launcher:main',
        'wordseg-prep = segmentation.wordseg_prep:main',
        'wordseg-gold = segmentation.wordseg_gold:main',
        'wordseg-eval = segmentation.wordseg_eval:main',
        'wordseg-dibs = segmentation.algos.wordseg_dibs:main',
        'wordseg-dmcmc = segmentation.algos.wordseg_dmcmc:main',
        'wordseg-tp = segmentation.algos.wordseg_tp:main',
        'wordseg-puddle = segmentation.algos.wordseg_puddle:main',
        ]},

    data_files=[('bin', ['segmentation/algos/wordseg_dmcmc/build/dpseg'])],
)
