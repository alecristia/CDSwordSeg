#!/usr/bin/env python
"""Script for analyzing a single file in the algoComp2015.1.0 project

Replaces the former segment_one_corpus.sh script. Run the file with
the '--help' option to get in.

Copyright 2015 Alex Cristia, Mathieu Bernard

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

ALGO_CHOICES = ['AGc3sf', 'AGu', 'TPs', 'dibs', 'dmcmc', 'ngrams', 'puddle']
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


def run_command(algo, algo_dir, command, clusterize=False):
    """Call the command as a subprocess or schedule it in the cluster"""
    ofile = os.path.join(algo_dir, algo + '.stdout')
    if clusterize:
        if CLUSTERIZABLE:
            fcommand = write_command(command)
            command = ('qsub -j y -V -cwd -o {} -N {} {}'
                       .format(ofile, algo, fcommand))
            res = subprocess.check_output(
                shlex.split(command))
            return res.split()[2] # job pid on the cluster
        else:
            print('qsub not detected, running the job on local host')

    return subprocess.Popen(shlex.split(command))


def wait_jobs(jobs_id, clusterize):
    """Wait all the jobs in list are terminated and return"""
    if clusterize:
        print('waiting for jobs...')
        fcommand = write_command('echo done')
        command = ('qsub -j y -V -cwd -o /dev/null -N waiting -sync yes '
                   '-hold_jid ' + ','.join(jobs_id) + ' ' + fcommand)
        subprocess.call(shlex.split(command), stdout=sys.stdout)
    else:
        for pid in jobs_id:
            print('waiting {}'.format(pid.pid))
            pid.wait()


def write_gold_file(tags, gold):
    """remove ;eword and ;esyll in tags to create gold"""
    with open(gold, 'w') as out:
        for line in open(tags, 'r').xreadlines():
            out.write(line.replace(';esyll', '')
                      .replace(' ', '')
                      .replace(';eword', ' ').strip() + '\n')


def algo_dict(algos, directory=CDSPATH):
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
        script = [s for s in scripts if algo in s][0]
        res[algo] = os.path.join(pipeline, script)
    return res


def parse_args():
    parser = argparse.ArgumentParser(description='')

    g1 = parser.add_argument_group('I/O parameters')
    g1.add_argument(
        'tagsfile', type=str,
        help='input tag file containing the utterances to segment in words. '
        'One phonologized utterance per line, with ;esyll and ;eword '
        'separators as outputed by the phonologizer')

    g1.add_argument(
        '-g', '--goldfile', type=str, default=None,
        help='gold file containing the gold version of the tags file, '
        'i.e. with ;esyll removed and ;eword replaced by a space. '
        'If not provided, compute it.')

    g1.add_argument(
        '--cds-dir', type=str, default=CDSPATH,
        help='algoComp directory in CDSwordSeg. default is {}'.format(CDSPATH))

    g1.add_argument(
        '-d', '--output-dir', type=str,
        default=os.path.join(os.path.curdir, 'results'),
        help='directory to write output files. Default is ./results. '
        "Each selected algo create it's own subdirectory in OUTPUT_DIR")

    g1.add_argument(
        '-k', '--keyname', type=str, default='key',
        help='base of generated intermediate files in OUTPUT_DIR')

    g1.add_argument(
        '-o', '--output-file', type=str, default=None,
        help='Main result file. Default is OUTPUT_DIR/KEYNAME-cfgold.txt')

    g2 = parser.add_argument_group('Computation parameters')
    g2.add_argument(
        '-a', '--algorithms', type=str, nargs='+', default=['dibs'],
        choices=ALGO_CHOICES + ['all'],
        metavar='ALGO',
        help='Choose algorithms in {}, or choose "all". '
        'Default is to compute dibs.'.format(ALGO_CHOICES))

    g2.add_argument(
        '-c', '--clusterize', action='store_true',
        help='enable parallel computations if the qsub command is detected')

    g2.add_argument(
        '--ag-debug', action='store_true',
        help='Setup the AGc3sf and AGu algorithm in debug configuration. '
        'This have no effect on other algorithms')

    return parser.parse_args()


def main():
    # parse input arguments and check for error
    args = parse_args()
    assert os.path.isfile(args.tagsfile), \
        'invalid input file {}'.format(args.tagsfile)
    assert os.path.isdir(args.cds_dir), \
        'invalid CDS dir {}'.format(args.cds_dir)

    if args.output_file is None:
        args.output_file = os.path.join(args.output_dir,
                                        args.keyname + '-cfgold.txt')

    if args.goldfile is None:
        base, ext = os.path.splitext(args.tagsfile)
        args.goldfile = base + '-gold' + ext
        write_gold_file(args.tagsfile, args.goldfile)
    else:
        assert os.path.isfile(args.goldfile), \
            'invalid input file {}'.format(args.goldfile)

    args.output_dir = os.path.abspath(args.output_dir)
    if not os.path.isdir(args.output_dir):
        os.mkdir(args.output_dir)

    # retrieve path to the script of each required algorithm
    script = algo_dict(args.algorithms, args.cds_dir)

    # prepare main result file with a header
    if not os.path.isfile(args.output_file):
        open(args.output_file, 'w').write(CFGOLD + '\n')

    jobs_id = []
    for algo in script.keys():
        # create a subdirectory to store intermediate files
        algo_dir = os.path.join(args.output_dir, algo)
        if not os.path.isdir(algo_dir):
            os.mkdir(algo_dir)

        # copy tags ang gold files in it (this is required by the
        # underlying scripts)
        shutil.copy(args.tagsfile,
                    os.path.join(algo_dir, args.keyname + '-tags.txt'))
        shutil.copy(args.goldfile,
                    os.path.join(algo_dir, args.keyname + '-gold.txt'))

        # generate the bash command to call
        command = ' '.join([script[algo],
                            args.cds_dir + '/',  # ABSPATH
                            args.keyname,        # KEYNAME
                            algo_dir + '/'])     # RESFOLDER
        if 'AG' in algo and args.ag_debug:
            command += ' debug'

        # call the script and do the computation
        jobs_id.append(run_command(algo, algo_dir, command, args.clusterize))

    # wait all the jobs terminate
    wait_jobs(jobs_id, args.clusterize)

    # finally collapse all the results
    print('all jobs terminated, collapse results in {}'
          .format(args.output_file))
    for algo in script.keys():
        if not algo == 'ngrams':
            # get the result score
            res_file = args.keyname + '-' + algo + '-cfgold-res.txt'
            algo_dir = os.path.join(args.output_dir, algo)
            res_file = os.path.join(algo_dir, res_file)

            # TODO fix this (change algo names in lower layers)
            # special case of AGu
            if algo == 'AGu':
                res_file = res_file.replace('AGu-', 'agU-')
            # special case of AGc3sf
            if algo == 'AGc3sf':
                res_file = res_file.replace('AGc3sf-', 'agc3s-')
            # special case for TPs
            elif algo == 'TPs':
                res_file = res_file.replace('TPs-', 'tpREL-')

            assert os.path.isfile(res_file), ('result file {} not found for '
                                              'algo {}'.format(res_file, algo))
            with open(os.path.join(algo_dir, res_file), 'r') as r:
                r.readline()  # consume 1st line (header)
                res_line = r.readline()

            # collapse it to the main output file
            open(args.output_file, 'a').write(algo + '\t' + res_line)


if __name__ == '__main__':
    # try:
    main()
    # except Exception as err:
    #     print('fatal error in {} : {}'.format(__file__, err))
    #     exit(1)
