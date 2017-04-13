#!/usr/bin/env Rscript
args<-commandArgs(trailingOnly=TRUE)
acq<-load(args[1])
utterance_data<-data.frame(utterances)
clean_corpus<-utterance_data[ , c('language', 'utterance', 'speaker_label')]
language_data<-clean_corpus[clean_corpus$language==(args[3]) & clean_corpus$speaker_label!="CHI", ]
language_data_noCHI<-language_data[ ,2]
write.table(language_data_noCHI, file=args[2], row.names=F,col.names=F,quote=F)