.. wordseg documentation master file, created by
   sphinx-quickstart on Thu Apr  6 20:18:12 2017.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to wordseg's documentation!
===================================

In this project, we seek to study a set of algorithms for word
segmentation from phonological-like text transcriptions.

Our current pipeline involves three steps:

1. Database creation.

   In this step, a set of conversations or transcriptions are
   processed to e.g. select specific speakers and remove annotations,
   leaving only the orthographic form of what was said.

2. Phonologization.

   Takes a (set of) orthographic (clean) output(s) and converts it
   (them) into a surface phonological form.

3. Segmentation.

   Takes a phonological-like text transcript and returns one or
   several versions of the same corpus, with automatically-determined
   word boundaries, as well as lists of the most frequent words, and
   all this based on a selection of algorithms (chosen by
   user). Within Oberon, DiBS, TP, and PUDDLE work out of the box; AGu
   and AG3fs require python-anaconda so make sure to load this module;
   and DMCMC will require you to build a program first (only once in
   your local environment). It is also extremely resource and
   time-consuming, so please ponder carefully whether you actually
   need it for your research question.


.. toctree::
   :maxdepth: 2
   :caption: Contents:

   installation
   algorithms
   pipeline
   modules
