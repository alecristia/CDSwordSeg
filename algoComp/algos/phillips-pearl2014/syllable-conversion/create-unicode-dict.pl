#!/usr/bin/perl 

# Creates/updates unicode-dict.txt
# unicode-dict.txt is a dictionary of possible syllabes, taken from syllabified-dict.txt
# represented as unicode characters.

use Encode; 
 
%dict = (); 
# a simple way to generate unicode assignments for whatever units we encounter
$base = 3001; # shouldn't be any control characters below this range
$current_uni = 0;

binmode(STDOUT, ":utf8");
open(IN, "<syllabified-dict.txt") || die "Couldn't open syllabified-dict.txt\n";
open(WORDDICT, ">unicode-word-dict.txt") || die "Couldn't open unicode-word-dict.txt\n";
binmode(WORDDICT, ":utf8");
%checkhash = (); #hash for checking duplicate unicode values

# assign unicode characters to syllabes in syllabified-dict.txt
# also print word/unicode pairs to unicode-word-dict.txt
while(defined($fileline = <IN>)){
	$fileline =~ /(.+)\t(.+)$/;
	print(WORDDICT "$1\t");
	 @syls_to_enter = split(/\//,$2);
	foreach $syl (@syls_to_enter){
	  if(!exists($dict{$syl})){
		# add syllable to word/unicode dict
		$char = chr(hex($current_uni + $base));
		if ($char =~ /\s/){
			while ($char =~ /\s/){
				$current_uni++;
				$char = chr(hex($current_uni+$base));
			}
		}
		$dict{$syl} = $char;
		if(exists($checkhash{$dict{$syl}}))
		{	
			$checkhash{$dict{$syl}}++;
			print STDOUT "duplicate for $syl: $checkhash{$dict{$syl}}";
		}
		else{$checkhash{$dict{$syl}} = 1;}

		# increment $current_uni so we don't get the same character next time
		$current_uni++;
	  }
	  print(WORDDICT "$dict{$syl}");
	}
	print(WORDDICT "\n");
}
close IN;
close WORDDICT;

# print out new unicode dictionary to unicode-dict.txt
open(OUT, ">unicode-dict.txt") || die "Couldn't open unicode-dict.txt\n";
binmode(OUT, ":utf8");
foreach $syl (sort (keys %dict)){
	print(OUT "$syl\t$dict{$syl}\n");
}
close(OUT);
