#! usr/bin/perl

# Uses the maximum onset principle to fully syllabify the Callhome dictionary 
# and print it to syllabified-dict.txt.


# Save valid onsets from ValidOnsets.txt
%onsets = {};
open(ONSETS, "<ValidOnsets.txt") or die("Couldn't open ValidOnsets.txt\n");
while(defined($fileline = <ONSETS>)){
		chomp($fileline);
		$fileline =~ s/L/l/g;
		$fileline =~ s/G/J/g;
		$fileline =~ s/\~/n/g;
		$fileline =~ s/N/G/g;
		$fileline =~ s/c/C/g;
		$fileline =~ s/M/m/g;
		$fileline =~ s/\r//g;
		$onsets{$fileline} = 1;
}
close(ONSETS);

open(MRCCALL, "<mrc-call-syllabified.txt") or die("Couldn't opne mrc-call-syllabified.txt for reading");
%mrccall = {}; # hash holds already syllabified word = syllabification
while(defined($fileline = <MRCCALL>)){
	chomp($fileline);
	if ($fileline =~ /^([\w|\@|\'|\-|\^]+)\s*(.*)$/){
		$ortho = $1; $ipa = $2;
		# Clean up the MRC dictionary to match our Klattese format
		$ipa =~ s/eI/e/g;
		$mrccall{$ortho} = $ipa;
	}
}
close(MRCCALL);

# Go through dict-brent.txt,
# for nonsyllabified words: for each syllable, find its vowel, and its maximum onset, given acceptable onsets and beginning of word.
# print syllabified version to syllabified-dict.txt.
open(SYLLABIFIED, ">syllabified-dict.txt") or die("Couldn't open syllabified-dict.txt for writing\n");
open(DICT, "<dict-Brent-Klatt.txt") or die("Couldn't open dict-brent-klatt.txt for reading");
@englishwords=();  #the words in non-IPA, normal english. 

$count_fromMRC=0; $count_fromMOP=0;

open(NONE,">no_syllabification.txt") or die("Couldn't open no_syllabification.txt for writing\n");

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
			$count_fromMRC++;
		}else{ # otherwise start doing an automatic segmentation
			$count_fromMOP++;
			print NONE "$curreng\n";
		$word = $2; # IPA transcription
		$currsyllable = "";
		$entry = "";
		# work backwards with each word..
		@wordarray = split(//, $word);
		while(@wordarray > 0){
			$currchar = pop(@wordarray); # get current char
			$currsyllable = $currchar . $currsyllable; # add current char to current syllable 
			# if hit a vowel..
			if($currchar =~ /[iIeE\@acoUuYOWRx\^]/){
				# find and add consonants for valid onset
				$onset = "";
				while(@wordarray > 0 && exists($onsets{$wordarray[@wordarray-1] . $onset})){
					$currchar = pop(@wordarray);
					$onset = $currchar . $onset;
				}
				$currsyllable = $onset . $currsyllable;
				# add syllable to word entry
				$entry = "\/" . $currsyllable . $entry;
				$currsyllable = "";
			}
			elsif(@wordarray == 0){
				# add syllable to word entry
				$entry = "\/" . $currsyllable . $entry;
				$currsyllable = "";
			}
		}
		
		# print syllables as entry in collection of syllabified words
		#(also add space for abc-type entries)
		$entry =~ s/\/$//g; # remove last '/'
		$entry =~ s/^\///g; # remove first '/"
		$entry = " " . $entry;
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
close(NONE);
print "Number of syllabifications\nFrom MRC:\t$count_fromMRC\nFrom MOP:\t$count_fromMOP\n";
