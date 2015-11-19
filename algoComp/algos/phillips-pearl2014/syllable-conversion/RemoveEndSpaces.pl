#! usr/bin/perl

# Remove line-final spaces from brent9mos

open(IN, "<brent9mos.txt") or die("couldn't open brent9mos.txt for reading.\n");
@brent9mos = <IN>;
close(IN);
open(OUT, ">brent9mos.txt") or die("couldn't open brent9mos.txt for writing.\n");
foreach (@brent9mos){
	$_ =~ s/\s\n/\n/;
	print OUT $_;
}
close(OUT);

open(IN, "<brent9mos-klatt.txt") or die("couldn't open brent9mos-klatt.txt for reading.\n");
@brent9mos = <IN>;
close(IN);
open(OUT, ">brent9mos-klatt.txt") or die("couldn't open brent9mos-klatt.txt for writing.\n");
foreach (@brent9mos){
	$_ =~ s/\s\n/\n/;
	print OUT $_;
}
close(OUT);

open(IN, "<brent9mos-unicode.txt") or die("couldn't open brent9mos-unicode.txt for reading.\n");
binmode(IN, ":utf8");
@brent9mos = <IN>;
close(IN);
open(OUT, ">brent9mos-unicode.txt") or die("couldn't open brent9mos-unicode.txt for writing.\n");
binmode(OUT, ":utf8");
foreach (@brent9mos){
	$_ =~ s/\s\n/\n/;
	print OUT $_;
}
close(OUT);
