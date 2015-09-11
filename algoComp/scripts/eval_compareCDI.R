USAGE="Rscript eval_compareCDI.R AGE OUTFILE FILE1 \n\
   Compares level of acquisition in the CDI
   Words and Gestures (from WordBank)
   at Age AGE (number 8-18) for one algo
   and stores it in OUTFILE.
   
   The format of the file1 should be:
   frequency word1
   frequency word2
   ...
   
  "
abort<-function(...){
  cat(...,"\n")
  quit('no')
}

xage=18
outfile="compareCDI.txt"
file1="Lyon_algoComp/res-dibs/lyon0_test_count.txt"


if (!interactive()){
  args <- commandArgs(TRUE)
  if(length(args)!=4)abort("Usage",USAGE)
  xage <- args[1]
  outfile <- args[2]
  file1 <- args[3]
   }


cdi=read.table("wordbankWGcomp1.txt",header=T)
colnames(cdi)<-8:18
cdi["pron",]<-scan("Eng_wbWGcomp_phonocols.txt",what="char")

t(cdi[cdi[,]== xage,5:dim(cdi)[2]])->selcdi

colnames(selcdi)<-paste("propComp",xage,"mo",sep="")

freq1=read.table(file1)

colnames(freq1)=c("freq","type")

selcdi$freq1=NA
for(thisr in rownames(selcdi)){
	selcdi[thisr,"freq1"]<-freq1$freq[freq1$type==thisr]
}

write.table(outfile)

cat("Look for graphics results in file",outfile,"\n")

quit("no")
#PROBLEMS:
#the outputs of the other algos contain "_"

#MISSING
#The actual matching routine (the one above won't work because it requires precise matching- perhaps we want to do a grep, which doesn't punish undersegmentations?)