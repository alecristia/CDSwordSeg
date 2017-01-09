==============================
Instructions for text analyses
==============================

Copyright (C) 2015, 2016 by Alex Cristia, Xuan Nga Cao, Mathieu Bernard

For questions contact Alex Cristia alecristia@gmail.com

Overview
========

In this project, we seek to study a set of algorithms for word
segmentation from phonological-like text transcriptions.

Our current pipeline involves three steps:

1. Database creation. In this step, a set of conversations or
   transcriptions are processed to e.g. select specific speakers and
   remove annotations, leaving only the orthographic form of what was
   said.

2. Phonologization. Takes a (set of) orthographic (clean) output(s)
   and converts it (them) into a surface phonological form.

3. Segmentation. Takes a phonological-like text transcript and returns
   one or several versions of the same corpus, with
   automatically-determined word boundaries, as well as lists of the
   most frequent words, and all this based on a selection of
   algorithms (chosen by user). Within Oberon, DiBS, TP, and PUDDLE work out of the box;
   AGu and AG3fs require python-anaconda so make sure to load this module;
   and DMCMC will require you to build a program first (only once in your local environment). It is also extremely resource
   and time-consuming, so please ponder carefully whether you actually need it for
   your research question.

Recipes
-------

These three steps are packaged together in corpora dependant
recipes. Examples of previous recipes can be found in the recipes 
folder; these are corpora that include child-directed speech and 
sometimes also adult-directed speech, for instance:

- bernstein: based on only one corpus, that of Nan Bernstein; contains both chid and adult directed speech
- WinnipegLENA: based on a corpus that is not CHAT formatted (includes "translation" to cha)
- childes: based on a selection of English-spoken CHILDES corpora
- arglongitudinal: probably the most explicit and easy to follow recipe; contains a README explaining step by step how it was created

To build your own recipe, we suggest you look at those recipes. 
You can also do it your own way from the instructions below.


Making a new grammar
-------
- Duplicate an extant grammar (extension .lt) in CDSWordSeg/algoComp/algos/AG/grammars
- Rename
- for colloc0, you just need to change the terminals to the phonemes found in your corpus
- for colloc3syllfnc, you need to verify whether the language to be segmented is indeed head initial (like all th e grammars we have so far) or head-final (invert fnc word & content word in all appearances); and check also whether the langauage you are segmenting has a more complex syllable structure than english or different word shapes (e.g. for CatSpa we had to add words with up to 8 syllables)
- Duplicate a grammar caller in CDSWordSeg/algoComp/algos/AG (extension .sh)
- Modify the grammar being called at the top to the new file you just worked on
- that's it!

Building DMCMC
------
- Navigate to CDSWordSeg/algoComp/algos/phillips-pearl2014/dpseg_files
- do $ make -f Makefile2
- do $ chmod +x dpseg
- do $ cp dpseg ..

STEP 1: Database creation
=========================

The necessary scripts are found in the folder called `database_creation`

Alternative 1: .trs files from WinnipegLENA corpus
--------------------------------------------------

1. Open and adapt one of the trs2cha scripts,
   e.g. scripts/trs2cha_201511.text (creates 3 selections) or
   scripts/trs2cha_all.text (collapses across all addressees). You
   need to pay attention to the variables at the top

    - the trs folder is where your trs files are;

    - the cha folder will be created so pick anything you want. (A
      reasonable option is that the folder is sister to the trs folder.)

2. **IMPORTANT** ALSO notice that there is a section in the middle
   that needs to be changed to select subsets of sentences! There is
   more explanation in comments (lines starting with #) in the middle
   of `scripts/trs2cha_all.text`.

3. In a terminal window, navigate to the scripts subfolder of your
   database_creation folder, e.g. :

    $ cd /home/rolthiolliere/Documents/database_creation/scripts

  (you don't type the "$" -- this is just a convention to indicate that
  a line is copied + pasted into a terminal window)

4. Now run the script from the terminal window by typing:

    $ ./trs2cha_201511.text #or whatever name you gave it

  (you might see an error "cannot create directory", don't worry about
  that - it'll just occur when you've already have a dir with that
  name, e.g. if you've already worked on this corpus)

If you see a message like grep:
/home/rolthiolliere/Documents/databases<something else>*.cha: No such
file or directory it probably means you forgot the "/" at the end of
the name.

Normally, this will result in a folder being created, with .cha files
inside. You then continue all steps in Alternative 2, because you now
have .cha files.


Alternative 2: .cha files
-------------------------

1. Open and adapt `scripts/cha2sel.sh`, particularly the parts marked
   with "Attention". By doing this, you are selecting which speakers
   (lines) will be analyzed.

2. Open and adapt `scripts/selcha2clean.sh`, particularly the parts
   marked with "Attention". By doing this you are correcting common
   misspellings in your database.

3. Open and adapt one of the wrappers or create a new one, such as
   `wrapper_clean_many_files.sh` or `wrapper_oneFilePerCorpus.sh`.
   Further instructions are provided inside those files.

4. Run the scripts by navigating to the folder and launching them::

     cd /YOUR_ABSOLUTE_PATH_GOES_HERE/database_creation/
     ./wrapper_clean_many_files.sh

   OR::

     ./wrapper_oneFilePerCorpus.sh

NOTES:

- YOUR_ABSOLUTE_PATH_GOES_HERE is the absolute path leading to your
  local copy of database_creation

- If this doesn't run at all (you get a "permission denied" error), it
  probably means that you haven't rendered the scripts executable. Do
  so by typing::

    chmod +x ./scripts/cha2sel.sh
    chmod +x ./scripts/selcha2clean.sh
    chmod +x wrapper_clean_many_files.sh

Alternative 3: BUCKEYE
----------------------

1. Adapt the following variables, being careful to provide absolute
   paths. Then copy and paste these 4 lines onto a terminal window::

     # pick a nice name for your phonological corpus, because this keyname
     # will be used for every output file!
     KEYNAME="buckeye_allbreaks"

     # must exist and contain cha files - notice the / at the end of the name
     RAWFOLDER="/Users/caofrance/Documents/databases/Buckeyebootphon/"

     # will be created and loads of output files will be stored there -
     # notice the / at the end of the name
     RESFOLDER="/Users/caofrance/Documents/tests/res_buckeye_allbreaks/"

     # right now, only options is english -- NOTICE, IN SMALL CAPS
     LANGUAGE="english"

2. Open and adapt if necessary fromBuckeye2clean_human.text,
   particularly the part that is marked with "Attention" - this
   concerns boundary decisions.

3. Run the scripts by navigating to the folder and launching them::

    cd /YOUR_ABSOLUTE_PATH_GOES_HERE/database_creation/
    ./fromBuckeye2clean_human.text $KEYNAME $RAWFOLDER $RESFOLDER $LANGUAGE


STEP 2: Phonologizing
=====================

The necessary scripts are found in the folder called `phonologization`

This step is (internally) very different depending on whether you are
analyzing Qom or English (the two languages we have worked with so
far). There is one example wrapper that contains information for
phonologizing both languages:

`wrapper_oneFilePerCorpus.sh`

And another example wrapper that phonologizes all files within the
list produced by `wrapper_clean_many_files.sh` in Step 1.

**NOTE** this wrapper is actually not finished; it would be the version
that works with the multicorpora that Xuan Nga has been analyzing...

**NOTE** English phonologization depends on the *festival* open source
  program. See http://www.cstr.ed.ac.uk/projects/festival/


STEP 3: Segmentation -- THESE ARE OLD AND NEED UPDATING!!!
====================

The necessary scripts are found in the folder called `algoComp`

1. In a terminal window, navigate to the algoComp/ subfolder

2. Adapt the following variables and copy-paste them into a terminal::

     ABSPATH="`pwd`/"
     KEYNAME="bernsteinads"
     RESFOLDER="/Users/caofrance/Documents/tests/res_bernsteinads/" #macbook
     RESFOLDER="/fhgfs/bootphon/scratch/acristia/results/201510_bernsteinads/" #oberon

3. Run segmentation as follows:

   Follow one the 3.1 or 3.2 alternatives

   3.1. Compute it on your machine::

     ./segment_one_corpus.sh $ABSPATH $KEYNAME $RESFOLDER
     #AG isn't working anymore on my mac - to be checked!
     #other than that, ALL OK 2015-10-14

   3.2. Compute it on the cluster

   If you want to run the segmentation process on a cluster managed by
   Sun Grid Engine ('qsub' command needed), provide a 4th argument to the
   ./segment_one_corpus.sh script. Only the absence/presence of the 4th
   argument matters, not its content. See pipeline/clusterize.sh for more
   details::

     ./segment_one_corpus.sh $ABSPATH $KEYNAME $RESFOLDER notnull

     # AG not run yet because checking problem in the macbook pro bootphon
     # of the other algos, only ngrams seems to work & produce a non-empty
     # gold -- is it a problem with python??


4. This will result in many files being added to your results
   directory. The most interesting one might be the one called _<YOUR
   KEYNAME>-cfgold.txt, which looks like this::

     algo token_f-score token_precision token_recall boundary_f-score boundary_precision boundary_recall
     dibs 0.2353 0.3118 0.189 0.4861 0.6915 0.3748
     tpABS 0.7743 0.7603 0.7888 0.8994 0.8806 0.919
     tpREL 0.2263 0.3274 0.1729 0.5861 0.9426 0.4253
     ag 0.7242 0.6866 0.766 0.8792 0.8271 0.9384


   If you want to see how each algorithm segmented the corpus, you can
   look at the files ending with -cfgold. (The true segmentation is
   usually in the file ending with -gold).

   If you're interested in the highest frequency words each algorithm
   found, they are in the files ending with freq-top (top 10k words).

IMPORTANT
=========

If you want to take your results home, please bear in mind that
several of these files contain substantial parts of the corpus, so be
careful (DON'T take the whole folder). A fast way to clean up is, in a
terminal window (to be on the safe side, I do it on the thumb drive,
so that the originals are kept in this computer)::

    cd <the mother folder of the res_folders>
    mkdir cfgold_results
    cp res_*/_*gold.txt results/
    rm res_*/*all.txt
    rm res_*/*output.txt
    rm res_*/*lines.txt
    rm res_*/*gold.txt


Troubleshooting
===============

- If you get an error::

    ## py-cky.h:1014: In inside() Error: earley parse failed, terminals
    that probably means you used a wrong letter in a dictionary entry.

    Focus on the end of the error:
    ## py-cky.h:1014: In inside() Error: earley parse failed, terminals = (s I s i l j x)

This means that one of the letters in "s I s i l j x" is wrong.
Compare them against the list of letters ("phonemes") with the ones listed in::

 algos/AG/grammars/Colloq0_enKlatt.lt

namely:
d e f g h i k l m n o p r @ s t u C v D E w x G y z I J O R S T U W Y Z ^ a b c | L M N X


There is no "j" in this list -- so that means there is at least one
incorrect entry with j, in this case "s I s i l j x" or rather
"sIsiljx".

A longer route: Do::

  $ cd /YOUR_ABSOLUTE_PATH_GOES_HERE/algoComp201507/algos/AG/input
  $ tr -d '/' < input.ylt |sed '/^$/d' | sort | uniq -c | awk '{print $2" "$1}' | sort -n -r > ~/Desktop/letter-count.txt

This will generate a file called letter-count.txt on your
Desktop. Open it and paste the contents onto LibreOffice Calc

Once you find the guilty letter, go to the dictionary
/YOUR_ABSOLUTE_PATH_GOES_HERE/database_creation/update_dictionary/data/dict-Brent.txt
Do a search for it, and change it to the appropriate letter.

Finally, regenerate the dictionary following the instructions in
SUBROUTINE: ADDING WORDS TO THE DICTIONARY, step 4+

- If you get an error::

    ## py-cfg.cc:256: In gibbs_estimate() Error in py-cfg::gibbs_estimate(), tprob = 0, trains[XX]

This means that one of your phrases is too long. You might need to use
a different version of adaptor grammar -- ask Alex about it.


- If you get an error::

    ./do_colloq0_english.sh: line 49: py-cfg-new/py-cfg: cannot execute binary file

this means that something went wrong with the Adaptor Grammar
build. Navigate to algos/AG/py-cfg-new and run::

  make clean
  make

You should see something like the following, with no errors::

  [acristia@oberon py-cfg-new]$ make clean
  rm -fr *.o *.d *.prs *.trace *.wlt *~ core
  [acristia@oberon py-cfg-new]$ make
  g++ -c -MMD -O6 -Wall -ffast-math -fno-finite-math-only -finline-functions -fomit-frame-pointer -fstrict-aliasing   gammadist.c -o gammadist.o
  g++ -MMD -O6 -Wall -ffast-math -fno-finite-math-only -finline-functions -fomit-frame-pointer -fstrict-aliasing     -c -o py-cfg.o py-cfg.cc
  g++ -c -MMD -O6 -Wall -ffast-math -fno-finite-math-only -finline-functions -fomit-frame-pointer -fstrict-aliasing  mt19937ar.c -o mt19937ar.o
  g++ -MMD -O6 -Wall -ffast-math -fno-finite-math-only -finline-functions -fomit-frame-pointer -fstrict-aliasing     -c -o sym.o sym.cc
  g++ gammadist.o py-cfg.o mt19937ar.o sym.o -lm -Wall -O6  -o py-cfg
  g++ -c -MMD -O6 -Wall -ffast-math -fno-finite-math-only -finline-functions -fomit-frame-pointer -fstrict-aliasing   -DQUADPREC py-cfg.cc -o py-cfg-quad.o
  g++ gammadist.o py-cfg-quad.o mt19937ar.o sym.o -lm -Wall -O6  -o py-cfg-quad
  g++ -c -MMD -O6 -Wall -ffast-math -fno-finite-math-only -finline-functions -fomit-frame-pointer -fstrict-aliasing   -fopenmp py-cfg.cc -o py-cfg-mp.o
  g++ -c -MMD -O6 -Wall -ffast-math -fno-finite-math-only -finline-functions -fomit-frame-pointer -fstrict-aliasing   -fopenmp -DQUADPREC py-cfg.cc -o py-cfg-quad-mp.o
  g++ -fopenmp gammadist.o py-cfg-quad-mp.o mt19937ar.o sym.o -lm -Wall -O6  -o py-cfg-quad-mp

- If you get an error:
bogdan@precisiont7610:~/CDSwordSeg/algoComp/pipeline$ ./AG.sh ~/CDSwordSeg/algoComp ~/CDSwordSeg/results/AG_baseIDS AGc3s
# Iteration 0, 86161 tables, -logPcorpus = 432815, -logPrior = 1706.46, 0/14569 analyses unchanged, 0/14569 rejected.
# Iteration 0, 85681 tables, -logPcorpus = 447553, -logPrior = 1706.46, 0/14569 analyses unchanged, 0/14569 rejected.
# Iteration 0, 87531 tables, -logPcorpus = 437737, -logPrior = 1706.46, 0/14569 analyses unchanged, 0/14569 rejected.
# Iteration 0, 85505 tables, -logPcorpus = 431854, -logPrior = 1706.46, 0/14569 analyses unchanged, 0/14569 rejected.
# Iteration 0, 88133 tables, -logPcorpus = 437727, -logPrior = 1706.46, 0/14569 analyses unchanged, 0/14569 rejected.
# Iteration 0, 88130 tables, -logPcorpus = 443818, -logPrior = 1706.46, 0/14569 analyses unchanged, 0/14569 rejected.
# Iteration 0, 85507 tables, -logPcorpus = 445540, -logPrior = 1706.46, 0/14569 analyses unchanged, 0/14569 rejected.
# Iteration 0, 83784 tables, -logPcorpus = 431983, -logPrior = 1706.46, 0/14569 analyses unchanged, 0/14569 rejected.
py-cfg: py-cky.h:509: F pycfg_type::decrtree(pycfg_type::tree*, pycfg_type::U): Assertion `weight <= tp->count' failed.
/home/bogdan/CDSwordSeg/algoComp/algos/AG/do_AG_japanese.sh: line 117:  1462 Aborted                 (core dumped) $PYCFG -n $NITER -G $RESFOLDER/$RUNFILE$i.wlt -A $RESFOLDER/$TMPFILE$i.prs -F $RESFOLDER/$TMPFILE$i.trace -E -r $RANDOM -d 101 -a 0.0001 -b 10000 -e 1 -f 1 -g 100 -h 0.01 -R -1 -P -x 10 -u $YLTFILE -U cat $GRAMMARFILE > $RESFOLDER/$OUTFILE$i.prs < $YLTFILE
The grammar was parsing all the sentences without a problem, as I fixed all issues that arose during parsing. I was getting the error after the first parse, when AG was trying to update the model.

I've tried several things, among which testing AG with a grammar that works. So I've created an English toy test set and I ran AG using the colloc3syllFunc grammar that came with the package. It worked fine. So, after more testing I've changed my Japanese grammar to something more similar to the English grammar and it finally passes the model updating step. It appears that it is important to know what levels of the grammar to adapt, as that was the sole difference between the working and non-working grammars. You can find attached the two grammars.