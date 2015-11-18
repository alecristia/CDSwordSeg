#! usr/bin/perl

# Run each unigram DPSEG model over 5 train/test sets for publish-able results

$a = 0;
$b1 = 1;
$b2 = 90;
$ngram = 2;

#Bigram Models

#Ideal
#for($i=1;$i<=5;$i++){
#print "B_I:\t$i\n";
#$output = 'B_I:' . $a . '.' . $b1 . '.' . $b2 . '.' . $i . '.txt';
#$stats = 'B_I:' . $a . '.' . $b1 . '.' . $b2 . '.' . $i .'stats.txt';
#$train = 'train-uni-9mos-clean' . $i . '.txt';
#$test = 'test-uni-9mos-clean' . $i . '.txt';
#system("./../dpseg -C ../configs/config-bi-ideal.txt -o ../output_clean/english/$output --data-file ../corpora_clean/$train --eval-file ../corpora_clean/$test --ngram $ngram --a1 $a --b1 $b1 --b2 $b2 > ../output_clean/english/$stats");
#}
#Viterbi
#for($i=1;$i<=5;$i++){
#print "B_V:\t$i\n";
#$output = 'B_V:' . $a . '.' . $b1 . '.' . $b2 . '.' . $i . '.txt';
#$stats = 'B_V:' . $a . '.' . $b1 . '.' . $b2 . '.' . $i .'stats.txt';
#$train = 'train-uni-9mos-clean' . $i . '.txt';
#$test = 'test-uni-9mos-clean' . $i . '.txt';
#system("./../dpseg -C ../configs/config-viterbi.txt -o ../output_clean/english/$output --data-file ../corpora_clean/$train --eval-file ../corpora_clean/$test --ngram $ngram --a1 $a --b1 $b1 --b2 $b2 > ../output_clean/english/$stats");
#}
#DPS
for($i=1;$i<=5;$i++){
print "B_T:\t$i\n";
$output = 'B_DPS:' . $a . '.' . $b1 . '.' . $b2 . '.' . $i . '.txt';
$stats = 'B_DPS:' . $a . '.' . $b1 . '.' . $b2 . '.' . $i .'stats.txt';
$train = 'train-uni-9mos-clean' . $i . '.txt';
$test = 'test-uni-9mos-clean' . $i . '.txt';
system("./../dpseg_files/dpseg -C ../configs/config-dps.txt -o ../output_clean/english/$output --data-file ../corpora_clean/$train --eval-file ../corpora_clean/$test --ngram $ngram --a1 $a --b1 $b1 --b2 $b2 > ../output_clean/english/$stats");
}

#DMCMC
#for($i=1;$i<=5;$i++){
#print "B_D:\t$i\n";
#$output = 'B_DMCMC:' . $a . '.' . $b1 . '.' . $b2 . '.ver' . $i . '.txt';
#$stats = 'B_DMCMC:' . $a . '.' . $b1 . '.' . $b2 . '.ver' . $i .'stats.txt';
#$train = 'train-uni-9mos-clean' . $i . '.txt';
#$test = 'test-uni-9mos-clean' . $i . '.txt';
#system("./../dpseg -C ../configs/config-bi-dmcmc.txt -o ../output_clean/english/$output --data-file ../corpora_clean/$train --eval-file ../corpora_clean/$test --ngram $ngram --a1 $a --b1 $b1 --b2 $b2 > ../output_clean/english/$stats");
#}
