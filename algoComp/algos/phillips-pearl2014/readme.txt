Syllabic Bayesian word segmenter
Lawrence Phillips
10/10/2014
Edits by Alex Cristia <alecristia@gmail.com> 2015-11-18 & 2017-01-09

#############################

Included are all of the files necessary to run the Bayesian word
segmenter from Goldwater, Griffiths, Johnson (2010) over a syllabified
corpus as documented in Phillips & Pearl (2014).

All code was created with a UNIX environment in mind. It is highly
recommended that all code be run in Linux/Mac or similar environment.

#############################
CREATING DPSEG FILE
#############################

Before the model can be run, you'll first need to compile the dpseg executable.

First, acquire the Boost program_options library. Directions can be
found at
http://www.boost.org/doc/libs/1_56_0/more/getting_started/unix-variants.html

If you're having trouble installing the boost library, another set of
useful directions can be found at
http://ubuntuforums.org/showthread.php?t=1180792

You'll need to download the boost library and extract it from the
archive. From the command line, move to the extracted directory and
install using './bootstrap.sh --exec-prefix=/usr/local' (you can limit
the number of libraries installed by using the --with-libraries
flag). Then build the program_options library using the built-in
function './b2 install'. This should throw the header files in
/usr/local/include and the libraries in /usr/local/lib.

Then, in the 'dpseg_files' folder, compile the program 'dpseg' by
using the 'make' function. 

NOTE: "makefile" contains an absolute path; therefore, it won't work.
Use instead:
$ make -f Makefile2


If the program does not compile, check the
Makefile. In particular, make sure the variable CFLAGS is pointing to
the folder containing the boost header files and that the variable
LIBS is pointing to the folder containing the boost libraries (.so
files). #comment: modified LIBS to adapt to our system

Finally, make dpseg executable using 'chmod +x dpseg' and copy the
file to the parent folder.


#############################
INSTRUCTIONS
#############################

Run the file 'syllable-conversion/run-syllabification.pl' from that
directory to create the appropriate syllabified corpus files

Run 'corpora_clean/CreateTrainTestSets.pl' from that directory in
order to create train/test sets. Then run 'RemoveLineFinalSpaces.pl'
to clean up these files somewhat.

Run the files 'run_dpseg/RunUnigram-Eng.pl' and
'run_dpseg/RunBigram-Eng.pl' to create the model output. Note that
these files can take some time. In particular, the DMCMC (OnlineMem)
learner was not thoroughly optimized, and in some cases may take a
week in order to complete.

The output files are difficult to compare. To consolidate the data run
'analysis/ReadInData.pl' which will create a 'results.txt' file
located in the folder 'results/English/'


#############################
ADDITIONAL SCRIPTS
#############################

The 'analysis' folder contains a number of scripts to accomplish
different tasks:

Run_score_output.pl - Take the output of the learners and adjust
F-scores to account for 'reasonable' errors. These are printed to
'results/English/adjusted_results.txt'.  A list of reasonable errors
found is printed in 'okayerrors/eng/'

read_okayerrors.pl - Reads the reasonable error files and prints a
summary in the 'okayerrors' folder. The summary shows what each error
should have been.

read_contexterrors.pl - Similar to 'read_okayerrors.pl', except prints
the output of the learner rather than showing what the error should
have been.

'frequency.pl' - Calculates a frequency metric to determine for each
learner how frequent (on average), the words they correctly identified
were.

# edits: added english subfolder to output_clean; English subfolder to
  results
