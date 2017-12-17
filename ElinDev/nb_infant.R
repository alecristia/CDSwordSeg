library(gam)
library(readr)
library(plyr)
library(dplyr)
library(tidyr)
library(purrr)
library(ggplot2)
library(knitr)

library(lme4)


english_all_data_understand <- read_delim("~/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/Analysis_algos_CDI/CDI_data/english_all_data_understand.csv", 
                                          "\t", escape_double = FALSE, trim_ws = TRUE)

eng_understand=english_all_data_understand %>%
  rename(Type=uni_lemma)

data_by_nb_infant<-function(data, nb_infant, AGE)
{ new_data<-data%>%
    filter(age==AGE)
  u=as.vector(sample(new_data$data_id, nb_infant))
  final_data<-new_data%>%
    filter(data_id==u[1])
  for (i in (2:length(u)))
  {
    temp<-new_data%>%
      filter(data_id==u[i])
    final_data=rbind(final_data, temp)
  }
  return(final_data)
}

eng_und_200=data_by_nb_infant(eng_understand,200, 13)

get_prop<-function(data)
{
  dat_prop<-data%>%
    group_by(lexical_class, Type, age, data_id)%>%
    summarise(uni_value = any(value)) %>%
    group_by(lexical_class, Type,age) %>%
    summarise(num_true = sum(uni_value, na.rm = TRUE),
              num_false = n() - num_true,
              prop = mean(uni_value, na.rm = TRUE))
  return(dat_prop) 
}

prop_100=get_prop(eng_und_100)

# get two groups of different frequency by TO

HF_TP_150_400 <- read_delim("~/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/Analysis_algos_CDI/power_analysis/TPs/gold_150_400/HF_TP_150-400.txt", 
                            "\t", escape_double = FALSE, trim_ws = TRUE)
hf_tp=HF_TP_150_400
hf_tp$group=rep('HF', nrow(HF_TP_150_400))

LF_TP_6_70 <- read_delim("~/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/Analysis_algos_CDI/power_analysis/TPs/gold_150_400/LF_TP_6-70.txt", 
                         "\t", escape_double = FALSE, trim_ws = TRUE)

lf_tp=LF_TP_6_70
lf_tp$group=rep('LF', nrow(LF_TP_6_70))

tp_groups=rbind(lf_tp, hf_tp)

freq_tps <- read_delim("~/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/full_corpus/TPs/syllable/freq-words.txt", 
                       "\t", escape_double = FALSE, trim_ws = TRUE)%>%
  mutate(
    log_freq=scale(log(Freq), center=TRUE, scale=TRUE)
  )


# merge all dataframes 
dat_gp=merge(tp_groups, prop_100, by='Type')
HF=subset(dat_gp, group=='HF')
LF=subset(dat_gp, group=='LF')
t.test(HF$prop, LF$prop)

boxplot(prop~ group,dat_gp, xlab= "Groups of words with high and low occurences in TP lexicon", ylab="Mean proportion of 200 13-months-old infants understanding words of the two groups")

#prop fitted by TP
dat_gp$log_freq_tps=log(dat_gp$Freqtps)

#model fitted with all words type in CDI for a certain age

sub_dat<- eng_prop_understand%>%
  filter(age==13)%>%
  filter(!Type %in% tp_groups$Type)

train=merge(sub_dat, freq_tps, by='Type')
test=dat_gp
  
m0_tps_13<-lm(prop~log_freq, train)

new=data.frame(log_freq=test$log_freq)
fit_prop<-predict(m0_tps_13, test,  se.fit = TRUE, interval = "prediction", level="confidence", type="terms")


summary(lm(prop~log_freq, test))
