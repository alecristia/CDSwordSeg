#! usr/bin/perl

open(CODE,"<load_directories.pl") or die("couldn't open load_directories\n");
binmode(CODE,":utf8");
foreach $line (<CODE>){ eval($line); }
close(CODE);
# Reminder:
# %dir = output directory e.g. '../output_clean/english'
# %language = e.g. 'English'
# %name = e.g. '9mos'
# %params = e.g. '1\t1\t90'
# %res_dir = e.g. '../results/English'
# $corp_dir = '../corpora_clean'
# %cross_dir = e.g. '../ForeignCorpora/JapaneseCorpus/'
# %uni_file = e.g. $cross_dir{eng} . 'brent9mos-text-uni-clean.txt';
# %syl_file = e.g. $cross_dir{eng} . 'brent9mos-text-syl-clean.txt';
# %klatt_file = e.g. $cross_dir{eng} . 'brent9mos-text-klatt-clean.txt';
# %vowels = e.g. 'aeiou'

@order = qw(eng);


foreach $lang (@order){
	# Initialize data
	$TP=0; $TR = 0; $TF = 0;
	$BP=0; $BR = 0; $BF = 0;
	$LP=0; $LR = 0; $LF = 0;

	$resfile = "$res_dir{$lang}segment_all.txt";

	for($i=1;$i<=5;$i++){
		$infile = "$corp_dir" . "test-uni-$name{$lang}-clean$i.txt";
		$outfile = "$dir{$lang}segment_all_$i.txt";

		# Read in True Corpus
		open(INPUT,"<$infile")or die("Couldn't open $infile\n");
		binmode(INPUT, ":utf8");
		@input = <INPUT>; undef(@clean); @clean;
		foreach $line (@input){
			$line =~ s/ $//;
			$line =~ s/  / /;

			if($line !~ /^\s*$/){ push(@clean,$line); }
		}
		close(INPUT);

		open(OUT,">$outfile") or die("Couldn't open $outfile\n");
		binmode(OUT, ":utf8");
		foreach $line (@clean){
			$line =~ s/\s//g;
			print OUT join(' ', split(//,$line)) . "\n";
		}
		close(OUT);

		# second line contains the scores
		@results = `perl ../score_seg_chunks.prl $infile $outfile`;
		$data = $results[1];

		# Update values
		$data =~ /^P (.+) R/;
		$TP = $TP + $1;
		$data =~ /R (.+) F/;
		$TR = $TR + $1;
		$data =~ /F (.+) BP/;
		$TF = $TF + $1;
		$data =~ /BP (.+) BR/;
		$BP = $BP + $1;
		$data =~ /BR (.+) BF/;
		$BR = $BR + $1;
		$data =~ /BF (.+) LP/;
		$BF = $BF + $1;
		$data =~ /LP (.+) LR/;
		$LP = $LP + $1;
		$data =~ /LR (.+) LF/;
		$LR = $LR + $1;
		$data =~ /LF (.+)$/;
		$LF = $LF + $1;


	}

	# Average over 5 trials
	$TP = $TP / 5; $TR = $TR / 5; $TF = $TF / 5;
	$BP = $BP / 5; $BR = $BR / 5; $BF = $BF / 5;
	$LP = $LP / 5; $LR = $LR / 5; $LF = $LF / 5;

	# Output statistics
	open(RESULTS,">$resfile") or die("Couldn't open $resfile\n");
	print RESULTS "$lang\nTP\tTR\tTF\tBP\tBR\tBF\tLP\tLR\tLF\n";
	printf RESULTS "%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f", $TP,$TR,$TF,$BP,$BR,$BF,$LP,$LR,$LF;
	close(RESULTS);
}

print "\n"; # Because score_seg_chunks outputs '.' to the terminal but without a newline
