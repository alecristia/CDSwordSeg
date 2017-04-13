acq<-load("/Users/bootphonproject/Desktop/segmentation/acqdiv_corpus_2016-09-22_ctn_jap.rda")
utterance_data<-data.frame(utterances)
clean_corpus<-utterance_data[ , c('language', 'utterance', 'speaker_label')]
language_data<-clean_corpus[clean_corpus$language=="Japanese" & clean_corpus$speaker_label!="CHI", ]
language_data_noCHI<-language_data[ ,2]
write.table(language_data_noCHI, file="/Users/bootphonproject/Desktop/segmentation/results/japanese/clean_corpus.txt", row.names=F,col.names=F,quote=F)