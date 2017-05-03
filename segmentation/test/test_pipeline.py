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

import pytest

from segmentation import Separator
from segmentation.wordseg_gold import gold_text
from segmentation.wordseg_prep import prepare_text
from segmentation.wordseg_eval import evaluate
from segmentation.algos import (
    wordseg_tp, wordseg_dibs, wordseg_puddle, wordseg_dpseg)

from . import tags


algos = {
    'dibs': wordseg_dibs,
    'dpseg': wordseg_dpseg,
    'puddle': wordseg_puddle,
    'tp': wordseg_tp}


@pytest.mark.parametrize('algo', algos)
def test_pipeline(algo, tags):
    # the token separator we use in the whole pipeline
    separator = Separator(phone=' ', syllable=';esyll', word=';eword')

    # build the gold version from the tags
    gold = list(gold_text(tags, separator=separator))
    assert len(gold) == len(tags)
    for a, b in zip(gold, tags):
        assert separator.remove(a) == separator.remove(b)

    # prepare the text for segmentation
    prepared_text = list(prepare_text(tags, separator=separator))
    assert len(prepared_text) == len(tags)
    for a, b in zip(prepared_text, tags):
        assert separator.remove(a) == separator.remove(b)

    # segment it with the given algo (use default options)
    segmented = list(algos[algo].segment(prepared_text))

    s = separator.remove
    assert len(segmented) == len(tags)
    for n, (a, b) in enumerate(zip(segmented, tags)):
        assert s(a) == s(b), 'line {}: "{}" != "{}"'.format(n+1, s(a), s(b))

    results = evaluate(segmented, gold)
    assert len(results.keys()) % 3 == 0
    for v in results.values():
        assert v >= 0
        assert v <= 1
