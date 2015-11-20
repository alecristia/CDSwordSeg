####Original readme

To run syllabification on the Brent corpus you'll need the following files:

dict-Brent.txt
ValidOnsets.txt
brent9mos.txt
mrc-call-syllabified.txt

as well as the following perl scripts

edit-dict-brent.pl
adding-syllabification.pl
create-unicode-dict.pl
convert-to-unicode.pl
convert-to-english.pl
run-syllabification.pl

With them in the directory run run-syllabification.pl

>	perl run-syllabification.pl

This will generate the Unicode file that you need, brent9mos-unicode.txt, an IPA version (encoded in Klattese) is also produced, brent9mos-klatt.txt

Copies of the corpora and unicode dictionaries are also made to the folder corpora_clean where the files will later be used

Klattese reference can be found online at http://www.people.ku.edu/~mvitevit/Klatt_IPA.pdf

# Alex Cristia <alecristia@gmail.com> 2015-11-19
We are starting from a corpus that is already syllabified (and in a different set of characters, but it doesn't look like it should matter). I'm not sure why the dictionary is syllabified. For now, the simplest path is to take the corpus in phono syllabified format, make a dictionary of syllables, create unicode forms for those syllables, and input this to the rest of the system.

