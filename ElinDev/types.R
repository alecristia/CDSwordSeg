# number of types in subcorpus
types=c(450,465,501,535,527,470,546,467,504,482)
SUBS=paste("subs",0:9)
hist(types)
mean(types)
algos=c("ngrams","dibs","tps","puddle")
word_per_algos=c(59,16,5,3)
non_word_per_algos=c(21,3,4,0)
word_per_type

DibsFscoreAllSub <- read.delim("~/Documents/CDSwordSeg/recipes/bernstein/data_06_10/DibsFscoreAllSub.txt")

PuddleFscoreAllSub <- read.delim("~/Documents/CDSwordSeg/recipes/bernstein/data_06_10/PuddleFscoreAllSub.txt", comment.char="#")

TPFscoreAllSub <- read.delim("~/Documents/CDSwordSeg/recipes/bernstein/data_06_10/TPFscoreAllSub.txt")

names(TPFscoreAllSub)
MeanTP_fscore=apply(TPFscoreAllSub ,2, mean)
MeanDibs_fscore=apply(DibsFscoreAllSub ,2, mean)
MeanPuddle_fscore=apply(PuddleFscoreAllSub ,2, mean)
