#! usr/bin/perl
$KEYNAME = $ARGV[0];
$RESFOLDER = $ARGV[1];

system("perl convert-to-unicode-flexible.pl $corpusname $ortho");
system("perl RemoveEndSpaces.pl $corpusname");

system("cp -b brent9mos-klatt.txt ../corpora_clean/");
system("cp -b brent9mos-unicode.txt ../corpora_clean/");
system("cp -b unicode-dict.txt ../corpora_clean/");
system("cp -b unicode-word-dict.txt ../corpora_clean/");
