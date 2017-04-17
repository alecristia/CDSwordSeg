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
from setuptools.command.install import install
from pkg_resources import resource_filename


PACKAGE_NAME = 'wordseg'
VERSION = '0.2'


# On Reads The Docs we don't install any package (for online
# documentation)
REQUIREMENTS = [] if os.environ.get('READTHEDOCS', None) else [
    'joblib',
    'pandas',
    'phonemizer>=0.3'
]


# from https://stackoverflow.com/questions/36187264
def binaries_directory():
    """Return the installation directory, or None"""
    if '--user' in sys.argv:
        paths = (site.getusersitepackages(),)
    else:
        py_version = '%s.%s' % (sys.version_info[0], sys.version_info[1])
        paths = (s % (py_version) for s in (
            sys.prefix + '/lib/python%s/dist-packages/',
            sys.prefix + '/lib/python%s/site-packages/',
            sys.prefix + '/local/lib/python%s/dist-packages/',
            sys.prefix + '/local/lib/python%s/site-packages/',
            '/Library/Python/%s/site-packages/',
        ))

    for path in paths:
        if os.path.exists(path):
            return path

    sys.stderr.write('no installation path found\n')
    return None


class CustomInstall(install):
    """Custom handler for the 'install' command

    * compile the C/C++ binaries of the wordseg package,
    * install the Python part
    * install the compiled binaries to the package install directory

    """
    def run(self):
        targets = ['wordseg-dmcmc']

        # compile all the C/C++ targets (just calling 'make' in their directory)
        for target in targets:
            path = os.path.join('.', 'segmentation', 'algos', target.replace('-', '_'))
            subprocess.check_call('make', cwd=path)

        # install the Python package in a regular way
        super().run()

        # install the compiled binaries
        for target in targets:
            path = os.path.join(sys.prefix, 'bin')
            self.execute(
                shutil.move, args=[os.path.join(
                    '.', 'segmentation', 'algos', target.replace('-', '_'),
                    'build', target), path],
                msg='Installing {} binary to {}'.format(target, path))


setup(
    name=PACKAGE_NAME,
    version=VERSION,
    packages=find_packages(),
    zip_safe=True,

    setup_requires=['pytest-runner'],
    tests_require=['pytest'],

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

    cmdclass={'install': CustomInstall},

    # metadata for upload to PyPI
    author='Alex Cristia',
    description='word segmentation from phonological-like text transcriptions',
    license='GPL3',
    url='https://github.com/alecrisita/CDSWordSeg',
    long_description=open('README.md').read()
)
