#!/usr/bin/env python
#
# Copyright 2015 - 2017 Alex Cristia, Mathieu Bernard
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

"""High-level wrapper on word segmentation algorithms

Takes a phonological-like text transcript and returns one or several
versions of the same corpus, with automatically-determined word
boundaries, as well as lists of the most frequent words, all this
based on a selection of algorithms (chosen by user).

The algorithms are running in parallel, either locally (with the
joblib Python library), or on a cluster using the qsub command (Sun
Grid Engine).

Run the script with the '--help' option to get in.

"""

import argparse
import os
import shlex
import shutil
import subprocess
import sys
import tempfile

from segmentation.wordseg_gold import gold_text


CDSPATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'algos')
"""The segmentation/algos directory in the CDSwordSeg sources tree"""


class NonAGSegmenter(object):
    """A general wrapper to non-AG word segmentation algorithms

    :param str algo: the segmentation algorithm to use, in supported_algos()
    :param str tags: the tags file of phonologized utterances to segment
    :param str output_dir: the output directory where to store the results
    :param str script_dir: algoComp/pipeline directory in CDSwordSeg

    This class creates output_dir, copy tags in it and create the
    command to be executed.

    """
    def __init__(self, algo, tags, gold, output_dir, script_dir=CDSPATH):
        # check the algo is supported
        if algo not in self.supported_algos():
            raise ValueError('unknown algo {}'.format(algo))
        self.algo = algo

        # get the absolute path to the algo script
        self.script = self._script(script_dir)
        if not os.path.isfile(self.script):
            raise ValueError('non-existing script {}'.format(self.script))

        # create the output dir and copy the tags and gold files in
        # it. Be conservative and do not overwrite any data in the
        # result directory.
        if os.path.isdir(output_dir):
            raise ValueError(
                'result directory already exists {}'.format(output_dir))
        if not os.path.isfile(tags):
            raise ValueError(
                'non-existing tags file {}'.format(tags))
        self.output_dir = output_dir
        os.mkdir(self.output_dir)
        shutil.copy(tags, os.path.join(self.output_dir, 'tags.txt'))
        shutil.copy(gold, os.path.join(self.output_dir, 'gold.txt'))

        # create the command launching the script
        self.command = ' '.join(
            [self.script,
             os.path.abspath(os.path.join(script_dir, '..')) + '/',  # ABSPATH
             self.output_dir + '/'])  # RESFOLDER

        self.ncores = self._ncores()

    def __repr__(self):
        """Return a string representation"""
        return ' -> '.join([self.algo, self.output_dir])

    @staticmethod
    def supported_algos():
        """Algorithms supported by this class"""
        return ['dibs', 'dmcmc', 'ngrams', 'puddle', 'TPs']

    def _ncores(self):
        try:
            return {'dmcmc': 5, 'puddle': 5}[self.algo]  # 5-fold xeval
        except KeyError:
            return 1

    def _script(self, script_dir):
        """Return the absolute path to the script behind self.algo"""
        return os.path.abspath(os.path.join(script_dir, self.algo + '.sh'))


class AGSegmenter(NonAGSegmenter):
    """A general wrapper to AG word segmentation algorithms

    Add the debug option in top of the NonAGSegmenter

    """
    def __init__(self, algo, tags, gold, output_dir,
                 script_dir=CDSPATH, debug=False):
        NonAGSegmenter.__init__(self, algo, tags, gold, output_dir, script_dir)

        self.command += ' ' + self.algo
        if debug:
            self.command += ' debug'
        self.ncores = 8

    @staticmethod
    def supported_algos():
        """Algorithms supported by the WordSegmenter class"""
        return ['AGc3sf', 'AGu']

    def _script(self, script_dir):
        """Return the absolute path to the script behind self.algo"""
        return os.path.abspath(os.path.join(script_dir, 'AG.sh'))


def supported_algos():
    return AGSegmenter.supported_algos() + NonAGSegmenter.supported_algos()


def create_nonag(algo, args):
    algo_dir = os.path.join(args.output_dir, algo)
    return NonAGSegmenter(
        algo, args.tagsfile, args.goldfile, algo_dir, args.cds_dir)


def create_ag(algo, args):
    # special case of AG median: run N jobs
    if args.ag_median > 1:
        jobs = []
        for i in range(1, args.ag_median+1):
            algo_dir = os.path.join(args.output_dir, algo + '_' + str(i))
            jobs.append(AGSegmenter(algo, args.tagsfile, args.goldfile,
                                    algo_dir, args.cds_dir, args.ag_debug))
        return jobs
    else:  # only one job
        algo_dir = os.path.join(args.output_dir, algo)
        return AGSegmenter(algo, args.tagsfile, args.goldfile,
                           algo_dir, args.cds_dir, args.ag_debug)


def create_jobs(args):
    """Return a list of initialized WordSegmenter instances"""
    algos = args.algorithms
    if algos == ['all']:
        algos = supported_algos()

    jobs = []
    for algo in algos:
        j = create_ag(algo, args) if 'AG' in algo else create_nonag(algo, args)
        if isinstance(j, list):
            jobs += j
        else:
            jobs.append(j)
    return jobs


def clusterizable():
    """Return True if the 'qsub' command is found in the PATH"""
    try:
        subprocess.check_output(shlex.split('which qsub'))
        return True
    except:
        return False


def write_command(command, bin='bash'):
    """Write a two lines script from command and return its path"""
    tfile = tempfile.mkstemp()[1]
    with open(tfile, 'w') as f:
        f.write('#!/usr/bin/env ' + bin + '\n')
        f.write(command + '\n')
    return tfile


def run_job(job, clusterize=False, basename='', log2file=True):
    """Call the command as a subprocess or schedule it in the cluster

    The log2file option can be set to False to log to stdout instead,
    this option only works when running jobs locally (i.e. with
    clusterize is False).

    basename is the prefix of the job name when using qsub.

    Return the job pid

    """
    ofile = os.path.join(job.output_dir, 'log')

    if clusterize and clusterizable():
        fcommand = write_command(job.command)
        jobname = job.algo if basename == '' else basename + '_' + job.algo
        print('name = {}'.format(jobname))
        ncores = ('-pe openmpi {}'.format(job.ncores)
                  if job.ncores != 1 else '')
        command = ('qsub {} -j y -V -cwd -o {} -N {} {}'
                   .format(ncores, ofile, jobname, fcommand))
        res = subprocess.check_output(shlex.split(command))
        return res.split()[2]  # job pid on the cluster
    else:
        ofile = (open(ofile, 'a') if log2file else sys.stdout)
        return subprocess.Popen(
            shlex.split(job.command),
            stdout=ofile,
            stderr=subprocess.STDOUT)


def wait_jobs(pids, clusterize):
    """Wait all the pids in list are terminated and return"""
    if clusterize and clusterizable():
        print('waiting for jobs...')
        fcommand = write_command('echo done')
        command = ('qsub -j y -V -cwd -o /dev/null -N waiting -sync yes '
                   '-hold_jid {} {}'.format(','.join(pids.values()), fcommand))
        subprocess.call(shlex.split(command), stdout=sys.stdout)
    else:
        for pid in pids.iteritems():
            print('waiting {} of pid {}'.format(pid[0].algo, pid[1].pid))
            pid[1].wait()


def parse_args():
    parser = argparse.ArgumentParser(
        description='This script is a segmentation pipeline binding a '
        'phonologized input to various word segmentation algorithms.')

    parser.add_argument(
        '-v', '--verbose', action='store_true',
        help='display some log during execution')

    parser.add_argument(
        '--log-to-stdout', action='store_true', help="""
        output log messages to stdout (by default log to OUTPUT_DIR/log)""")

    parser.add_argument(
        'tagsfile', type=str, metavar='TAGSFILE',
        help='input tag file containing the utterances to segment in words. '
        'One phonologized utterance per line, with ;esyll and ;eword '
        'separators as outputed by the phonologizer')

    gp1 = parser.add_argument_group('I/O optional parameters')
    # gp1.add_argument(
    #     '-g', '--goldfile', type=str, default=None,
    #     help='gold file containing the gold version of the tags file, '
    #     'i.e. with ;esyll removed and ;eword replaced by a space. '
    #     'If not provided, compute it')

    # gp1.add_argument(
    #     '--cds-dir', type=str, default=CDSPATH,
    #     help='algoComp/pipeline directory in CDSwordSeg. '
    #     'default is {}'.format(CDSPATH))

    gp1.add_argument(
        '-d', '--output-dir', type=str,
        default=os.path.curdir,
        metavar='OUTPUT_DIR',
        help='directory to write output files. Default is to write in `.` , '
        "each selected algo create it's own subdirectory in OUTPUT_DIR")

    gp2 = parser.add_argument_group('Computation parameters')
    gp2.add_argument(
        '-a', '--algorithms', type=str, nargs='+', default=['dibs'],
        choices=supported_algos() + ['all'], metavar='ALGO',
        help='choose algorithms in {}, or choose "all", '
        'default is to compute dibs.'.format(supported_algos()))

    gp2.add_argument(
        '-u', '--unit-representation', type=str, metavar='UNIT',
        choices=['phoneme', 'syllable'], default='phoneme',
        help='Representation unit to segment, must be "phoneme" or "syllable"')

    gp2.add_argument(
        '-c', '--clusterize', action='store_true',
        help='schedule jobs on the cluster if the qsub command is detected, '
        'else of if not specified, run jobs as parallel subproceses.')

    gp2.add_argument(
        '-j', '--jobs-basename', type=str, default='',
        help='if --clusterize, basename of scheduled jobs')

    gp2.add_argument(
        '-s', '--sync', action='store_true',
        help='wait all the jobs are terminated before exiting')

    gp3 = parser.add_argument_group('Adaptor Grammar specific parameters')
    gp3.add_argument(
        '--ag-debug', action='store_true',
        help='setup the AG algorithm in debug configuration, '
        'this have no effect on other algorithms')

    gp3.add_argument(
        '--ag-median', type=int, default=1, metavar='N',
        help='run the AG algorithms N times and return the median evaluation, '
        'default is N=1, this have no effect on other algorithms')

    return parser.parse_args()


def main():
    """Entry point of the segmentation pipeline"""
    # parse input arguments
    args = parse_args()

    # check that tags file and CDS dir exists
    assert os.path.isfile(args.tagsfile), \
        'invalid tags file {}'.format(args.tagsfile)
    assert os.path.isdir(args.cds_dir), \
        'invalid CDS dir {}'.format(args.cds_dir)

    # create the output dir if needed
    args.output_dir = os.path.abspath(args.output_dir)
    if not os.path.isdir(args.output_dir):
        os.makedirs(args.output_dir)

    # compute the gold file if not given
    if args.goldfile is None:
        base, ext = os.path.splitext(args.tagsfile)
        args.goldfile = base + '-gold' + ext

        if args.verbose:
            print('writing gold file to {}'.format(args.goldfile))

        gold = gold_text(open(args.tagsfile, 'r'))
        open(args.goldfile, 'w').write(gold)
    else:
        assert os.path.isfile(args.goldfile), \
            'invalid gold file {}'.format(args.goldfile)

    # create and run the segmentation jobs, store their pid
    jobs = create_jobs(args)
    pids = {}
    for job in jobs:
        pids[job] = run_job(job, args.clusterize, args.jobs_basename,
                            log2file=not args.log_to_stdout)

    if args.verbose:
        print('launched jobs are')
        for k, v in pids.iteritems():
            print('  {} : {}'.format(k, v if isinstance(v, str) else v.pid))

    # wait all the jobs terminate
    if args.sync:
        wait_jobs(pids, args.clusterize)


if __name__ == '__main__':
    #    main()
    try:
        main()
    except KeyboardInterrupt:
        print >> sys.stderr, 'Keyboard interruption, exiting'
        sys.exit(1)
    except Exception as err:
        print >> sys.stderr, 'Fatal error in {} : {}'.format(__file__, err)
        sys.exit(1)
