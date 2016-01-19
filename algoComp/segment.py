#!/usr/bin/env python
"""Script for analyzing a single file in the algoComp2015.1.0 project

Replaces the former segment_one_corpus.sh script. Run the file with
the '--help' option to get in.

Copyright 2015, 2016 Alex Cristia, Mathieu Bernard

"""

import argparse
import os
import shlex
import shutil
import subprocess
import sys
import tempfile


CDSPATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'pipeline')
"""The algoComp/pipeline directory in CDSwordSeg"""


class NonAGSegmenter(object):
    """A general wrapper to non-AG word segmentation algorithms

    :param str algo: the segmentation algorithm to use, in supported_algos()
    :param str tags: the tags file of phonologized utterances to segment
    :param str output_dir: the output directory where to store the results
    :param str script_dir: algoComp/pipeline directory in CDSwordSeg

    This class creates output_dir, copy tags in it and create the
    command to be executed.

    """
    def __init__(self, algo, tags, output_dir, script_dir=CDSPATH):
        # check the algo is supported
        if algo not in self.supported_algos():
            raise ValueError('unknown algo {}'.format(algo))
        self.algo = algo

        # get the absolute path to the algo script
        self.script = self._script(script_dir)
        if not os.path.isfile(self.script):
            raise ValueError('non-existing script {}'.format(self.script))

        # create the output dir and copy the tags file in it. Be
        # conservative and do not overwrite any data in the result
        # directory
        if os.path.isdir(output_dir):
            raise ValueError('result directory already exists {}'
                             .format(output_dir))
        if not os.path.isfile(tags):
            raise ValueError('non-existing tags file {}'
                             .format(tags))
        os.mkdir(output_dir)
        shutil.copy(tags, os.path.join(output_dir, 'tags.txt'))

        # create the command lanuching the script
        self.command = ' '.join([self.script,
                                 os.join(script_dir, '..') + '/',  # ABSPATH
                                 self.output_dir + '/'])           # RESFOLDER

    @staticmethod
    def supported_algos():
        """Algorithms supported by this class"""
        return ['dibs', 'dmcmc', 'ngrams', 'puddle', 'TPs']

    def _script(self, script_dir):
        """Return the absolute path to the script behind self.algo"""
        return os.path.abspath(os.path.join(script_dir, self.algo + '.sh'))


class AGSegmenter(NonAGSegmenter):
    def __init__(self, algo, tags, output_dir,
                 script_dir=CDSPATH, debug=False):
        NonAGSegmenter.__init__(self, algo, tags, output_dir, script_dir)

        self.command += ' ' + self.algo
        if debug:
            self.command += ' debug'

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
    return NonAGSegmenter(algo, args.tagsfile, algo_dir, args.cds_dir)


def create_ag(algo, args):
    # special case of AG median: run N jobs
    if args.ag_median > 1:
        jobs = []
        for i in range(1, args.ag_median+1):
            algo_dir = os.path.join(args.output_dir, algo + '_' + str(i))
            jobs.append(AGSegmenter(algo, args.tagsfile, algo_dir,
                                    args.cds_dir, args.ag_debug))
        return jobs
    else:  # only one job
        algo_dir = os.path.join(args.output_dir, algo)
        return AGSegmenter(algo, args.tagsfile, algo_dir,
                           args.cds_dir, args.ag_debug)


def create_jobs(args):
    """Return a list of initialized WordSegmenter instances"""
    if args.algos == 'all':
        args.algos = supported_algos()

    jobs = []
    for algo in args.algos:
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

CLUSTERIZABLE = clusterizable()


def write_command(command, bin='bash'):
    """Write a two lines script from command and return its path"""
    tfile = tempfile.mkstemp()[1]
    with open(tfile, 'w') as f:
        f.write('#!/usr/bin/env ' + bin + '\n')
        f.write(command + '\n')
    return tfile


def run_job(job, clusterize=False, basename=''):
    """Call the command as a subprocess or schedule it in the cluster"""
    ofile = os.path.join(job.output_dir, 'log')
    if clusterize and CLUSTERIZABLE:
        fcommand = write_command(job.command)
        jobname = job.algo if basename == '' else basename + '_' + job.algo
        print('name = {}'.format(jobname))
        command = ('qsub -j y -V -cwd -o {} -N {} {}'
                   .format(ofile, jobname, fcommand))
        res = subprocess.check_output(shlex.split(command))
        return res.split()[2]  # job pid on the cluster
    else:
        return subprocess.Popen(shlex.split(command),
                                stdout=open(ofile, 'a'),
                                stderr=subprocess.STDOUT)


def wait_jobs(jobs_id, clusterize):
    """Wait all the jobs in list are terminated and return"""
    if clusterize and CLUSTERIZABLE:
        print('waiting for jobs...')
        fcommand = write_command('echo done')
        command = ('qsub -j y -V -cwd -o /dev/null -N waiting -sync yes '
                   '-hold_jid {} {}'.format(','.join(jobs_id.values()),
                                            fcommand))
        subprocess.call(shlex.split(command), stdout=sys.stdout)
    else:
        for pid in jobs_id.iteritems():
            print('waiting {} of pid {}'.format(pid[0], pid[1].pid))
            pid[1].wait()


# TODO review this function
def write_gold_file(tags, gold):
    """remove ;eword and ;esyll in tags to create gold"""
    with open(gold, 'w') as out:
        for line in open(tags, 'r').xreadlines():
            goldline = (line.replace(';esyll', '')
                        .replace(' ', '')
                        .replace(';eword', ' ').strip())
            # remove multiple contiguous spaces
            goldline = ' '.join(goldline.split())
            out.write(goldline + '\n')


def parse_args():
    parser = argparse.ArgumentParser(
        description='This script is a segmentation pipeline binding a '
        'phonologized input to various word segmentation algorithms.')

    parser.add_argument(
        '-v', '--verbose', action='store_true',
        help='display some log during execution')

    parser.add_argument(
        'tagsfile', type=str,  metavar='TAGSFILE',
        help='input tag file containing the utterances to segment in words. '
        'One phonologized utterance per line, with ;esyll and ;eword '
        'separators as outputed by the phonologizer')

    g1 = parser.add_argument_group('I/O optional parameters')

    g1.add_argument(
        '-g', '--goldfile', type=str, default=None,
        help='gold file containing the gold version of the tags file, '
        'i.e. with ;esyll removed and ;eword replaced by a space. '
        'If not provided, compute it')

    g1.add_argument(
        '--cds-dir', type=str, default=CDSPATH,
        help='algoComp/pipeline directory in CDSwordSeg. '
        'default is {}'.format(CDSPATH))

    g1.add_argument(
        '-d', '--output-dir', type=str,
        default=os.path.curdir,
        help='directory to write output files. Default is to write in `.` , '
        "each selected algo create it's own subdirectory in OUTPUT_DIR")

    g2 = parser.add_argument_group('Computation parameters')
    g2.add_argument(
        '-a', '--algorithms', type=str, nargs='+', default=['dibs'],
        choices=supported_algos() + ['all'],
        metavar='ALGO',
        help='choose algorithms in {}, or choose "all", '
        'default is to compute dibs.'.format(supported_algos()))

    g2.add_argument(
        '-c', '--clusterize', action='store_true',
        help='schedule jobs on the cluster if the qsub command is detected, '
        'else of if not specified, run jobs as parallel subproceses.')

    g2.add_argument(
        '-j', '--jobs-basename', type=str, default='',
        help='if --clusterize, basename of scheduled jobs')

    g2.add_argument(
        '-s', '--sync', action='store_true',
        help='wait all the jobs are terminated before exiting')

    g3 = parser.add_argument_group('Adaptor Grammar specific parameters')
    g3.add_argument(
        '--ag-debug', action='store_true',
        help='setup the AG algorithm in debug configuration, '
        'this have no effect on other algorithms')

    g3.add_argument(
        '--ag-median', type=int, default=1, metavar='N',
        help='run the AG algorithms N times and return the median evaluation, '
        'default is N=1, this have no effect on other algorithms')

    args = parser.parse_args()
    if args.verbose:
        print('parsed arguments are:\n  '
              + str(args).replace('Namespace(', '').replace(', ', '\n  ')[:-1])

    return args


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
    assert not os.path.isdir(args.output_dir), \
        'result directory already exists: {}'.format(args.output_dir)
    os.mkdir(args.output_dir)

    # compute the gold file if not given
    if args.goldfile is None:
        base, ext = os.path.splitext(args.tagsfile)
        args.goldfile = base + '-gold' + ext

        if args.verbose:
            print('writing gold file to {}'.format(args.goldfile))

        write_gold_file(args.tagsfile, args.goldfile)
    else:
        assert os.path.isfile(args.goldfile), \
            'invalid gold file {}'.format(args.goldfile)

    # create and run the segmentation jobs
    jobs = create_jobs(args)
    pids = {}
    for job in jobs:
        pids[job] = run_job(job, args.clusterize, args.jobs_basename)

    # wait all the jobs terminate
    if args.sync:
        wait_jobs(pids, args.clusterize)
    else:
        print('launched jobs are')
        for k, v in jobs.iteritems():
            print('  {} : {}'.format(k, v))


if __name__ == '__main__':
    try:
        main()
    except Exception as err:
        print >> sys.stderr, 'fatal error in {} : {}'.format(__file__, err)
        exit(1)
