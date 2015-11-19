# Convert Brent file to unicode

# Read unicode/word pairs from unicode-word-dict.txt
open(DICT, "<unicode-word-dict.txt") || die "Couldn't open unicode-word-dict.txt for reading\n";
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


open(IN, "<brent9mos.txt") or die("Couldn't open brent9mos.txt\n");
open(OUT, ">brent9mos-unicode.txt") or die("Couldn't open brent9mos-unicode.txt\n");

binmode(IN, ":utf8");
binmode(OUT, ":utf8");

# (following code blatantly copy/pasted from createIPA.pl)
while(defined($inputfileline = <IN>)){
  # line should be words divided by one space each
  # get rid of newline at the end
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
	if($index != $#words_in_line){
		print(OUT " ");
	}
      }
  }
    $index++;
  }
   print(OUT "\n");
}

close(IN);
close(OUT);
