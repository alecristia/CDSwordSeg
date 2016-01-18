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


CFGOLD = ('algo token_f-score token_precision token_recall '
          'boundary_f-score boundary_precision boundary_recall')

CDSPATH = os.path.dirname(os.path.abspath(__file__))
"""The algoComp directory in CDSwordSeg"""

ALGO_CHOICES = sorted(
    ['AGc3sf', 'AGu', 'TPs', 'dibs', 'dmcmc', 'ngrams', 'puddle'],
    key=str.lower)
"""Algorithms provided in the algoComp pipeline"""


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


def run_command(algo, algo_dir, command, clusterize=False, basename=''):
    """Call the command as a subprocess or schedule it in the cluster"""
    ofile = os.path.join(algo_dir, 'log')
    if clusterize and CLUSTERIZABLE:
        fcommand = write_command(command)
        jobname = algo if basename == '' else basename + '_' + algo
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


def algo_dict(algos, directory=CDSPATH, verbose=False):
    """Returns a map of `algos` to *.sh scripts in `directory`/pipeline"""
    # get the list of algo bash scripts
    pipeline = os.path.join(directory, 'pipeline')
    scripts = [f for f in os.listdir(pipeline) if '.sh' in f]

    # check for correct algos
    if 'all' in algos:
        algos = ALGO_CHOICES
    else:
        for algo in algos:
            assert algo in ALGO_CHOICES, 'unknown algo {}'.format(algo)

    # fill the resulting dict
    res = {}
    for algo in algos:
        algo_id = 'AG' if 'AG' in algo else algo
        script = [s for s in scripts if algo_id in s][0]
        res[algo] = os.path.join(pipeline, script)
    return res


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
        help='algoComp directory in CDSwordSeg. default is {}'.format(CDSPATH))

    g1.add_argument(
        '-d', '--output-dir', type=str,
        default=os.path.curdir,
        help='directory to write output files. Default is to write in `.` , '
        "each selected algo create it's own subdirectory in OUTPUT_DIR")

    g2 = parser.add_argument_group('Computation parameters')
    g2.add_argument(
        '-a', '--algorithms', type=str, nargs='+', default=['dibs'],
        choices=ALGO_CHOICES + ['all'],
        metavar='ALGO',
        help='choose algorithms in {}, or choose "all", '
        'default is to compute dibs.'.format(ALGO_CHOICES))

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



    # mapping from algo name to script absolute path
    scripts = algo_dict(args.algorithms, args.cds_dir, args.verbose)

    # mapping from algo name to pid
    jobs = {}

    # The main loop running all algos on the tags data
    for algo in scripts.keys():
        # create a subdirectory to store intermediate files. Be
        # conservative and do not overwrite any data in the result
        # directory
        algo_dir = os.path.join(args.output_dir, algo)
        assert not os.path.isdir(algo_dir), \
            'result directory already exists: {}'.format(algo_dir)
        os.mkdir(algo_dir)

        # copy tags ang gold files in it (this is required by the
        # underlying scripts)
        shutil.copy(args.tagsfile, os.path.join(algo_dir, 'tags.txt'))
        shutil.copy(args.goldfile, os.path.join(algo_dir, 'gold.txt'))

        # generate the bash command to call
        command = ' '.join([scripts[algo],
                            args.cds_dir + '/',  # ABSPATH
                            algo_dir + '/'])     # RESFOLDER

        # special case of AG algos: specify grammar and debug mode
        if 'AG' in algo:
            command += ' ' + algo
            if args.ag_debug:
                command += ' debug'

        # special case of AG median: run N jobs
        if 'AG' in algo and args.ag_median > 1:
            commands = [command] * args.ag_median

            for i, c in enumerate(commands, 1):  # modify RESFOLDER
                c = c.split()
                c[3] = c[3][:-1] + '_' + str(i) + '/'
                print(c[3])
                print(c)
                # # call the script and get back the pid
                # jobs[algo] = run_command(
                #     algo, algo_dir, c, args.clusterize, args.jobs_basename)
        else:
            # call the script and get back the pid
            print(command)
            # jobs[algo] = run_command(
            #     algo, algo_dir, command, args.clusterize, args.jobs_basename)

    # wait all the jobs terminate
    if args.sync:
        wait_jobs(jobs, args.clusterize)
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
