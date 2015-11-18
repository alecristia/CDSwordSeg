#! usr/bin/perl

for($i=0;$i<5;$i++){

	open(CORPUS, "<brent9mos-unicode.txt") or die("Couldn't open corpus for reading.\n");
	while (<CORPUS>){
		push(@corp_lines, $_);
	}
	close(CORPUS);

	$begin = int(rand(25552)); #random number between 0 and # of lines(28391) - 10%(2839)
	$end = $begin + 2839;
	$index = $i+1;
	open(TEST, ">test-uni-9mos-clean" . $index . ".txt") or die("couldn't open test for writing.\n");
	open(TRAIN, ">train-uni-9mos-clean" . $index . ".txt") or die("couldn't open train for writing.\n");

	for($count = 0; $count<=28390; $count++){
		if($count >= $begin && $count<=$end){
			print TEST shift(@corp_lines);
		}else{
			print TRAIN shift(@corp_lines);
		}
	}

	close(TEST);
	close(TRAIN);
}
