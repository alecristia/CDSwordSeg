#! usr/bin/perl

# converts unicode file back to english.

# Read unicode/syllable pairs from unicode-dict.txt
open(DICT, "<unicode-dict.txt") || die "Couldn't open unicode-dict.txt for reading\n";
binmode(DICT, ":utf8");

%dict = ();
@dict_lines = <DICT>;
close(DICT);

foreach $dict_line (@dict_lines){
  if($dict_line =~ /(.+)\t(.+)$/){
#print("debug: syllable = $1, unicode character = $2\n");
    $dict{$2} = $1;
  }
}

# Read in unicode file, translate back into plain English and print to engbrent-text-out.txt
open(IN, "<brent9mos-unicode.txt") || die "Couldn't open brent9mos-unicode.txt for reading\n";
binmode(IN, ":utf8");
open(OUT, ">brent9mos-klatt.txt") || die "Couldn't open brent9mos-klatt.txt\n";
binmode(OUT, ":utf8");

while(defined($fileline = <IN>)){
	# get rid of trailing newlines
	chomp($fileline);
	@line_chars = split(/ /, $fileline);
	foreach $line_char (@line_chars){
		@word_chars = split(//, $line_char);
		$utt_to_print;
		foreach $word_char (@word_chars){
			if(exists ($dict{$word_char})){
				$utt_to_print = $utt_to_print . '/' . $dict{$word_char};
			}
		}
		$utt_to_print =~ s/^\///;
		print(OUT "$utt_to_print ");
		undef($utt_to_print);
	}
	print(OUT "\n");
}
