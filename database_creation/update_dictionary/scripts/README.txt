NOTE!!! BELOW are the original instructions from the 

Lawrence Phillips & Lisa Pearl, 12/23/13

README for syllabic American English-US Brent corpus (UCI-Brent-Syllabic Corpus).

Twenty five files are included here:

**Information files:
(1) README.txt: this readme file

(2) Klatt_IPA.pdf: A file describing the Klattese IPA encoding

**Data files (in data directory):

(1) brent9mos.txt: A file containing the orthographic transcript of a subset of the Brent corpus in the CHILDES database, specifically all utterances directed at children 9 months or younger.

(2) brent9mos-text-klatt-syls: A file containing the syllabified Klattese IPA transcript of the subset of the Brent corpus directed at children 9 months and younger.

[The following three files are used in the syllabification process]

(3) dict-Brent.txt: Phonemic (Klattese) transcription of all words appearing in brent9mos.txt file.

(4) mrc-call-syllabified.txt: Syllabic transcription of words in brent9mos.txt, derived from the MRC Psycholinguistic Database (Wilson 1988). 

Wilson, M.D. (1988). The MRC Psycholinguistic Database: Machine Readable Dictionary, Version 2, Behavioral Research Methods, Instruments and Computers, 20 6-11.

(5) ValidOnsets.txt: Contains a list of valid syllable onsets.



**Perl (and related) files (in perl directory):

(1) README_syllabic_conversion.txt: describes how to run syllabic conversion process for use in programs that operate over single characters (e.g., code designed to process individual phonemese)

(2) run-syllabification-9mos: master batch script that calls perl scripts to create syllabified form of english orthographic text

(3) adding-syllabification.pl, convert-to-english-9mos.pl, convert-to-english-syls-9mos.pl, convert-to-unicode-9mos.pl, create-unicode-dict.pl, edit-dict-brent.pl, remove-end-spaces-9mos.pl: helper scripts to accomplish different parts of the syllabification process


**Output file generated during syllabic conversion process (in output directory):

(1) brent9mos-text-klatt-syls.txt: syllabified Klattese IPA version of original orthographic text

(2) brent9mos-text-klatt.txt: Klattese IPA version of original orthographic text

(3) brent9mos-text-unicode.txt: Unicode encoding of syllabified Klattese IPA orthographic text

(4) brent9mos.txt: orthographic text of 9mos subsection of Brent corpus

(5) dict-Brent-Klatt.txt: Klattese IPA version of words in Brent corpus

(6) syllabified-dict.txt: syllabification of Klattese IPA version of words in Brent corpus

(7) unicode-dict.txt: Syllable to unicode conversion dictionary

(8) unicode-word-dict.txt: Word to unicode-syllable conversion dictionary



****************************************

NOTE: If using these corpora in published materials, please cite one or more of the following:

Phillips, L. & Pearl, L. 2012. 'Less is More' in Bayesian word segmentation: When cognitively plausible learners outperform the ideal, In N. Miyake, D. Peebles, & R. Cooper (eds), Proceedings of the 34th Annual Conference of the Cognitive Science Society, 863-868. Austin, TX: Cognitive Science Society. 


Phillips, L. & Pearl, L. 2013. "Less is More" in language acquisition: Evidence from word segmentation. Manuscript, University of California, Irvine.


CHILDES database:
B.MacWhinney. 2000. The CHILDES Project: Tools for Analyzing Talk. Mahwah, 
NJ: Lawrence Erlbaum Associates. 

Brent corpus (original source of the data):
Brent, M. R. & Siskind, J. M. (2001). The role of exposure to isolated words in early vocabulary development. Cognition, 81, 31-44.

******************************************


To run syllabification on the Brent corpus you'll need the following files:

dict-Brent.txt
ValidOnsets.txt
brent9mos.txt
mrc-call-syllabified.txt

as well as the following perl scripts

edit-dict-brent.pl
adding-syllabification.pl
create-unicode-dict.pl
convert-to-unicode-9mos.pl
convert-to-english-9mos.pl
run-syllabification-9mos.pl

With them in the directory run run-syllabification.pl

>	perl run-syllabification-9mos.pl

Run-syllabification goes through the following five steps:

1. run edit-dict-brent (requires dict-Brent.txt) to generate a new dictionary in Klattese (dict-Brent-Klatt.txt)
2. run adding-syllabification (requires dict-Brent-Klatt.txt, ValidOnsets.txt) to generate syllabified dictionary (syllabified-dict.txt)
3. run create-unicode-dict (requires syllabified-dict.txt) to generate unicode dictionary of syllables (unicode-dict.txt) and words (unicode-word-dict.txt)
4. run convert-to-unicode-9mos (requires unicode-word-dict.txt and brent9mos.txt) to create the unicode-transcribed version of the brent file (brent9mos-text-unicode.txt)
5. run convert-to-english-9mos (requires unicode-dict.txt and brent9mos-text-unicode.txt) to convert the unicode-transcribed brent file to phonemic form (brent9mos-text-out.txt)

Note: Unicode versions are created for use with programs that already operate over single characters (e.g., programs used to operating over phonemes).

