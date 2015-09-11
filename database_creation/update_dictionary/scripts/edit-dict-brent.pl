#!/usr/bin/perl

open(IN, "<../data/dict-Brent.txt")or die("Couldn't open data/dict-Brent.txt for reading");
@dict_lines = <IN>;
close(IN);

open(OUT, ">../../fromCHAtoSND/input/dict-Brent-Klatt.txt") or die("Couldn't create ../../fromCHAtoSND/input/dict-Brent-Klatt.txt for writing");

foreach $line (@dict_lines){

	@words = split(/\s+/,$line);
	$word = $words[0];
#	$line =~ /^(.+)\s+(.+)$/;
#	#print STDOUT "$2\n";
#	$word = $1;
	@rest = @words;
	shift(@rest); # remove first word

	@brent_word=();
	foreach $bit (@rest){
		#print STDOUT "$bit\t";
		if ($bit =~ /\./){
			$bit =~ s/\.//g;
			push(@brent_word,$bit);
			#print STDOUT "Debug\t";
		}else{
			#print STDOUT "$bit\n";
		}
		#print STDOUT "\n";
	}
	$brent = join("",@brent_word);
	#print STDOUT "$brent\n";
	
	# now start replacing characters with their Klattese equivalents
	# assorted mistakes I stumbled on
	$brent =~ s/m6sOG/m6sOZ/g;
	$brent =~ s/pZnc/p\^nc/g;
	$brent =~ s/\-w//g;
	$brent =~ s/\]\=//g;
	# consonants
	$brent =~ s/L/xl/g;
	$brent =~ s/G/J/g;
	$brent =~ s/M/xm/g;
	$brent =~ s/\~/xn/g;
	$brent =~ s/N/G/g;
	$brent =~ s/c/C/g;
	#vowels
	$brent =~ s/\&/\@/g;
	$brent =~ s/O/c/g;
	$brent =~ s/0/o/g;
	$brent =~ s/9/Y/g;
	$brent =~ s/7/O/g;
	$brent =~ s/Q/W/g;
	$brent =~ s/6/x/g;
	$brent =~ s/3/R/g;
	$brent =~ s/A/^/g;
	$brent =~ s/\(/Ir/g;
	$brent =~ s/\*/Er/g;
	$brent =~ s/\)/Ur/g;
	$brent =~ s/\#/ar/g;
	$brent =~ s/\%/cr/g;
	#missing entries
	if ($word eq 'mmm'){
		print OUT "mm\txm\n";
		print OUT "mhm\txmhxm\n";
		print OUT "ohgoodness\togUdnIs\n";
		print OUT "mygoodness\tmYgUdnIs\n";
		print OUT "ohmygoodness\tomYgUdnIs\n";
		print OUT "guzenheit\@snle\tgxz^ndhYt\n";
		print OUT "mms\txmz\n";
	}

	print OUT "$word\t$brent\n"; # you'll need to delete the final line
}

close(OUT);


