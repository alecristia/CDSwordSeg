# Copyright 2017 Mathieu Bernard, Elin Larsen
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

"""Test of the segmentation pipeline from raw text to eval"""

import os
import re
import pytest

from segmentation import Separator
from segmentation.wordseg_gold import gold_text
from segmentation.wordseg_prep import prepare_text
from segmentation.algos import (
    wordseg_tp, wordseg_dibs, wordseg_puddle, wordseg_dmcmc)


algos = {
    'dibs': wordseg_dibs,
    'dmcmc': wordseg_dmcmc,
    'puddle': wordseg_puddle,
    'tp': wordseg_tp}


def load_tags():
    _file = os.path.join(os.path.dirname(__file__), 'data', 'tags.txt')
    text = open(_file, 'r').readlines()
    return [line.strip() for line in text if len(line.strip())]


text = load_tags()


@pytest.mark.parametrize('algo', algos)
def test_pipeline(algo):
    # the token separator we use in the whole pipeline
    separator = Separator(phone=' ', syllable=';esyll', word=';eword')

    # build the gold version from the phonologized one
    gold = list(gold_text(text, separator=separator))

    # prepare the text for segmentation
    prepared_text = list(prepare_text(text, separator=separator))

    # segment it with the given algo (use default options)
    segmented = list(algos[algo].segment(prepared_text))

    assert len(gold) == len(text)
    assert len(text) == len(text)
    assert len(prepared_text) == len(text)
    assert len(segmented) == len(text)
    for i in range(len(text)):
        print()
        print(re.sub('\s', '', gold[i]))
        print(re.sub('\s', '', segmented[i]))
        assert re.sub('\s', '', segmented[i]) == re.sub('\s', '', gold[i])

    # TODO add the evaluation here
