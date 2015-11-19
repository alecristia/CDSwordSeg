#! usr/bin/perl

use Getopt::Long;
use utf8;

# Script to replicate the Precision and Recall measurements of Goldwater's script
# The idea being to mess with the inner workings to allow for a new error analysis

$guess; $true; $m; $vers; $morph; $unidict; $worddict; $funcword; $lang;
$result = GetOptions("true=s" => \$true,
	"guess=s" => \$guess,
	"model=s" => \$m,
	"vers=s" => \$vers,
	"morph=s" => \$morph,
	"unidict=s" =>\$unidict,
	"worddict=s" =>\$worddict,
	"funcword=s" =>\$funcword,
	"lang=s" =>\$lang);

binmode(STDOUT,":utf8");

# READ IN DATA
open(TRUE, "<$true") or die("Couldn't open true corpus\n");
binmode(TRUE,":utf8");

open(GUESS, "<$guess") or die("Couldn't open model results\n");
binmode(GUESS,":utf8");

@true_lines = <TRUE>; @model_lines = <GUESS>;
close(TRUE); close(GUESS);


# remove final empty lines
$n = @model_lines; $n = $n-1;
if($model_lines[$n] =~ /^\s+$/){
	pop(@model_lines);
	if($model_lines[$n-1] =~ /^\s+$/){
		pop(@model_lines);
	}
}

$n = @true_lines; $n = $n-1;
if($true_lines[$n] =~ /^\s+$/){
	pop(@true_lines);
	if($true_lines[$n-1] =~ /^\s+$/){
		pop(@true_lines);
	}
}

# remove all empty lines
@tmp_lines = @model_lines; undef(@model_lines);
for($i=0;$i<@tmp_lines;$i++){
	if($tmp_lines[$i] !~ /^$/){
		push(@model_lines,$tmp_lines[$i]);
	}
}

@tmp_lines = @true_lines; undef(@true_lines);
for($i=0;$i<@tmp_lines;$i++){
	if($tmp_lines[$i] !~ /^$/){
		push(@true_lines,$tmp_lines[$i]);
	}
}

# Read in acceptable morphology
%suffix; %prefix;
open(MORPH,"<$morph") or die("Couldn't open $morph\n");
@morph_lines = <MORPH>;
close(MORPH);
%unicode_dict;
open(DICT,"<$unidict") or die("couldn't open $unidict\n");
binmode(DICT,":utf8");
@dict_lines = <DICT>;
close(DICT);
foreach $line (@dict_lines){
	chomp($line);
	@array = split(/\s+/,$line);
	$uni_to_ipa{$array[1]} = $array[0]; # give it the Klattese, spits out unicode
	$ipa_to_uni{$array[0]} = $array[1];
}

foreach $line (@morph_lines){
	chomp($line); $line =~ s/\s//g;
	$ipa = $line; $ipa =~ s/\\//g;
	if($line =~ /\\\S+/){
		if(exists($ipa_to_uni{$ipa})){
			$suffix{$ipa_to_uni{$ipa}} = $ipa;
		}
	}elsif($line =~ /\S+\\/){
		if(exists($ipa_to_uni{$ipa})){
			$prefix{$ipa_to_uni{$ipa}} = $ipa;
		}
	}
}

# Read in Function Word List
%uni_to_word; %word_to_uni;
open(DICT,"<$worddict") or die("Couldn't open $worddict\n");
binmode(DICT,":utf8");
@dict_lines = <DICT>;
close(DICT);
foreach $line (@dict_lines){
	chomp($line);
	@array = split(/\t/,$line);
	$uni_to_word{$array[1]} = $array[0];
	$word_to_uni{$array[0]} = $array[1];
}

%func;
open(FUNC,"<$funcword") or die("Couldn't open $funcword\n");
@func_lines = <FUNC>;
close(FUNC);
foreach $line (@func_lines){
	chomp($line); $line =~ s/\s//g;
	if(exists($word_to_uni{$line})){
		$func{$word_to_uni{$line}} = $line;
	}
}

# Grab Ntokens, Nbounds, Nlexicon

$ntoken_true; $ntoken_model; $nlex_true; $nlex_model; $nbound_true; $nbound_model; %dict_true; %dict_model;
if(@true_lines != @model_lines){
	$n_true = @true_lines; $n_model = @model_lines;
	die("Model and True corpus are not of equal size:\nTrue:\t$n_true\tModel:\t$n_model\n");
}

for($i=0;$i<@true_lines;$i++){
	$true_line = $true_lines[$i]; $model_line = $model_lines[$i];
	chomp($true_line); chomp($model_line);

	# check sizes
	$check_true = $true_line; $check_model = $model_line;
	$check_true =~ s/ //g; $check_model =~ s/ //g;
	if($check_true ne $check_model){ die("Lines not equal:\t$i\nTrue:\t$check_true\nModel:\t$check_model\n");}

	@true_words = split(/ /,$true_line); @model_words = split(/ /,$model_line);

	# update token counts
	$ntoken_true = $ntoken_true + @true_words; $ntoken_model = $ntoken_model + @model_words;
	# update boundary counts
	$nbound_true = $nbound_true + @true_words - 1; $nbound_model = $nbound_model + @model_words - 1;

	# update lexicon counts
	foreach $word (@true_words){
		if(exists($dict_true{$word})){
			$dict_true{$word}++;
		}else{
			$dict_true{$word} = 1;
		}
	}
	foreach $word (@model_words){
		if(exists($dict_model{$word})){
			$dict_model{$word}++;
		}else{
			$dict_model{$word} = 1;
		}
	}
	$nlex_true = keys(%dict_true); $nlex_model = keys(%dict_model);

}

# Determine Frequent Words in the corpus (Occur more than 10 times)
$cutoff = 10;
%dict_freq;
@true_keys = keys %dict_true;
foreach $key (@true_keys){
	if($dict_true{$key}>=$cutoff){
		$dict_freq{$key} = 1;
	}
}

# Score Lexicons
$nlex_correct=0;
foreach $word (keys(%dict_model)){
	if(exists($dict_true{$word})){
		$nlex_correct++;
	}
}

$lex_precision = $nlex_correct / $nlex_model;
$lex_recall = $nlex_correct / $nlex_true;
$lex_Fscore = 2 * $lex_precision * $lex_recall / ($lex_precision + $lex_recall);


# Score Tokens

$ntoken_correct=0;
for($i=0;$i<@true_lines;$i++){
	@words_true = split(/ /,$true_lines[$i]); @words_model = split(/ /,$model_lines[$i]);
	
	$count_true=0; $count_model=0;
	$index_true[0]=$count_true; $index_model[0]=$count_model;
	$over_count=0; $under_count=0;

	$end=0;
	while($end!=1){
		# CHECK THAT WE'RE STILL IN BOUNDS
		if($count_true >= @words_true or $count_model >= @words_model){
			$end=1;
		}
		# END IF NECESSARY		
		if($end!=1){		


		# RECONSTRUCT CURRENT WORD HYPOTHESES
		undef($word_true);undef($word_model);		
		$word_true; $word_model;
		foreach $index (@index_true){
			$word_true = $word_true . " " . $words_true[$index];
		}
		foreach $index (@index_model){
			$word_model = $word_model . " " . $words_model[$index];
		}

		$word_true =~ s/^\s//g; $word_model =~ s/^\s//g;

		# CHECK FOR EQUIVALENCY
		if(join("",split(/ /,$word_true)) eq join("",split(/ /,$word_model))){ # If words are equivalent
			$error_line = $word_true . "\t" . $word_model;
			if($over_count==0 && $under_count==0){ # If correct
				push(@correct,1);
			}else{
				for($x=0;$x<@index_true;$x++){ push(@correct,0);} # If not correct
			}
			if($over_count==0 && $under_count!=0){ # If pure undersegmentation
				if(exists($under{$error_line})){
					$under{$error_line}++;
				}else{
					$under{$error_line} = 1;
				}
			}elsif($under_count==0 && $over_count!=0){ # If pure oversegmentation
				if(exists($over{$error_line})){
					$over{$error_line}++;
				}else{
					$over{$error_line} = 1;
				}
			}elsif($under_count>0 && $over_count>0){ # If a mix
				if(exists($other{$error_line})){
					$other{$error_line}++;
				}else{
					$other{$error_line} = 1;
				}
			}
			$count_true++; $count_model++; # move on to next words
			$over_count=0; $under_count=0; # Reset counters
			undef(@index_true);undef(@index_model); # Remove index entries and reset
			$index_true[0] = $count_true; $index_model[0] = $count_model;

		}elsif(length(join("",split(/ /,$word_true))) > length(join("",split(/ /,$word_model)))){ # If true is longer than model
			$count_model++; $over_count++;
			push(@index_model,$count_model); # Add another entry for the model
		}elsif(length(join("",split(/ /,$word_true))) < length(join("",split(/ /,$word_model)))){ # If model is longer than true
			$count_true++; $under_count++;
			push(@index_true,$count_true); # Add another entry for the true
		}
		}
	}
}

$ntoken_correct=0;
foreach $val (@correct){
	if($val==1){ $ntoken_correct++;}
}
$ntoken_precision = $ntoken_correct / $ntoken_model;
$ntoken_recall = $ntoken_correct / $ntoken_true;
$ntoken_Fscore = 2 * $ntoken_precision * $ntoken_recall / ($ntoken_precision + $ntoken_recall);

# Score Boundaries
@bounds_true; @bounds_model;
for($i=0;$i<@true_lines;$i++){
	@words_true = split(/ /,$true_lines[$i]); @words_model = split(/ /,$model_lines[$i]);
	
	foreach $word (@words_true){
		@units = split(//, $word); $n = @units;
		for($j=1;$j<$n;$j++){
			push(@bounds_true,0);
		}
		push(@bounds_true,1);
	}

	foreach $word (@words_model){
		@units = split(//, $word); $n = @units;
		for($j=1;$j<$n;$j++){
			push(@bounds_model,0);
		}
		push(@bounds_model,1);
	}
	# remove extra boundary at the end of each line
	pop(@bounds_true); pop(@bounds_model);
}


$nbound_correct = 0;
for($i=0;$i<@bounds_true;$i++){
	if($bounds_true[$i] == $bounds_model[$i] && $bounds_true[$i] == 1){
		$nbound_correct++;
	}
}

$nbound_precision = $nbound_correct / $nbound_model;
$nbound_recall = $nbound_correct / $nbound_true;
$nbound_Fscore = 2 * $nbound_precision * $nbound_recall / ($nbound_precision + $nbound_recall);


# Change scores
$total_errors=0;
$was_real_word=0; $was_morph=0; $was_func=0; $was_semifunc=0; undef(@correct); %correct;
$real_perc=0; $morph_perc=0; $func_perc=0; $semifunc_perc=0;
%found_morphemes;
foreach $error (keys %over){ # OVERSEGMENTATION
	$n = $over{$error};
	@mistakes = split(/\t/,$error);
	@model_words = split(/ /,$mistakes[1]);
	@true_words = split(/ /,$mistakes[0]);
	$model_n = @model_words; $true_n = @true_words;
	$trueword = $mistakes[0];

	$num_true=0; $num_morph=0; $real_word=0; $real_morph=0;
	for($i=0;$i<@model_words;$i++){
		$word = $model_words[$i];
		if(exists($dict_freq{$word})){ # Was the overseg a real, semi-frequent word?
			$num_true++;
			$real_word++;
			if(exists($correct{over}{real}{$word})){
				$correct{over}{real}{$word} = $correct{over}{real}{$word}+$n;
			}else{ $correct{over}{real}{$word}=$n; }
			if(exists($context{over}{real}{$trueword})){
				$context{over}{real}{$trueword} = $context{over}{real}{$trueword} + $n;
			}else{ $context{over}{real}{$trueword} = $n; }
		}elsif($i+1==@model_words and exists($suffix{$word})){ # Was the overseg suffix morphology?
			$num_true++;
			$num_morph++;
			$real_morph++;
			if(exists($correct{over}{morph}{$word})){
				$correct{over}{morph}{$word} = $correct{over}{morph}{$word}+$n;
			}else{ $correct{over}{morph}{$word}=$n; }
			if(exists($context{over}{morph}{$trueword})){
				$context{over}{morph}{$trueword} = $context{over}{morph}{$trueword}+$n;
			}else{ $context{over}{morph}{$trueword}=$n; }
		}elsif($i==0 and exists($prefix{$word})){ # Was the overseg prefix morphology?
			$num_true++;
			$num_morph++;
			$real_morph++;
			if(exists($correct{over}{morph}{$word})){
				$correct{over}{morph}{$word} = $correct{over}{morph}{$word}+$n;
			}else{ $correct{over}{morph}{$word}=$n; }
			if(exists($context{over}{morph}{$trueword})){
				$context{over}{morph}{$trueword} = $context{over}{morph}{$trueword}+$n;
			}else{ $context{over}{morph}{$trueword}=$n; }
		}
	}
	if($num_true>0){
		$nbound_correct = $nbound_correct + ($num_true - 1)*$n;
		$nbound_true = $nbound_true + ($num_true - 1)*$n;
		$ntoken_correct = $ntoken_correct + ($num_true)*$n;
		$ntoken_true = $ntoken_true + ($num_true - 1)*$n;

		# Sum num. of real words/morphemes found
		$was_real_word = $was_real_word + $real_word*$n;
		$was_morph = $was_morph + $real_morph*$n;

		# For calculating % errors with any real/func/etc...
		if($real_word > 0){ $real_perc = $real_perc + $n; }
		if($num_morph > 0){ $morph_perc = $morph_perc + $n; }
	}
	$total_errors = $total_errors + $n*$model_n;
}

foreach $error (keys %under){ # UNDERSEGMENTATION
	$n = $under{$error};
	@mistakes = split(/\t/,$error);
	@model_words = split(/ /,$mistakes[1]);
	@true_words = split(/ /,$mistakes[0]);
	$model_n = @model_words; $true_n = @true_words;
	$trueword = $mistakes[0];
	
	$num_true=0; $num_morph=0; $real_word=0; $real_morph=0; $real_func=0; $real_semifunc=0;

	for($i=0;$i<@model_words;$i++){
		$word = $model_words[$i];
#		if(exists($dict_true{$word})){ # Was the underseg a real word?
		if(exists($dict_freq{$word})){ # Was the underseg a real, semi-frequent word?
			$num_true++;
			$real_word++;
			if(exists($correct{under}{real}{$word})){
				$correct{under}{real}{$word} = $correct{under}{real}{$word}+$n;
			}else{ $correct{under}{real}{$word}=$n; }
			if(exists($context{under}{real}{$trueword})){
				$context{under}{real}{$trueword} = $context{under}{real}{$trueword}+$n;
			}else{ $context{under}{real}{$trueword}=$n; }
		}elsif($i+1==@model_words and exists($suffix{$word})){ # Was the underseg suffix morphology?
			$num_true++;
			$num_morph++;
			$real_morph++;
			if(exists($correct{under}{morph}{$word})){
				$correct{under}{morph}{$word} = $correct{under}{morph}{$word}+$n;
			}else{ $correct{under}{morph}{$word}=$n; }
			if(exists($context{under}{morph}{$trueword})){
				$context{under}{morph}{$trueword} = $context{under}{morph}{$trueword}+$n;
			}else{ $context{under}{morph}{$trueword}=$n; }
		}elsif($i==0 and exists($prefix{$word})){ # Was the underseg prefix morphology?
			$num_true++;
			$num_morph++;
			$real_morph++;
			if(exists($correct{under}{morph}{$word})){
				$correct{under}{morph}{$word} = $correct{under}{morph}{$word}+$n;
			}else{ $correct{under}{morph}{$word}=$n; }
			if(exists($context{under}{morph}{$trueword})){
				$context{under}{morph}{$trueword} = $context{under}{morph}{$trueword}+$n;
			}else{ $context{under}{morph}{$trueword}=$n; }
		}
	}

	# look for function word equivalencies ($error is ok, if composed entirely of func words)
	if($num_true==0){
		$num_func=0;
		foreach $word (@true_words){
			if(exists($func{$word})){
				$num_func++;
			}
		}
		if($num_func == $true_n){ # if all true words are function words
			$num_true = 1;
			$real_func++;
			$tmp_words = join(" ",@model_words);
			if(exists($correct{under}{func}{$tmp_words})){
				$correct{under}{func}{$tmp_words} = $correct{under}{func}{$tmp_words}+$n;
			}else{ $correct{under}{func}{$tmp_words}=$n; }
			if(exists($context{under}{func}{$trueword})){
				$context{under}{func}{$trueword} = $context{under}{func}{$trueword}+$n;
			}else{ $context{under}{func}{$trueword}=$n; }
		}
		if($num_func + 1 == $true_n){ # If all but one word is a function word
			$num_true = 1;
			$real_semifunc++;
			$tmp_words = join(" ",@model_words);
			if(exists($correct{under}{semifunc}{$tmp_words})){
				$correct{under}{semifunc}{$tmp_words} = $correct{under}{semifunc}{$tmp_words}+$n;
			}else{ $correct{under}{semifunc}{$tmp_words}=$n; }
			if(exists($context{under}{semifunc}{$trueword})){
				$context{under}{semifunc}{$trueword} = $context{under}{semifunc}{$trueword}+$n;
			}else{ $context{under}{semifunc}{$trueword}=$n; }
		}
	}

	if($num_true>0){
		$nbound_true = $nbound_true - ($true_n - 1)*$n;
		$ntoken_true = $ntoken_true - ($true_n - 1)*$n;
		$ntoken_correct = $ntoken_correct + $n;
		$was_real_word = $was_real_word + $real_word*$n;
		$was_morph = $was_morph + $real_morph*$n;
		$was_func = $was_func + $real_func*$n;
		$was_semifunc = $was_semifunc + $real_semifunc*$n;


		# For calculating % errors with any real/func/etc...
		if($real_word > 0){ $real_perc = $real_perc + $n; }
		if($num_morph > 0){ $morph_perc = $morph_perc + $n; }
		$func_perc = $func_perc + $real_func*$n;
		$semifunc_perc = $semifunc_perc + $real_semifunc*$n;
	}
	$total_errors = $total_errors + $n*$model_n;
}

# Adjust for new morphemes added to the lexicon
$nunique_morphemes = keys %found_morphemes;
$nlex_correct = $nlex_correct + $nunique_morphemes;
$nlex_true = $nlex_true + $nunique_morphemes;

# Add in other errors for the total
foreach $val (keys %other){
	$n = $other{$val};
	@mistakes = split(/\t/,$error);
	@model_words = split(/ /,$mistakes[1]);
	$model_n = @model_words;
	$total_errors = $total_errors + $n*$model_n;
}

# Calculate % of errors with each type
$real_perc = $real_perc / $total_errors;
$morph_perc = $morph_perc / $total_errors;
$func_perc = $func_perc / $total_errors;
$semifunc_perc = $semifunc_perc / $total_errors;


$lex_precision = $nlex_correct / $nlex_model;
$lex_recall = $nlex_correct / $nlex_true;
$lex_Fscore = 2 * $lex_precision * $lex_recall / ($lex_precision + $lex_recall);

#print "LP: = $lex_precision\nLR: = $lex_recall\nLF: = $lex_Fscore\n";

$ntoken_precision = $ntoken_correct / $ntoken_model;
$ntoken_recall = $ntoken_correct / $ntoken_true;
$ntoken_Fscore = 2 * $ntoken_precision * $ntoken_recall / ($ntoken_precision + $ntoken_recall);

#print "TP: = $ntoken_precision\nTR: = $ntoken_recall\nTF: = $ntoken_Fscore\n";

$nbound_precision = $nbound_correct / $nbound_model;
$nbound_recall = $nbound_correct / $nbound_true;
$nbound_Fscore = 2 * $nbound_precision * $nbound_recall / ($nbound_precision + $nbound_recall);

#print "BP: = $nbound_precision\nBR: = $nbound_recall\nBF: = $nbound_Fscore\n";

#print "\n\nReal Words:\t$was_real_word\nMorphology:\t$was_morph\nFunction Words:\t$was_func\n";

print "$m,$vers,$ntoken_precision,$ntoken_recall,$ntoken_Fscore,$nbound_precision,$nbound_recall,$nbound_Fscore,$lex_precision,$lex_recall,$lex_Fscore,$was_real_word,$was_morph,$was_func,$was_semifunc,$total_errors,$real_perc,$morph_perc,$func_perc,$semifunc_perc,\n";

# PRINT OUT ERRORS WITH COUNTS FROM %CORRECT
@order_out;
push(@order_out,"okayerrors/$lang/$m\:$vers\_over_real\.txt");
push(@order_out,"okayerrors/$lang/$m\:$vers\_over_morph\.txt");
push(@order_out,"okayerrors/$lang/$m\:$vers\_under_real\.txt");
push(@order_out,"okayerrors/$lang/$m\:$vers\_under_morph\.txt");
push(@order_out,"okayerrors/$lang/$m\:$vers\_under_func\.txt");
@errors = qw(over over under under under);
@types = qw(real morph real morph func);

for($i=0;$i<@order_out;$i++){

	open(OUT,">$order_out[$i]") or die("couldn't open $order_out[$i]\n");
	binmode(OUT,":utf8");
		
	$error = $errors[$i]; $type = $types[$i];

	undef(%tmp_hash);
	foreach $key (keys %{$correct{$error}{$type}}){
		$tmp_hash{$key} = $correct{$error}{$type}{$key};
	}

	foreach (sort { ($tmp_hash{$b} <=> $tmp_hash{$a}) } keys %tmp_hash){
		print OUT "$_\t$tmp_hash{$_}\n";
	}

	close(OUT);
}


# PRINT OUT ERRORS WITH COUNTS FROM %CONTEXT
undef(@order_out); @order_out;
push(@order_out,"okayerrors/$lang/$m\:$vers\_over_real_context\.txt");
push(@order_out,"okayerrors/$lang/$m\:$vers\_over_morph_context\.txt");
push(@order_out,"okayerrors/$lang/$m\:$vers\_under_real_context\.txt");
push(@order_out,"okayerrors/$lang/$m\:$vers\_under_morph_context\.txt");
push(@order_out,"okayerrors/$lang/$m\:$vers\_under_func_context\.txt");
@errors = qw(over over under under under);
@types = qw(real morph real morph func);

for($i=0;$i<@order_out;$i++){

	open(OUT,">$order_out[$i]") or die("couldn't open $order_out[$i]\n");
	binmode(OUT,":utf8");
		
	$error = $errors[$i]; $type = $types[$i];

	undef(%tmp_hash);
	foreach $key (keys %{$context{$error}{$type}}){
		$tmp_hash{$key} = $context{$error}{$type}{$key};
	}

	foreach (sort { ($tmp_hash{$b} <=> $tmp_hash{$a}) } keys %tmp_hash){
		print OUT "$_\t$tmp_hash{$_}\n";
	}

	close(OUT);
}
