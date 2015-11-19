#! usr/bin/perl

use utf8;

@order = qw(eng);

%unidict;
$unidict{eng} = "../corpora_clean/unicode-dict.txt";

@order_models = qw(U_I U_V U_D U_DMCMC B_I B_V B_D B_DMCMC);
@order_vers = 1..5;
@order_errors = qw(under_real under_morph under_func over_real over_morph);


%dict; %sum_dict; # Dict holds data condensed across versions, sum_dict is also condensed across learners
foreach $lang (@order){
	undef(%uni_to_ipa); %uni_to_ipa;


	open(DICT,"<$unidict{$lang}")or die("couldn't open $unidict{$lang}\n");
	binmode(DICT,":utf8");
	foreach $line (<DICT>){
		chomp($line);
		@array = split(/\s+/,$line);
		$uni_to_ipa{$array[1]} = $array[0];
#		print "$array[1]\t$array[0]\n";
	}
	close(DICT);
	$uni_to_ipa{' '} = ' ';

	foreach $model (@order_models){
		foreach $error (@order_errors){
			foreach $vers (@order_vers){
				$file = "okayerrors/$lang/$model\:$vers\_$error\.txt";
				open(IN,"<$file") or die("couldn't open $file\n");
				binmode(IN,":utf8");
				@lines = <IN>; chomp(@lines);
				close(IN);

				foreach $line (@lines){
					undef($uni); undef($num); undef($ipa);
					@array = split(/\t/,$line);
					$uni = $array[0]; $num = $array[1];

					@chars = split(//,$uni); undef(@ipa_array); @ipa_array;
					foreach $c (@chars){
						if(exists($uni_to_ipa{$c})){ push(@ipa_array,$uni_to_ipa{$c});}else{ print "No match:\t$c\t$lang\n"; }
					}
					$ipa = join("",@ipa_array);

					if(exists($dict{$lang}{$model}{$error}{$ipa})){
						$dict{$lang}{$model}{$error}{$ipa} = $dict{$lang}{$model}{$error}{$ipa} + $num;
					}else{ $dict{$lang}{$model}{$error}{$ipa} = $num; }

					if(exists($sum_dict{$lang}{$error}{$ipa})){
						$sum_dict{$lang}{$error}{$ipa} = $sum_dict{$lang}{$error}{$ipa} + $num;
					}else{ $sum_dict{$lang}{$error}{$ipa} = $num; }
				}
			}
		}
	}
}

open(OUT, ">okayerrors/summary.txt")or die("couldn't open summary.txt\n");
foreach $lang (@order){
	foreach $error (@order_errors){
		foreach $model (@order_models){
			print OUT "$lang\t$error\t$model\n";
			undef(%tmp_hash); %tmp_hash; %tmp = %{$dict{$lang}{$model}};
			foreach $key (keys %{$tmp{$error}}){
				$tmp_hash{$key} = $dict{$lang}{$model}{$error}{$key};
			}
			
			@sorted_keys = (sort { ($tmp_hash{$b} <=> $tmp_hash{$a}) } keys %tmp_hash);
			
			$n = @sorted_keys; #print "$sorted_keys[0]\n";

			$max = 10; if($max > @sorted_keys){ $max = @sorted_keys; }
			for($i=0;$i<$max;$i++){
				$key = $sorted_keys[$i]; $val = $tmp_hash{$sorted_keys[$i]};
				print OUT "\t$key\t$val\n";
			}
		}
		print OUT "\n";
	}
	print OUT "\n";
}
close(OUT);

# Condense numbers across all 4 models
open(OUT, ">okayerrors/summary_condensed.txt")or die("couldn't open summary.txt\n");
foreach $lang (@order){
	foreach $error (@order_errors){
		print OUT "$lang\t$error\n";
		undef(%tmp_hash); %tmp_hash;
		foreach $key (keys %{$sum_dict{$lang}{$error}}){
			$tmp_hash{$key} = $sum_dict{$lang}{$error}{$key};
		}
		
		@sorted_keys = (sort { ($tmp_hash{$b} <=> $tmp_hash{$a}) } keys %tmp_hash);
		
		$n = @sorted_keys; #print "$sorted_keys[0]\n";

		$max = 10; if($max > @sorted_keys){ $max = @sorted_keys; }
		for($i=0;$i<$max;$i++){
			$key = $sorted_keys[$i]; $val = $tmp_hash{$sorted_keys[$i]};
			print OUT "\t$key\t$val\n";
		}
		print OUT "\n";
	}
	print OUT "\n";
}
close(OUT);

