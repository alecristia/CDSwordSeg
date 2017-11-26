library(gam)
library(readr)
library(dplyr)
library(tidyr)
library(purrr)
library(ggplot2)
library(knitr)
library(reshape2) # for box plot

setwd("~/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/Analysis_algos_CDI/")

function_content_words <- read_delim("~/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/Analysis_algos_CDI/function_content_words.csv", 
                                         "\t", escape_double = FALSE, trim_ws = TRUE)

concreteness_2_classes <- read_delim("~/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/Analysis_algos_CDI/concreteness_2_classes.csv", 
                                          "\t", escape_double = FALSE, trim_ws = TRUE)

Mono_poly_CDI <- read_delim("~/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/Analysis_algos_CDI/Mono_poly_CDI.csv", 
                               "\t", escape_double = FALSE, trim_ws = TRUE)

dat=merge(Mono_poly_CDI,function_content_words, by='Type' )%>%
  select(Type, num_syllables, lexical_classes)

### TPS
freq_tps <- read_delim("~/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/full_corpus/TPs/syllable/freq-words.txt", 
                       "\t", escape_double = FALSE, trim_ws = TRUE)%>%
  mutate(#log_freq=scale(log(Freq/sum(Freq)), center=TRUE, scale=TRUE)
          word_count=Freq,
          log_freq=log(word_count/sum(word_count))
        )%>%
  select(Type, word_count, log_freq)

dat_tps=merge(dat, freq_tps)
boxplot(log_freq~ lexical_classes, dat_tps)
boxplot(log_freq~ num_syllables, dat_tps)
boxplot(log_freq~ num_syllables*lexical_classes, dat_tps, col=c('green', 'red'), 
        ylab="Log frequency of words segmented by TPs ", xlab= "Lexical classes",main="")

boxplots.double = boxplot(log_freq~ num_syllables*lexical_classes, dat_tps,  
                          ylab="Log frequency of CDI words segmented by TPs ",
                          xaxt='n', col=c('palevioletred1','royalblue2'),
                          ylim=c(-12, -1))
axis(side=1, at=c(1.5, 3.5), labels=c('Content words', 'Function words'), line=0.5, lwd=0)
text(c(1, 2, 3, 4), c(-2, -2, -2, -2), c('Monosyllabic ', 'Polysyllabic ',
                                             'Monosyllabic', 'Polysyllabic'))

### gold

freq_brent <- read_delim("~/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/Analysis_algos_CDI/freq_brent.csv", "\t", escape_double = FALSE, trim_ws = TRUE, col_names = TRUE)%>%
  rename(word_count_gold=Freqgold)%>%
  mutate(log_freq_gold=log(word_count_gold/sum(word_count_gold))
         #, frequency=scale(log_freq,center=TRUE, scale=TRUE) # centered at 0, and divided by standard deviation
  )
dat_gold=merge(dat, freq_brent, by='Type')
dat_gold_tps=merge(freq_brent,dat_tps, by='Type')

boxplots.double = boxplot(log_freq_gold~ num_syllables*lexical_classes, dat_gold_tps,  
                          ylab="Log frequency of TPs-CDI words in CDS ",
                          xaxt='n', col=c('palevioletred1','royalblue2'),
                          ylim=c(-12, -1))
axis(side=1, at=c(1.5, 3.5), labels=c('Content words', 'Function words'), line=0.5, lwd=0)
text(c(1, 2, 3, 4), c(-2, -2, -2, -2), c('Monosyllabic ', 'Polysyllabic ',
                                             'Monosyllabic', 'Polysyllabic'))

### gold
