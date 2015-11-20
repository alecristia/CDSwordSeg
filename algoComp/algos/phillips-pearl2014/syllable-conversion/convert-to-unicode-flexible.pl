#!/usr/bin/perl
$corpusname = $ARGV[0];
$ortho = $ARGV[1];
$outfolder = $ARGV[2];

# Convert **INPUT** file ($ortho) to unicode <--- Alex Cristia -- now
# we get 2 arguments to decide what is converted TODO pass also
# dictionary & code name for conversion target

# Read unicode/word pairs from unicode-word-dict.txt
open(DICT, "original/unicode-word-dict.txt")
        or die "Couldn't open ../input/unicode-word-dict.txt for reading\n";
binmode(DICT, ":utf8");

%dict = ();
@dict_lines = <DICT>;
close(DICT);

foreach $dict_line (@dict_lines){
  if($dict_line =~ /(.+)\t(.+)$/){
    #print("debug: syllable = $1, unicode character = $2\n");
    $dict{$1} = $2;
	}
}


open(IN, "<$ortho")
        or die("Couldn't open $ortho\n");
open(OUT, ">$outfolder$corpusname-text-unicode.txt")
        or die("Couldn't open $outfolder$corpusname-text-unicode.txt\n");
open(ADD, ">$outfolder$corpusname-ADD.txt")
        or die("Couldn't open $outfolder$corpusname-ADD.txt\n");

binmode(IN, ":utf8");
binmode(OUT, ":utf8");
binmode(ADD, ":utf8");
binmode(STDOUT, ":utf8");

# (following code blatantly copy/pasted from createIPA.pl)
while(defined($inputfileline = <IN>)){
  # line should be words divided by one space each
  # get rid of newline at the end

  # debug print
  #print("$inputfileline");

  chomp($inputfileline);

  @words_in_line = split(/ /,$inputfileline);

  # go through and replace
  $index = 0;
  while(defined($words_in_line[$index])){

    $word_to_find = $words_in_line[$index];
    # switch uppercase letters to lowercase letters
    $word_to_find =~ tr/[A-Z]/[a-z]/;
    # check to make sure word has some characters in it
    if($word_to_find =~ /./){
      # check to see if in dict hash
      if(exists ($dict{$word_to_find})){
	print(OUT $dict{$word_to_find});
#print "word: $word_to_find, unicode: $dict{$word_to_find}\n";
	if($index != $#words_in_line){
		print(OUT " ");
	}
      }else{
print(ADD "$word_to_find\n");
      }
  }
    $index++;
  }
   print(OUT "\n");
}

close(IN);
close(OUT);
