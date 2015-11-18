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
