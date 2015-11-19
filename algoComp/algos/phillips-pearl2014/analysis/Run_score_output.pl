#! usr/bin/perl

use utf8;

# Run score_output.pl over every model result and average for each model type of a given language

@order = qw(eng);

%dir;
$dir{eng} = '../output_clean/english';

%language;
$language{eng} = "English";

%name;
$name{eng} = '9mos';

%params;
$params{eng} = "1\t1\t90";

%res_dir;
$res_dir{eng} = '../results/English';

%morph;
$morph{eng} = "morphology.txt";

%unidict;
$unidict{eng} = "../corpora_clean/unicode-dict.txt";

%worddict;
$worddict{eng} = "../corpora_clean/unicode-word-dict.txt";

%funcword;
$funcword{eng} = "funcwords.txt";

$corp_dir = '../corpora_clean';

foreach $lang (@order){

	# clear previous results
	open(ERASE,">../results/$res_dir{$lang}/altered_results.txt") or die("Couldn't erase previous results\n");
	close(ERASE);

	@p = split("\t",$params{$lang});
	$a = shift(@p); $b1 = shift(@p); $b2 = shift(@p);

	$d = $dir{$lang}; $res_d = $res_dir{$lang};

	@files = <$d/*.txt>; @unigram; @bigram;
	foreach $file (@files){
		if( $file =~ /U.*\:.*$a\.ver/ and $file !~ /stats/){ # There are duplicates where B_DMCMC: became B_DMCMC_, ignore these files
			push(@myfiles, $file);
		}elsif( $file =~ /B.*\:.*$b1\.$b2.*/ and $file !~ /stats/ ){
			push(@myfiles, $file);
		}
	}

# Run full_mistakes.pl for each model and append results to full_mistakes.txt
foreach $model (@myfiles){
	print "$model\n";
	if($model =~ /B_/){
		$gram = "B";
	}elsif($model =~ /U_/){
		$gram = "U";
	}
	if($model =~ /DMCMC/){
		$m = "DMCMC";
	}elsif($model =~ /I/){
		$m = "I";
	}elsif($model =~ /V/){
		$m = "V";
	}elsif($model =~ /D/){
		$m = "D";
	}
	if($model =~ /(\d)\.txt/){
		$vers = $1;
	}
	$model_name = $gram . "_" . $m;

	system("perl score_output.pl --true $corp_dir/test-uni-" . $name{$lang} . "-clean" . $vers . ".txt " . "--guess $model --model $model_name --vers $vers > tmp.txt --morph " . $morph{$lang} . " --unidict " . $unidict{$lang} . " --worddict " . $worddict{$lang} . " --funcword " . $funcword{$lang} . " --lang " . $lang);

	open(TMP,"<tmp.txt") or die("couldn't open temp file\n");
	binmode(TMP,":utf8");
	@lines = <TMP>;
	close(TMP);
	
	open(OUT,">>../results/$res_dir{$lang}/altered_results.txt") or die("couldn't open altered_results.txt\n");
	binmode(OUT,":utf8");
	foreach $line (@lines){
		print OUT $line;
	}
	close(OUT);

}
#die("dead\n");
# Read in altered_results, save data, then reprint as averages
open(IN,"<../results/$res_dir{$lang}/altered_results.txt") or die("couldn't open altered_results for reading\n");
@lines = <IN>;
close(IN);
%dict;
foreach $line (@lines){
	@array = split(/,/,$line);
	$model_name = shift(@array);
	$vers_num = shift(@array);

	$tag = $model_name . " ". $vers_num;
	$dict{$tag} = join(',',@array);
}

@model_order = qw(U_I U_V U_D U_DMCMC SPLIT B_I B_V B_D B_DMCMC);
open(OUT,">../results/$res_dir{$lang}/altered_results.txt") or die("Couldn't open altered_results for writing\n");
open(CSV,">../results/$res_dir{$lang}/altered_results_csv.txt") or die("couldn't open csv version for writing\n");
$spacing = "         ";
print OUT "$language{$lang}\n\tTP$spacing TR$spacing TF$spacing BP$spacing BR$spacing BF$spacing LP$spacing LR$spacing LF\t\tReal\t\tMorph\t\tFunc\t\tSemiFunc\tTotal\t\tReal%\t\tMorph%\t\tFunc%\tSemiFunc%\n";

foreach $curr_model (@model_order){
	if($curr_model eq "SPLIT"){ print OUT "\n\n";}else{

	@keys = keys(%dict);
	undef(@true_keys); @true_keys;
	foreach $key (@keys){
		if($key =~ /^$curr_model /){
			push(@true_keys,$key);
		}
	}

	undef(@sum); @sum; undef(%all_values); %all_values;
	for($vers=0;$vers<@true_keys;$vers++){
		$key = $true_keys[$vers];
		@array = split(/,/,$dict{$key});
		$narray = @array - 1;
		
		print CSV "$curr_model,1,";

		for($i=0;$i<$narray;$i++){
			$sum[$i] += $array[$i];
			$all_values{$vers}{$i} = $array[$i];	
			print CSV sprintf("%.4f",$array[$i]); if($i+1!=$narray){ print CSV ","; }else{ print CSV "\n"; }
		}
	}

	undef(@averages); @averages;
	for($i=0;$i<$narray;$i++){
		$averages[$i] = $sum[$i] / 5;
		if($i<9 or $i>13){
			$averages[$i] = $averages[$i] * 100;
			for($vers=0;$vers<5;$vers++){
				$all_values{$vers}{$i} = $all_values{$vers}{$i} * 100;
			}
		}
	} 

	undef(@stds); @stds;
	for($i=0;$i<$narray;$i++){
		if($i>=9 and $i < 13){
			# For our percents, we need to calculate these dividing by the total # of errors
			if($averages[13] != 0){
				$averages[$i] = $averages[$i] / $averages[13] * 100;
				for($vers=0;$vers<5;$vers++){
					if($all_values{$vers}{13} != 0){
						$all_values{$vers}{$i} = $all_values{$vers}{$i} / $all_values{$vers}{13} * 100;
					}else{ $all_values{$vers}{$i} = "NaN"; }
				}
			}else{
				$averages[$i] = "NaN";
				$stds[$i] = "NaN";
			}
		}
		if($stds[$i] ne "NaN"){
			$sq_error = 0;
			for($vers=0;$vers<5;$vers++){
				$sq_error += ($averages[$i] - $all_values{$vers}{$i}) ** 2;
			}
			$stds[$i] = sprintf("%.2f",($sq_error / 4) ** .5);
		}
	}
	

	for($i=0;$i<$narray;$i++){
		if($averages[$i] ne "NaN"){
			$averages[$i] = sprintf("%.2f",$averages[$i]);
		}
	}

	# formatting junk
	if($curr_model =~ /D$/){ $curr_model =~ s/D/T/; }elsif($curr_model =~ /DMCMC/){ $curr_model =~ s/DMCMC/D/; }

	print OUT "$curr_model:\t";
	for($i=0;$i<$narray;$i++){
		print OUT "$averages[$i]($stds[$i])"; if($i+1 != $narray and $i<8){ print OUT " ";}elsif($i>=8 and $i+1 != $narray){ print OUT "\t"; }else{ print OUT "\n"; }
	}
		
	}
}

close(OUT);
close(CSV);

undef(@myfiles);
}
