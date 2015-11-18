#! usr/bin/perl

@order = qw(eng)

%dir;
$dir{eng} = '../output_clean/english/';

%language;
$language{eng} = "English";

%name;
$name{eng} = '9mos';

%params;
$params{eng} = "1\t1\t90";

%res_dir;
$res_dir{eng} = '../results/English/';

$corp_dir = '../corpora_clean/';

%cross_dir;
$cross_dir{eng} = '../corpora_clean/';

%uni_file;
$uni_file{eng} = $cross_dir{eng} . 'brent9mos-unicode.txt';

%syl_file;
$syl_file{eng} = $cross_dir{eng} . 'brent9mos-syl.txt';

%klatt_file;
$klatt_file{eng} = $cross_dir{eng} . 'brent9mos-klatt.txt';

%vowels;
$vowels{eng} = 'iIeE@acoUuYOWRx^';

%morph;
$morph{eng} = "morphology.txt";

%funcword;
$funcword{eng} = "funcwords.txt";

%worddict;
$worddict{eng} = "../corpora_clean/unicode-word-dict.txt";
