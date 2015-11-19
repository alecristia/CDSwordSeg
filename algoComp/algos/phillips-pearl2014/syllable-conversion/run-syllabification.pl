#! usr/bin/perl

system("perl edit-dict-brent.pl");
system("perl adding-syllabification.pl");
system("perl create-unicode-dict.pl");
system("perl convert-to-unicode.pl");
system("perl convert-to-english.pl");
system("perl RemoveEndSpaces.pl");

system("cp -b brent9mos-klatt.txt ../corpora_clean/");
system("cp -b brent9mos-unicode.txt ../corpora_clean/");
system("cp -b unicode-dict.txt ../corpora_clean/");
system("cp -b unicode-word-dict.txt ../corpora_clean/");
