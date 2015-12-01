Instructions for text analyses
For questions contact Alex Cristia alecristia@gmail.com

********************** Overview ******************

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
   algorithms (chosen by user).


********************** TODO ******************

- AC update the evaluation section for all the batch algos (i.e., not
PUDDLE or Phillips)

- AC start running the experiments on all the batch algos

- Mathieu

  - Have a non buggy results on all algos :
    -> refactor segment_one_corpus.sh to run all in one run
    -> debug them one by one
    -> run evaluation on that
    -> potential issues with other copora (@, etc...)

  - Smart clusterization of crossevaluation.

  - Optimize crossevaluation unfold step (no need to load entire
    files, tail is enought).

***** OLD TODO backup

- DONE Mathieu still working on adapting Phillips

- DONE whoever is done first will implement a cross-validation with
  20% chunks on the non-batch algos



*** troubleshoot oberon on step 3 segmentation, which boils down to
    the following

- dibs OK though odd that performance for dibs is 1pc lower with the
  new phon set, no?? maybe forget, since we will rerun everything
  anyway...

- ngrams OK

- TP OK, odd that performance is 2pc higher now; notice that standard
  format cannot be created now because spaces between letters are lost

- AG OK, changed to c3syll+functionwords standard format cannot be
  created bc spaces bet letters lost

- Puddle: poor performance because testing on the whole thing!!!! -->
  we decide to test on last 20% for all corpora

*** implement phillips

- now: ran one iteration of DMCMC on their own input; output looks okay

- in process: adaptation to our own input


********************** STEP 1: Database creation ******************

The necessary scripts are found in the folder called database_creation

*** Alternative 1: .trs files from WinnipegLENA corpus

1. Open and adapt one of the trs2cha scripts,
e.g. scripts/trs2cha_201511.text (creates 3 selections) or
scripts/trs2cha_all.text (collapses across all addressees). You need
to pay attention to the variables at the top:

- the trs folder is where your trs files are;

- the cha folder will be created so pick anything you want. (A
  reasonable option is that the folder is sister to the trs folder.)

IMPORTANT!!! ALSO notice that there is a section in the middle that
needs to be changed to select subsets of sentences! There is more
explanation in comments (lines starting with #) in the middle of
scripts/trs2cha_all.text.

3. In a terminal window, navigate to the scripts subfolder of your
database_creation folder, e.g.

$ cd /home/rolthiolliere/Documents/database_creation/scripts 

(you don't type the "$" -- this is just a convention to indicate that
a line is copied + pasted into a terminal window)

4. Now run the script from the terminal window by typing:
$ ./trs2cha_201511.text #or whatever name you gave it

(you might see an error "cannot create directory", don't worry about
that - it'll just occur when you've already have a dir with that name,
e.g. if you've already worked on this corpus)

If you see a message like
grep: /home/rolthiolliere/Documents/databases<something else>*.cha: No such file or directory
it probably means you forgot the "/" at the end of the name.

Normally, this will result in a folder being created, with .cha files
inside. You then continue all steps in Alternative 2, because you now
have .cha files.


*** Alternative 2: .cha files

1. Open and adapt scripts/cha2sel.sh, particularly the parts marked
   with "Attention". By doing this, you are selecting which speakers
   (lines) will be analyzed.

2. Open and adapt scripts/selcha2clean.sh, particularly the parts
   marked with "Attention". By doing this you are correcting common
   misspellings in your database.

3. Open and adapt one of the wrappers or create a new one, such as:
   wrapper_clean_many_files.sh
   wrapper_oneFilePerCorpus.sh

Further instructions are provided inside those files.

4. Run the scripts by navigating to the folder and launching them:
   cd /YOUR_ABSOLUTE_PATH_GOES_HERE/database_creation/
   ./wrapper_clean_many_files.sh

   OR

   ./wrapper_oneFilePerCorpus.sh

NOTES:

- YOUR_ABSOLUTE_PATH_GOES_HERE is the absolute path leading to your
  local copy of database_creation

- If this doesn't run at all (you get a "permission denied" error), it
  probably means that you haven't rendered the scripts executable. Do
  so by typing:

  chmod +x ./scripts/cha2sel.sh
  chmod +x ./scripts/selcha2clean.sh
  chmod +x wrapper_clean_many_files.sh

*** Alternative 3: BUCKEYE

1. Adapt the following variables, being careful to provide absolute
   paths. Then copy and paste these 4 lines onto a terminal window.

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

3. Run the scripts by navigating to the folder and launching them:

   cd /YOUR_ABSOLUTE_PATH_GOES_HERE/database_creation/
   ./fromBuckeye2clean_human.text $KEYNAME $RAWFOLDER $RESFOLDER $LANGUAGE

********************** STEP 2: Phonologizing ******************
The necessary scripts are found in the folder called phonologization

This step is (internally) very different depending on whether you are
analyzing Qom or English (the two languages we have worked with so
far). There is one example wrapper that contains information for
phonologizing both languages:

wrapper_oneFilePerCorpus.sh

And another example wrapper that phonologizes all files within the
list produced by wrapper_clean_many_files.sh in Step 1.

#NOTE! this wrapper is actually not finished; it would be the version
that works with the multicorpora that Xuan Nga has been analyzing...


********************** STEP 3: Segmentation  ******************

The necessary scripts are found in the folder called algoComp

1. In a terminal window, navigate to the algoComp/ subfolder

2. Adapt the following variables and copy-paste them into a terminal

ABSPATH="`pwd`/"
KEYNAME="bernsteinads"
RESFOLDER="/Users/caofrance/Documents/tests/res_bernsteinads/" #macbook
RESFOLDER="/fhgfs/bootphon/scratch/acristia/results/201510_bernsteinads/" #oberon

3. Run segmentation as follows:

Follow one the 3.1 or 3.2 alternatives

3.1. Compute it on your machine

    ./segment_one_corpus.sh $ABSPATH $KEYNAME $RESFOLDER
#AG isn't working anymore on my mac - to be checked!
#other than that, ALL OK 2015-10-14


3.2. Compute it on the cluster

If you want to run the segmentation process on a cluster managed by
Sun Grid Engine ('qsub' command needed), provide a 4th argument to the
./segment_one_corpus.sh script. Only the absence/presence of the 4th
argument matters, not its content. See pipeline/clusterize.sh for more
details.

    ./segment_one_corpus.sh $ABSPATH $KEYNAME $RESFOLDER notnull

# AG not run yet because checking problem in the macbook pro bootphon
# of the other algos, only ngrams seems to work & produce a non-empty
# gold -- is it a problem with python??


4. This will result in many files being added to your results
   directory. The most interesting one might be the one called _<YOUR
   KEYNAME>-cfgold.txt, which looks like this:

algo token_f-score token_precision token_recall boundary_f-score boundary_precision boundary_recall
dibs 0.2353 0.3118 0.189 0.4861 0.6915 0.3748
tpABS 0.7743 0.7603 0.7888 0.8994 0.8806 0.919
tpREL 0.2263 0.3274 0.1729 0.5861 0.9426 0.4253
ag 0.7242 0.6866 0.766 0.8792 0.8271 0.9384


If you want to see how each algorithm segmented the corpus, you can
look at the files ending with -cfgold. (The true segmentation is usually in
the file ending with -gold).

If you're interested in the highest frequency words each algorithm
found, they are in the files ending with freq-top (top 10k words).

******IMPORTANT****

If you want to take your results home, please bear in mind that
several of these files contain substantial parts of the corpus, so be
careful (DON'T take the whole folder). A fast way to clean up is, in a
terminal window (to be on the safe side, I do it on the thumb drive,
so that the originals are kept in this computer):

    cd <the mother folder of the res_folders>
    mkdir cfgold_results
    cp res_*/_*gold.txt results/
    rm res_*/*all.txt
    rm res_*/*output.txt
    rm res_*/*lines.txt
    rm res_*/*gold.txt


**** Troubleshooting:

- If you get an error:

    ## py-cky.h:1014: In inside() Error: earley parse failed, terminals
    that probably means you used a wrong letter in a dictionary entry.

    Focus on the end of the error:
    ## py-cky.h:1014: In inside() Error: earley parse failed, terminals = (s I s i l j x)

This means that one of the letters in "s I s i l j x" is wrong.
Compare them against the list of letters ("phonemes") with the ones listed in:
/YOUR_ABSOLUTE_PATH_GOES_HERE/algoComp201507/algos/AG/grammars/Colloq0_enKlatt.lt

namely:
d	e	f	g	h	i	k	l	m	n	o	p	r	@	s	t	u	C	v	D	E	w	x	G	y	z	I	J	O	R	S	T	U	W	Y	Z	^	a	b	c	|	L	M	N	X


There is no "j" in this list -- so that means there is at least one
incorrect entry with j, in this case "s I s i l j x" or rather
"sIsiljx".

A longer route: Do
$ cd /YOUR_ABSOLUTE_PATH_GOES_HERE/algoComp201507/algos/AG/input
$ tr -d '/' < input.ylt |sed '/^$/d' | sort | uniq -c | awk '{print $2" "$1}' | sort -n -r > ~/Desktop/letter-count.txt

This will generate a file called letter-count.txt on your
Desktop. Open it and paste the contents onto LibreOffice Calc

Once you find the guilty letter, go to the dictionary
/YOUR_ABSOLUTE_PATH_GOES_HERE/database_creation/update_dictionary/data/dict-Brent.txt
Do a search for it, and change it to the appropriate letter.

Finally, regenerate the dictionary following the instructions in
SUBROUTINE: ADDING WORDS TO THE DICTIONARY, step 4+

- If you get an error

    ## py-cfg.cc:256: In gibbs_estimate() Error in py-cfg::gibbs_estimate(), tprob = 0, trains[XX]

This means that one of your phrases is too long. You might need to use
a different version of adaptor grammar -- ask Alex about it.


- If you get an error
./do_colloq0_english.sh: line 49: py-cfg-new/py-cfg: cannot execute binary file

this means that something went wrong with the Adaptor Grammar
build. Navigate to algos/AG/py-cfg-new and run

make clean
make


You should see something like the following, with no errors:
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


***********************
Tests:
		mini	oberon	macbook
1.database	OK	OK
2.phonol	fail	OK
3.segment	( )

errors mac mini phonologize
Traceback (most recent call last):
  File "scripts/phonologize.py", line 161, in <module>
    main()
  File "scripts/phonologize.py", line 157, in main
    phonologize(args.input, args.output)
  File "scripts/phonologize.py", line 141, in phonologize
    text = process(text)
  File "scripts/phonologize.py", line 107, in process
    res = subprocess.check_output(['festival', '-b', tmpscm.name])
  File "//anaconda/lib/python2.7/subprocess.py", line 566, in check_output
    process = Popen(stdout=PIPE, *popenargs, **kwargs)
  File "//anaconda/lib/python2.7/subprocess.py", line 710, in __init__
    errread, errwrite)
  File "//anaconda/lib/python2.7/subprocess.py", line 1335, in _execute_child
    raise child_exception
OSError: [Errno 2] No such file or directory
