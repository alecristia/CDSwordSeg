#!/usr/bin/env python
#
# Copyright 2015-2017 Mathieu Bernard
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

"""Bayesian word segmentation algorithm.

See Goldwater, Griffiths, Johnson (2010) and Phillips & Pearl (2014).

1. Uses a hierarchical Pitman-Yor process rather than a hierarchical
   Dirichlet process model.  The HDP model can be recovered by setting
   the PY parameters appropriately (set --a1 and --a2 to 0, --b1 and
   --b2 then correspond to the HDP parameters).

2. Implements several different estimation procedures, including the
   original Gibbs sampler (*flip sampler*) as well as a sentence-based
   Gibbs sampler that uses dynamic programming (*tree sampler*) and a
   similar dynamic programming algorithm that chooses the best
   segmentation of each utterance rather than a sample.  The latter
   two algorithms can be run either in batch mode or in online mode.
   If in online mode, they can also be set to "forget" parts of the
   previously analysis.  This is described in more detail below.

3. Functionality for using separate training and testing files.  If
   you provide an evaluation file, the program will first run through
   its full training procedure (i.e., using whichever algorithm for
   however many iterations, kneeling, etc.).  After that, it will
   freeze the lexicon in whatever state it is in and then make a
   single pass through the evaluation data, segmenting each sentence
   according to the probabilities computed from the frozen lexicon.
   No new words/counts will be added to the lexicon during evaluation.
   Evaluation can be set to either sample segmentations or choose the
   maximum probability segmentation for each utterance.  Scores will
   be printed out at the end of the complete run based on either the
   evaluation data (if provided) or the training data (if not).

"""

import joblib
import pkg_resources
import re
import shlex
import subprocess
import tempfile
# import threading

from segmentation import utils, folding


DPSEG_BIN = pkg_resources.resource_filename(
    pkg_resources.Requirement.parse('wordseg'),
    'segmentation/algos/wordseg_dmcmc/build/dpseg')


class UnicodeGenerator(object):
    """Iterate on unicode characters starting at code `start`

    Exclude the space characters. This class is a perl to python
    simplified transcription of the original script
    create-unicode-dict-flexible.pl

    """
    def __init__(self, start=3001):
        self.index = start

    def __call__(self):
        char = chr(self.index)
        while re.match('\s', char):
            self.index += 1
            char = chr(self.index)
        self.index += 1
        return char


def _dpseg(text, args, log=utils.null_logger()):
    with tempfile.NamedTemporaryFile() as tmp:

        command = ('{} --output-file {} --debug-level 1000 {}'
                   .format(DPSEG_BIN, tmp.name, args))
        log.debug('running "%s"', command)

        job = subprocess.Popen(
            shlex.split(command),
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)

        out, err = job.communicate(('\n'.join(text) + '\n').encode('utf8'))
        # job.wait()

        for line in (line for line in out.decode().split('\n') if line):
            log.debug(line.strip())
        for line in (line for line in err.decode().split('\n') if line):
            log.error(line.strip())

        if job.returncode:
            raise RuntimeError(
                'failed with error code {}'.format(job.returncode))

        # # join the command output to log (from
        # # https://stackoverflow.com/questions/35488927)
        # def consume_lines(pipe, consume):
        #     with pipe:
        #         # NOTE: workaround read-ahead bug
        #         for line in iter(pipe.readline, b''):
        #             consume(line)
        #         consume('\n')

        # threading.Thread(
        #     target=consume_lines,
        #     args=[job.stdout, lambda line: log.debug(line)]).start()

        tmp.seek(0)
        return tmp.read().decode('utf8').split('\n')


def segment(text, nfolds=5, njobs=1,
            args='--ngram 1 --a1 0 --b1 1', log=utils.null_logger()):
    """Run the 'dpseg' binary on `nfolds` folds"""
    # force the text to be a list of utterances
    text = list(text)

    # set of unique units (syllables or phones) present in the text
    units = set(unit for utt in text for unit in utt.split())
    log.info('%s units found in %s utterances', len(units), len(text))

    # create a unicode equivalent for each unit and convert the text
    # to that unicode version
    log.debug('converting input to unicode')
    unicode_gen = UnicodeGenerator()
    unicode_mapping = {unit: unicode_gen() for unit in units}
    unicode_text = [''.join(unicode_mapping[unit] for unit in utt.split()) for utt in text]

    log.debug('building %s folds', nfolds)
    folded_texts, fold_index = folding.fold(unicode_text, nfolds, dmcmc_bugfix=True)

    segmented_texts = joblib.Parallel(n_jobs=njobs, verbose=0)(
        joblib.delayed(_dpseg)(fold, args, log=log) for fold in folded_texts)

    log.debug('unfolding the %s folds', nfolds)
    output_text = folding.unfold(segmented_texts, fold_index)

    # convert the text back to unit level (from unicode level)
    log.debug('converting output back from unicode')
    unit_mapping = {v: k for k, v in unicode_mapping.items()}
    unit_mapping[' '] = ' '
    segmented_text = [''.join(unit_mapping[char] for char in utt) for utt in output_text]

    return segmented_text


class Argument(object):
    """Argument read from a binary and sent to argparse"""
    # a list of dpseg options we don't want to expose in wordseg-dmcmc
    excluded = ['--help', '--config-file', '--debug-level', '--data-file',
                '--data-start-index', '--data-num-sents',
                '--eval-start-index', '--eval-num-sents',
                '--output-file', '--nsubjects']

    def __init__(self, name=None, default=None,  help=''):
        self.name = name
        self.default = default
        self.help = help

    def is_valid(self):
        if not self.name:
            return False
        if self.name in self.excluded:
            return False
        return True

    def send(self):
        self.help += ', default is "%(default)s"'
        return self

    def add(self, parser):
        parser.add_argument(self.name, default=self.default,
                            help=self.help, metavar='<arg>')


def yield_dpseg_arguments():
    # get the help message of the dpseg program
    help_msg= subprocess.Popen(
        [DPSEG_BIN, '--help'],
        stderr=subprocess.PIPE).communicate()[1].decode()

    # parse the message line by line to build arguments for argparse
    short_opts = '\s+-\w \[ (--[\w_\-]+) \]'
    long_opts = '\s+(--[\w_\-]+)'
    argument_re = ('({}|{})\s*'
                   '(arg)?\s*(\(\=([a-zA-Z0-9\._\-\s]+)\))?(.*)'
                   .format(short_opts, long_opts))

    argument = Argument()
    for line in help_msg.split('\n'):
        m = re.match(argument_re, line)
        if m:  # continuation of the previous help message
            # yield the previous argument
            if argument.is_valid():
                yield argument.send()
            argument = Argument()

            argument.name = m.group(2) if m.group(2) else m.group(3)
            argument.default = (m.group(6).replace('(=', '').replace(')', '')
                                if m.group(6) else None)
            argument.help = m.group(7).strip()
        else:  # the regext is not matched: this is the continuation
               # of a help message
            argument.help += ' ' + line.strip()

    if argument.is_valid():
        argument.help += ', default is %(default)s'
        yield argument.send()


def add_arguments(parser):
    """Add algorithm specific options to the parser"""
    parser.add_argument(
        '-f', '--nfolds', type=int, metavar='<int>', default=5,
        help='number of folds to segment the text on, default is %(default)s')

    parser.add_argument(
        '-j', '--njobs', type=int, metavar='<int>', default=1,
        help='number of parallel jobs to use, default is %(default)s')

    group = parser.add_argument_group('algorithm options')
    for arg in yield_dpseg_arguments():
        arg.add(group)


@utils.CatchExceptions
def main():
    """Entry point of the 'wordseg-dmcmc' command"""
    streamin, streamout, _, log, args = utils.prepare_main(
        name='wordseg-dmcmc',
        description=__doc__,
        add_arguments=add_arguments)

    assert args.nfolds > 0

    ignored_args = ['verbose', 'quiet', 'input', 'output', 'nfolds', 'njobs']
    dpseg_args = {k: v for k, v in vars(args).items() if k not in ignored_args and v}
    dpseg_args = ' '.join(
        '--{} {}'.format(k, v) for k, v in dpseg_args.items()).replace('_', '-')

    segmented = segment(
        streamin, nfolds=args.nfolds, njobs=args.njobs, args=dpseg_args, log=log)
    streamout.write('\n'.join(segmented) + '\n')


if __name__ == '__main__':
    main()
