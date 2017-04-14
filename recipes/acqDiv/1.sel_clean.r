acq<-load("../../../acqdiv_corpus_2016-09-22_ctn_jap.rda")
utterance_data<-data.frame(utterances)
clean_corpus<-utterance_data[ , c('language', 'utterance', 'speaker_label')]

language_data<-clean_corpus[clean_corpus$speaker_label!="CHI",]

write.table(language_data[language_data$language=="Japanese",2], file="../../../japanese_surface.txt", row.names=F,col.names=F,quote=F)
write.table(language_data[language_data$language=="Chintang",2], file="../../../chintang_surface.txt", row.names=F,col.names=F,quote=F)

