#!/usr/bin/perl

# Uses the maximum onset principle to fully syllabify the Callhome dictionary 
# and print it to syllabified-dict.txt.


# Save valid onsets from ValidOnsets.txt
%onsets = {};
open(ONSETS, "<../data/ValidOnsets.txt") or die("Couldn't open data/ValidOnsets.txt\n");
while(defined($fileline = <ONSETS>)){
		chomp($fileline);
		$fileline =~ s/L/l/g;
		$fileline =~ s/G/J/g;
		$fileline =~ s/\~/n/g;
		$fileline =~ s/N/G/g;
		$fileline =~ s/c/C/g;
		$fileline =~ s/M/m/g;
		$fileline =~ s/\r//g;
#print "$fileline\n";
		$onsets{$fileline} = 1;
}
close(ONSETS);

#foreach $val (sort (keys %onsets)){
 # print("debug: $syl\t$dict{$syl}\n");
 # print( "$val\t$onsets{$val}\n");
#}
#$w = "w";
#if( exists($onsets{$w})){ print "Yes";}
#print "$onsets{$w}";

#@onset_keys = keys %onsets;
#@onset_vals = values %onsets;
#if (defined($onset_keys[1])){
#foreach $val (@onset_vals){
#if ($onset_keys[1] =~ /$val/){
#print "\n$onset_keys[1]\n";
#}}}
#print "$onset_vals[0]\n";

open(MRCCALL, "<../data/mrc-call-syllabified.txt") or die("Couldn't open data/mrc-call-syllabified.txt for reading");
%mrccall = {}; # hash holds already syllabified word = syllabification
while(defined($fileline = <MRCCALL>)){
	chomp($fileline);
	if ($fileline =~ /^([\w|\@|\'|\-|\^]+)\s*(.*)$/){
		#$fileline =~ s/\r//g;
		$mrccall{$1} = $2;
	}
}
close(MRCCALL);

# Go through dict-brent.txt,
# for nonsyllabified words: for each syllable, find its vowel, and its maximum onset, given acceptable onsets and beginning of word.
# print syllabified version to syllabified-dict.txt.
open(SYLLABIFIED, ">../../fromCHAtoSND/input/syllabified-dict.txt") or die("Couldn't open ../../fromCHAtoSND/input/syllabified-dict.txt for writing\n");
open(DICT, "<../../fromCHAtoSND/input/dict-Brent-Klatt.txt") or die("../../fromCHAtoSND/input/dict-brent-klatt.txt for reading");
@englishwords=();  #the words in non-IPA, normal english. 

while(defined($fileline = <DICT>)){
	$curr = $fileline;
	chop($curr);
	# extract first syllable and add to list of acceptable onsets.
if($curr =~ /^([\w|\@|\'|\-|\^]+)\s*(.*)$/){
		$curreng = $1; # english word
		if (exists($mrccall{$curreng})){ # if there's already a syllabification use it
			if ( $curreng =~ /^a$/){}#print "Found a:\t$mrccall{$curreng}\n";
			$entry = $mrccall{$curreng};
			$entry =~ s/\r//g;
		}else{ # otherwise start doing an automatic segmentation
		$word = $2; # IPA transcription
		$currsyllable = "";
		$entry = "";
		# work backwards with each word..
		@wordarray = split(//, $word);
		while(@wordarray > 0){
			$currchar = pop(@wordarray); # get current char
			$currsyllable = $currchar . $currsyllable; # add current char to current syllable 
#print "\n Considering : $currchar\n";
			# if hit a vowel..
			if($currchar =~ /[iIeE\@acoUuYOWRx\^]/){
#print "Hit vowel!\n"; 
			#print "Word array: @wordarray\n";	
			#if (@wordarray > 0) { print "Word array > 0\n";
			#	if(exists ($onsets{$wordarray[@wordarray-1]})) { print "Exists\n";}
#}
				# find and add consonants for valid onset
				$onset = "";
				#if(@wordarray > 0){ print "$curr\t$currchar\t$wordarray[@wordarray-1]\t$onsets{$wordarray[@wordarray-1]}\t1\n";}
				while(@wordarray > 0 && exists($onsets{$wordarray[@wordarray-1] . $onset})){
					$currchar = pop(@wordarray);
					$onset = $currchar . $onset;
					#print "\n added to onset : $currchar\n";
				}
				$currsyllable = $onset . $currsyllable;
				# add syllable to word entry
				$entry = "\/" . $currsyllable . $entry;
#print "added syllable: $currsyllable\n";
				$currsyllable = "";
			}
			elsif(@wordarray == 0){
				# add syllable to word entry
#print "entry: $entry, currsyl: $currsyllable\n";
				$entry = "\/" . $currsyllable . $entry;
#print "added syllable: $currsyllable\n";
				$currsyllable = "";
			}
		}
		
		# print syllables as entry in collection of syllabified words
		#(also add space for abc-type entries)
		$entry =~ s/\/$//g; # remove last '/'
		$entry =~ s/^\///g; # remove first '/"
		$entry = " " . $entry;
		#$entry = " " . $entry;
		# remove first space..
		$entry =~ s/^\s//g;
	}
	}
	if($entry){
		print SYLLABIFIED "$curreng\t$entry\n";
	}
}

close(SYLLABIFIED);
close(DICT);
