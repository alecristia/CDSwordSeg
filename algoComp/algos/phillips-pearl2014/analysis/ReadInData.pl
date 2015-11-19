#! usr/bin/perl

# Reads in every file and averages over the 5 trials.

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
	@p = split("\t",$params{$lang});
	$a = shift(@p); $b1 = shift(@p); $b2 = shift(@p);

	$d = $dir{$lang}; $res_d = $res_dir{$lang};

	@files = <$d/*stats.txt>; @unigram; @bigram;
	foreach $file (@files){
		if( $file =~ /U.*$a\.ver\dstats/ ){
			push(@myfiles, $file);
		}elsif( $file =~ /B.*$b1\.$b2.*stats/ ){
			push(@myfiles, $file);
		}
	}

%dict = ();

open(OUT, ">$res_d/results.txt") or die("Couldn't open results.txt\n");
$l = $language{$lang};
$initial_space = "    ";
$space = "         ";
print OUT "$l Corpus results\n\n$initial_space TP$space TR$space TF$space BP$space BR$space BF$space LP$space LR$space LF$space NLL\n";
foreach $file (@myfiles) {
	open(FILE, "<$file") or die("Couldn't open $file for reading\n");
	while($line = <FILE>){
		if ( $line =~ /\# ngram\=/p){
			$ngram = ${^POSTMATCH};
		}
		elsif ( $line =~ /\# estimator\= /p){
			$estimator = ${^POSTMATCH};
		}
		elsif ( $line =~ /\# data\-file\=.+\-clean(\d)/){
			$version = $1;
		}
		elsif ( $line =~ /final posterior \= \-(\d*)/){
			$logL = $1;
		}
		elsif (eof FILE) {
			$file_data = $line;
		}
	}
	$file_data = $file_data . ' LogL ' . $logL;
	$file_data =~ s/\n//;

	close(FILE);
	chomp($ngram); chomp($estimator);
	$tmp_name = $ngram . '_' . $estimator;

	$dict{$tmp_name}{$version} = $file_data;
}

@model_order = qw(1_F 1_V 1_T 1_D SPLIT 2_F 2_V 2_T 2_D);

# For each model...
foreach $model (@model_order){
	if($model =~ /SPLIT/){
		print OUT "\n";
	}else{
	# Initialize data
	undef(@curr_data); @curr_data;
	undef(%all_data); %all_data; undef(@agg_data); @agg_data;
	# For each iteration of the model
	foreach $vers_num (keys %{$dict{$model}}){
		# Update values
		$curr_line = $dict{$model}{$vers_num};
		$curr_line =~ s/[PRFBLog]//g;
		$curr_line =~ s/^ +//g;
		$curr_line =~ s/ +$//g;
		$curr_line =~ s/\s+/ /g;

		@curr_data = split(/\s/,$curr_line);
		for($i=0;$i<@curr_data;$i++){
			$all_data{$vers_num}{$i} = $curr_data[$i];
			$agg_data[$i] += $curr_data[$i];
		}
	
	}
	undef(@averages); @averages; undef(@stds); @stds;
	print OUT "$model  ";
	for($i=0;$i<@agg_data;$i++){
		$averages[$i] = $agg_data[$i] / 5;
		print OUT sprintf("%.2f",$averages[$i]);

		$sq_error = 0;
		foreach $key (keys %all_data){
			$sq_error += ($averages[$i] - $all_data{$key}{$i}) ** 2;
		}
		$std = ($sq_error / ((keys %all_data)-1)) ** .5;
		$std = sprintf("%.2f",$std);

		print OUT "($std)"; if($i+1 != @agg_data){ print OUT " ";}else{ print OUT "\n"; }
	}
	}
}
close(OUT);

}
