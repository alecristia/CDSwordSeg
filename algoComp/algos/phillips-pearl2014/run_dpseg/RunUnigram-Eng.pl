#! usr/bin/perl

# Run each unigram DPSEG model over 5 train/test sets for publish-able results

$a = 0;
$b1 = 1;
$ngram = 1;

#Unigram Models
#Ideal
for($i=1;$i<=5;$i++){
print "Ideal\t$i\n";
$output = 'U_I:' . $a . '.' . $b1 . '.ver' . $i . '.txt';
$stats = 'U_I:' . $a . '.' . $b1 . '.ver' . $i .'stats.txt';
$train = 'train-uni-9mos-clean' . $i . '.txt';
$test = 'test-uni-9mos-clean' . $i . '.txt';
system("./../dpseg -C ../configs/config-uni-ideal.txt -o ../output_clean/english/$output --data-file ../corpora_clean/$train --eval-file ../corpora_clean/$test --ngram $ngram --a1 $a --b1 $b1 > ../output_clean/english/$stats");
}

#Viterbi
for($i=1;$i<=5;$i++){
print "Viterbi\t$i\n";
$output = 'U_V:' . $a . '.' . $b1 . '.ver' . $i . '.txt';
$stats = 'U_V:' . $a . '.' . $b1 . '.ver' . $i .'stats.txt';
$train = 'train-uni-9mos-clean' . $i . '.txt';
$test = 'test-uni-9mos-clean' . $i . '.txt';
system("./../dpseg -C ../configs/config-viterbi.txt -o ../output_clean/english/$output --data-file ../corpora_clean/$train --eval-file ../corpora_clean/$test --ngram $ngram --a1 $a --b1 $b1 > ../output_clean/english/$stats");
}
#DPS
for($i=1;$i<=5;$i++){
print "DPS\t$i\n";
$output = 'U_DPS:' . $a . '.' . $b1 . '.ver' . $i . '.txt';
$stats = 'U_DPS:' . $a . '.' . $b1 . '.ver' . $i .'stats.txt';
$train = 'train-uni-9mos-clean' . $i . '.txt';
$test = 'test-uni-9mos-clean' . $i . '.txt';
system("./../dpseg -C ../configs/config-dps.txt -o ../output_clean/english/$output --data-file ../corpora_clean/$train --eval-file ../corpora_clean/$test --ngram $ngram --a1 $a --b1 $b1 > ../output_clean/english/$stats");
}
#DMCMC
for($i=1;$i<=5;$i++){
print "DMCMC\t$i\n";
$output = 'U_DMCMC:' . $a . '.' . $b1 . '.ver' . $i . '.txt';
$stats = 'U_DMCMC:' . $a . '.' . $b1 . '.ver' . $i .'stats.txt';
$train = 'train-uni-9mos-clean' . $i . '.txt';
$test = 'test-uni-9mos-clean' . $i . '.txt';
system("./../dpseg -C ../configs/config-uni-dmcmc.txt -o ../output_clean/english/$output --data-file ../corpora_clean/$train --eval-file ../corpora_clean/$test --ngram $ngram --a1 $a --b1 $b1 > ../output_clean/english/$stats");
}
