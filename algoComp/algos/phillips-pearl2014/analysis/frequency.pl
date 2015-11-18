#! usr/bin/perl

use Math::NumberCruncher;
use POSIX;

# Script to calculate the relative frequency of words for both the ideal and the DMCMC learners

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

	open(OUT,">frequency_$lang.txt") or die("couldn't open frequency_$lang.txt\n");

	@pars = split(/\t/,$params{$lang});
	$a = $pars[0]; $b1 = $pars[1]; $b2 = $pars[2];

	@files = <$dir{$lang}*.txt>;
	foreach $file (@files){
		if($file =~ /B\_DMCMC:0\.$b1\.$b2\./ and $file !~ /stats/){
			push(@dmcmc_b,$file);
		}elsif($file =~ /U\_DMCMC:0\.$b1\./ and $file !~ /stats/){
			push(@dmcmc_u,$file);
		}elsif($file =~ /B\_I:0\.$b1\.$b2\./ and $file !~ /stats/){
			push(@ideal_b,$file);
		}elsif($file =~ /U\_I:0\.$b1\./ and $file !~ /stats/){
			push(@ideal_u,$file);
		}elsif($file =~ /B\_DPS:0\.$b1\.$b2\./ and $file !~ /stats/){
			push(@dps_b,$file);
		}elsif($file =~ /U\_DPS:0\.$b1\./ and $file !~ /stats/){
			push(@dps_u,$file);
		}elsif($file =~ /B\_V:0\.$b1\.$b2\./ and $file !~ /stats/){
			push(@v_b,$file);
		}elsif($file =~ /U\_V:0\.$b1\./ and $file !~ /stats/){
			push(@v_u,$file);
		}
	}

	# Calculate frequency of true words and then find avg. for the words each learner found

	open(IN,"<$uni_file{$lang}") or die ("couldn't open $uni_file{$lang}\n");
	binmode(IN,":utf8");
	@lines = <IN>;
	close(IN);

	# Create list of function words

	%uni_to_word; %word_to_uni;
	open(DICT,"<$worddict{$lang}") or die("Couldn't open $worddict{$lang}\n");
	binmode(DICT,":utf8");
	@dict_lines = <DICT>; chomp(@dict_lines);
	close(DICT);
	foreach $line (@dict_lines){
		@array = split(/\t/,$line);
		$uni_to_word{$array[1]} = $array[0];
		$word_to_uni{$array[0]} = $array[1];
	}
	undef(@dict_lines);

	open(FUNC,"<$funcword{$lang}") or die("Couldn't open $funcword{$lang}\n");
	binmode(FUNC,":utf8");
	@func_lines = <FUNC>; chomp(@lines);
	close(FUNC);
	%func;
	foreach $line (@func_lines){
		$line =~ s/\s//g;
		if(exists($word_to_uni{$line})){
			$func{$word_to_uni{$line}} = $line;
		}
	}
	undef(@func_lines);
	
	%raw;
	# identify each word and its raw count
	foreach $line (@lines){
		chomp($line);
		@words = split(' ',$line);
		foreach $word (@words){
			if(exists($raw{$word})){
				$raw{$word}++;
			}else{
				$raw{$word} = 1;
			}
		}
	}

	# produce freq counts
	%freq; $nwords=0;
	foreach $key (keys %raw){
		$nwords = $nwords + $raw{$key};
	}
	foreach $key (keys %raw){
		if(!exists($func{$key})){
			$freq{$key} = log($raw{$key} / $nwords);
		}
	}

	# produce score for each model
	# for each token add freq. score and average over final
	@models = qw(I_U V_U T_U D_U space I_B V_B t_B D_B);

	foreach $type (@models){

		if($type eq "I_U"){ @files = @ideal_u;}
		elsif($type eq "I_B"){ @files = @ideal_b;}
		elsif($type eq "V_U"){ @files = @v_u;}
		elsif($type eq "V_B"){ @files = @v_b;}
		elsif($type eq "T_U"){ @files = @dps_u;}
		elsif($type eq "T_B"){ @files = @dps_b;}
		elsif($type eq "D_U"){ @files = @dmcmc_u;}
		elsif($type eq "D_B"){ @files = @dmcmc_b;}
		elsif($type eq "space"){ print OUT "\n\n"; }

		if($type ne "space"){

		undef(@avgs); @avgs; undef(@avgs1); undef(@avgs2); undef(@avgs3); undef(@avgs4); @avgs1; @avgs2; @avgs3; @avgs4;
		foreach $file (@files){
			open(IN,"<$file");
			binmode(IN,":utf8");
			@lines = <IN>;
			close(IN);
#			print "$file\n";

			$score=0; $found=0; $avg=0; $num=0; $n = @lines;
			$score1=0; $found1=0; $score2=0; $found2=0; $score3=0; $found3=0; $score4=0; $found4=0; # Quartile results
			$avg1=0; $avg2=0; $avg3=0; $avg4=0;
			foreach $line (@lines){
				$num++; 
				chomp($line);
				@words = split(' ',$line);
				foreach $word (@words){
					if(exists($freq{$word})){
						$score = $score + $freq{$word};
						$found++;
						if($num <= floor($n/4)){
							$score1 = $score1 + $freq{$word};
							$found1++;
						}elsif($num <= floor($n/4)*2){
							$score2 = $score2 + $freq{$word};
							$found2++;
						}elsif($num <= floor($n/4)*3){
							$score3 = $score3 + $freq{$word};
							$found3++;
						}else{
							$score4 = $score4 + $freq{$word};
							$found4++;
						}
					}
				}
			}
			# average over the counts
			$avg = $score / $found;	push(@avgs,$avg);

			$avg1 = $score1 / $found1; push(@avgs1,$avg1);
			$avg2 = $score2 / $found2; push(@avgs2,$avg2);
			$avg3 = $score3 / $found3; push(@avgs3,$avg3);
			$avg4 = $score4 / $found4; push(@avgs4,$avg4);
		}
		$log_avg = Math::NumberCruncher::Mean(\@avgs);
		$log_avg1 = Math::NumberCruncher::Mean(\@avgs1);
		$log_avg2 = Math::NumberCruncher::Mean(\@avgs2);
		$log_avg3 = Math::NumberCruncher::Mean(\@avgs3);
		$log_avg4 = Math::NumberCruncher::Mean(\@avgs4);

		$log_avg = sprintf("%.2f",$log_avg);$log_avg1 = sprintf("%.2f",$log_avg1);$log_avg2 = sprintf("%.2f",$log_avg2);$log_avg3 = sprintf("%.2f",$log_avg3);$log_avg4 = sprintf("%.2f",$log_avg4);
		print OUT "$type:  \tTotal:\t$log_avg\t1stQ:\t$log_avg1\t2ndQ:\t$log_avg2\t3rdQ:\t$log_avg3\t4thQ:\t$log_avg4\n";
		}
	}
	close(OUT);
}
