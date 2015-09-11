USAGE="Rscript analyse.R FILE1 FILE2 [PDFFILE]\n\
   Compares two lexicons.
   The format of the files should be:
   frequency length word
   ......
  "
abort<-function(...){
  cat(...,"\n")
  quit('no')
}

file1="1of2lyon0_test_1-4ngrams_top10k.res"
file2="2of2lyon0_test_1-4ngrams_top10k.res"
outpdf="analyse.pdf"

file1="lyon0_test_1-4ngrams_top10k.res"
file2="lyon_mbr-word.res"

if (!interactive()){
  args <- commandArgs(TRUE)
  if(length(args)<2)abort("Usage",USAGE)
  file1 <- args[1]
  file2 <- args[2]
  if(length(args)>=3)outpdf <- args[3]
  pdf(outpdf,width=29.7/4,height=21/4)
  
  }

a1=read.table(file1)
a2=read.table(file2)
names(a1)=names(a2)=c("freq","len","type")
cat("There are",nrow(a1),"types in file",file1,"\n")
cat("There are",nrow(a2),"types in file",file2,"\n")

w1=levels(a1$type)
w2=levels(a2$type)
if (length(w1)!=nrow(a1)){cat('*** ERROR: nb of rows (',nrow(a1),') != nb of types (',length(w1),')\n'); quit("no")}
if (length(w2)!=nrow(a2)){cat('*** ERROR: nb of rows (',nrow(a2),') != nb of types (',length(w2),')\n'); quit("no")}
a1$type=paste(a1$type)
a2$type=paste(a2$type)
a1$match=a1$type %in% w2
a2$match=a2$type %in% w1

a1$rank=(nrow(a1)-rank(a1$freq+rnorm(nrow(a1),0,0.001)))+1
a2$rank=(nrow(a2)-rank(a2$freq+rnorm(nrow(a2),0,0.001)))+1
a1$bin=trunc((a1$rank-1)/10)
a2$bin=trunc((a2$rank-1)/10)
dimnames(a1)[[1]]=a1$type
dimnames(a2)[[1]]=a2$type

plot(aggregate(a1$match,by=list(a1$bin),mean),ylab="prob of match",xlab="bin of 10",sub=file1)
plot(aggregate(a2$match,by=list(a2$bin),mean),ylab="prob of match",xlab="bin of 10",sub=file2)
misa1=a1[!a1$match,]
misa2=a2[!a2$match,]
cat('There are',nrow(misa1),"unique types in file",file1,"(not also in",file2,")\n")
cat("  Top 20 words:\n")
head(misa1,20)
cat('There are',nrow(misa2),"unique types in file",file2,"(not also in",file1,")\n")
cat("  Top 20 words:\n")
head(misa2,20)
plot(misa1$rank,main="unique types",ylab="Rank",sub=file1)
plot(misa2$rank,main="unique types",ylab="Rank",sub=file2)

common=a1[a1$match,]
joined=cbind(a1[common$type,],a2[common$type,])
names(joined)=paste(names(a1),rep(c(1,2),each=length(names(a1))),sep="_")
cat('There are',nrow(joined),"common types to both file",file1,"and file",file2,"\n")
plot(log(joined$freq_1)/log(10),log(joined$freq_2)/log(10),xlab="log(freq1)",ylab="log(freq2)",main=paste("common words (N=",nrow(joined),")",sep=""),pch=".",cex=1.5)
rangg=range(log(c(joined$freq_1,joined$freq_2))/log(10))
lines(rangg,rangg,col="red")

#plot((joined$freq_1),(joined$freq_2),xlab="log(freq1)",ylab="log(freq2)",main=paste("common words (N=",nrow(joined),")",sep=""))


plot(aggregate(a1$match,by=list(floor(a1$len)),mean),ylab="prob of match",xlab="length (syll)",sub=file1)
plot(aggregate(a2$match,by=list(floor(a2$len)),mean),ylab="prob of match",xlab="length (syll)",sub=file2)

xx=cbind(misa1,misa1)
names(xx)=names(joined)
xx$freq_2=10^(-3)
xx$match_2=NA
xx$rank_2=nrow(a2)+1
xx$bin_2=max(a2$bin)+1

yy=cbind(misa2,misa2)
names(yy)=names(joined)
yy$freq_1=10^(-3)
yy$match_1=NA
yy$rank_1=nrow(a1)+1
yy$bin_1=max(a1$bin)+1

combined=rbind(joined,xx,yy)
combined$deltalog=(log(combined$freq_1)-log(combined$freq_2))/log(10)
#simplifying
#combined$type=combined$type_1
combined$type_1=combined$type_2=NULL
combined$len=(combined$len_1+combined$len_2)/2
combined$len_1=combined$len_2=NULL
combined$bin_1=combined$bin_2=NULL

plot(combined$rank_1,combined$deltalog)
plot(combined$rank_2,combined$deltalog)

plot(combined$rank_1[combined$rank_1<=200],combined$deltalog[combined$rank_1<=200])
plot(combined$rank_2[combined$rank_2<=200],combined$deltalog[combined$rank_2<=200])

cat("Types in algo 1 exceeding a frequency difference ratio of 500 within the 500 most frequent words\n")
combined[(combined$rank_1<=500)&(combined$deltalog>log(500)/log(10)),]

cat("Types in algo 2 exceeding a frequency difference ratio of 500 within the 500 most frequent words\n")
combined[(combined$rank_2<=500)&(combined$deltalog<log(1/500)/log(10)),]

#-- making a zipfian plot
plot(log(combined$rank_1),log(combined$freq_1),col='orange',xlab="log rank",ylab="log freq",main="Frequency statistics")
points(log(combined$rank_2),log(combined$freq_2),col='blue')
legend("bottomleft",bty="n",c(file1,file2),text.col=c("orange","blue"))

cat("Look for graphics results in file",outpdf,"\n")

quit("no")
