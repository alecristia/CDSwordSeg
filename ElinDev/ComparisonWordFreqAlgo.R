#comparison of word frequency in segmentation for different algorithms and different sub-corpus

#Comparison for one sub-corpus

name_subcorpus="sub0"
setwd("~/Documents/CDSwordSeg/algoComp/res-sub-bern-ADS/"+name_subcorpus)

#DIBS
setwd("~/Documents/CDSwordSeg/algoComp/res-sub-bern-ADS/sub0/dibs_0")
freq.top.dibs <- read.table("~/Documents/CDSwordSeg/algoComp/res-sub-bern-ADS/sub0/dibs_0/freq-top.txt", quote="\"", comment.char="")
colnames(freq.top.dibs)=c("freq_dibs","type_dibs")

#NGRAMS
setwd("~/Documents/CDSwordSeg/algoComp/res-sub-bern-ADS/sub0/ngrams")
freq.top <- read.table("~/Documents/CDSwordSeg/algoComp/res-sub-bern-ADS/sub0/ngrams/freq-top.txt", quote="\"", comment.char="")
freq.top.ngrams=freq.top[,-2]
colnames(freq.top.ngrams)=c("freq_ngrams","type_ngrams")

#TPS
setwd("~/Documents/CDSwordSeg/algoComp/res-sub-bern-ADS/sub0/TPs")
freq.top.tps <- read.table("~/Documents/CDSwordSeg/algoComp/res-sub-bern-ADS/sub0/TPs/freq-top.txt", quote="\"", comment.char="")
colnames(freq.top.tps)=c("freq_tps","type_tps")

#PUDDLE
setwd("~/Documents/CDSwordSeg/algoComp/res-sub-bern-ADS/sub0/puddle")
freq.top.puddle <- read.table("~/Documents/CDSwordSeg/algoComp/res-sub-bern-ADS/sub0/puddle/freq-top.txt", quote="\"", comment.char="")
colnames(freq.top.puddle)=c("freq_puddle","type_puddle")

setwd("~/Documents/CDSwordSeg/algoComp/res-sub-bern-ADS/sub0/")
freq.tps=freq.top.tps[1:100,]
freq.ngrams=freq.top.ngrams[1:100,]
freq.dibs=freq.top.dibs[1:100,]
freq.puddle=freq.top.puddle[1:100,]

algo.freq=cbind(freq.dibs,freq.ngrams,freq.tps,freq.puddle)
algo.type=algo.freq[,c(2,4,6,8)]

list.type=as.list(algo.type)
#dibs/ ngrams
dibs_ngrams=calculate.overlap(x=list(list.type[[1]],list.type[[2]]))
inter_dibs_ngrams=dibs_ngrams$a3
#dibs/tps
dibs_tps=calculate.overlap(x=list(list.type[[1]],list.type[[3]]))
inter_dibs_tps=dibs_tps$a3
#dibs/puddle
dibs_puddle=calculate.overlap(x=list(list.type[[1]],list.type[[4]]))
inter_dibs_puddle=dibs_puddle$a3

#intersection dibs/ngrams/tps
dibs_ngrams_tps=calculate.overlap(x=list(inter_dibs_ngrams,inter_dibs_tps))
inter_dibs_ngrams_tps=dibs_ngrams_tps$a3
inter_dibs_ngrams_tps

#intersection  dibs/ngrams/puddle
dibs_ngrams_puddle=calculate.overlap(x=list(inter_dibs_ngrams,inter_dibs_puddle))
inter_dibs_ngrams_puddle=dibs_ngrams_puddle$a3
inter_dibs_ngrams_puddle

#inter all algos
all_algo=calculate.overlap(x=list(inter_dibs_ngrams_tps,inter_dibs_ngrams_puddle))
inter_algo_0=all_algo$a3
inter_algo