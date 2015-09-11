#!/usr/bin/perl
$corpusname = $ARGV[0];
$outfolder = $ARGV[1];

# converts unicode file back to english.

# Read unicode/syllable pairs from unicode-dict.txt
open(DICT, "../input/unicode-dict.txt") || die "Couldn't open ../input/unicode-dict.txt for reading\n";
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
open(IN, "<$outfolder$corpusname-text-unicode.txt") || die "Couldn't open $outfolder$corpusname-text-unicode.txt for reading\n";
binmode(IN, ":utf8");
open(OUT, ">$outfolder$corpusname-text-klatt.txt") || die "Couldn't open $outfolder$corpusname-text-klatt.txt\n";
binmode(OUT, ":utf8");
binmode(STDOUT, ":utf8");

while(defined($fileline = <IN>)){
	# get rid of trailing newlines
	chomp($fileline);
#print "considering $fileline\n";
	@line_chars = split(/ /, $fileline);
	foreach $line_char (@line_chars){
			@word_chars = split(//, $line_char);
			foreach $word_char (@word_chars){
			 if(exists ($dict{$word_char})){
				$syl = $dict{$word_char};
#print("debug: " . $word_char . ": " . $dict{$word_char} . " \n");
				  print(OUT $dict{$word_char});
				 }
			}
		print(OUT " ");
	}
	print(OUT "\n");
}
