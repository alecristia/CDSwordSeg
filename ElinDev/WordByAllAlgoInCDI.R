library(wordbankr)
library(magrittr)
library(dplyr)
library(assertthat)
library(stringr)
library(ggplot2)
library(knitr)
opts_chunk$set(message = FALSE, warning = FALSE, cache = TRUE, fig.align = "center")
library(tidyr)
library(purrr)
library(readr)
install.packages("devtools")
devtools::install_github("langcog/langcog")
library(langcog)
library(ggrepel)
library(directlabels)
library(feather)

words_all_algos <- read.table("~/Documents/CDSwordSeg/results/res-brent-CDS/ComparaisonAvecAGu/WordsSegmentedAllAlgosIn10sub.txt", quote="\"", comment.char="")
types_all_subs_ini <- read.delim("~/Documents/CDSwordSeg/results/res-brent-CDS/ComparaisonAvecAGu/TypesAllSubs_FreqBrent")

## CDI
# Narrow down data to proportion of kids knowing or producing the word
#all_prop_data<-feather::read_feather("aoa-prediction-master/aoa_estimation/saved_data/all_prop_data.feather")
uni_prop_data<-feather::read_feather("aoa-prediction-master/aoa_unified/saved_data/uni_prop_data.feather")

prop_data <- uni_prop_data %>%
  select(language, measure, lexical_classes, words, prop, age) %>%
  distinct()

prop_data_english <- filter(prop_data, language == "English")

prop_understands= subset(prop_data_english, measure=="understands",select=c( lexical_classes, words, prop, age))
write.csv(prop_understands,file = "PropUnderstandCDI.csv", append = FALSE, sep="", row.names = FALSE, col.names = TRUE)

### fucntion that look if the words in a dataframe are the CDI dataframe (which has a column "words")
check_in_CDI=function(df_word, df_CDI)
{
  df_in_or_not=data_frame()
  for (i in 1:nrow(df_word))
  {
    df_in_or_not[i,1]=df_word[i,1]
    # this part takes larger words 'eg : the belonging to there'
    #z=grepl(df_word[i,1],df_CDI$words,ignore.case = TRUE) 
    #if (length(z[z==TRUE]) =="0"){df_in_or_not[i,2]="NO"}
    if (length(which(df_word[i,1]==df_CDI$words))>0){df_in_or_not[i,2]="YES"}
    else {df_in_or_not[i,2]="NO"}
  }
  return(df_in_or_not)
}

##### Which words segmented by all algo are in English CDI
words_algo_in_or_CDI=check_in_CDI(words_all_algos,prop_understands)
colnames(words_algo_in_or_CDI)=c("segmented_words","in_CDI")
words_of_algo_NOT_in_CDI=subset(words_algo_in_or_CDI,in_CDI=='NO', select=c(segmented_words, in_CDI))
words_of_algo_IN_CDI=subset(words_algo_in_or_CDI,in_CDI=='YES', select=c(segmented_words, in_CDI))

#### Which types that are in all subcorpus (from the beginning) are in English CDI
types_all_sub_strict_or_not_CDI=check_in_CDI(types_all_subs_ini,prop_understands)
colnames(types_all_sub_strict_or_not_CDI)=c("types_all_sub","in_CDI")
types_all_sub_strict_or_not_CDI$Freq=types_all_subs_ini$Freq
types_strict_CDI=subset(types_all_sub_strict_or_not_CDI,in_CDI=='YES', select=c(types_all_sub, Freq))
dim(types_strict_CDI)

setwd("~/Documents/CDSwordSeg/results/res-brent-CDS/ComparaisonAvecAGu")
write.table(x = types_strict_CDI, file = "TypesAllSubsInCDI", sep ="\t", col.names = TRUE, row.names = FALSE)


###subset the dataframe of words understood by the children for words segmented by algos
df_IN_CDI=data_frame(words=numeric())
for (i in 1:nrow(words_all_algos))
{
  if (length(which(words_all_algos[1,1]==prop_understands$words))!="0")
  {df_IN_CDI=subset(prop_understands, words==words_all_algos[1,1], select = c(language, lexical_classes,words,prop))}
  if (length(which(words_all_algos[i,1]==prop_understands$words))!="0")
  {df_IN_CDI=rbind(df_IN_CDI, subset(prop_understands, words==words_all_algos[i,1], select = c(lexical_classes,words,prop)))}
}

colnames(df_IN_CDI)[2]="uni_lemma"
colnames(prop_understands)[2]<-"uni_lemma"
#prop_understands=subset(prop_understands, select=c( lexical_classes, uni_lemma, prop))


library(xlsx)
setwd("~/Documents/CDSwordSeg/results/res-brent-CDS/AnalyseCDI")
write.xlsx(df_IN_CDI, "WordsInCDI.xlsx")
write.xlsx(df_IN_CDI, "WordsInCDI.xlsx")

setwd("~/Documents/")

#CHILDES
childes_data_en<-read_csv("aoa-prediction-master/aoa_prediction/predictors/childes/data/childes_english.csv")
uni_childes <- childes_data_en %>%
  filter(!is.na(word)) %>%
  filter(word_count != 0) %>%
  mutate(word_count = word_count + 1,
         frequency = log(word_count / sum(word_count)),
         final_count = final_count + 1,
         final_freq = log((final_count - solo_count) /
                            sum(final_count - solo_count)),
         solo_count = solo_count + 1,
         solo_freq = log(solo_count / sum(solo_count)))
uni_childes$final_frequency <- lm(final_freq ~ frequency,data = uni_childes)$residuals
uni_childes$solo_frequency <- lm(solo_freq ~ frequency, data = uni_childes)$residuals
uni_childes$language<-matrix("English",nrow(uni_childes),1)
colnames(uni_childes)[1]<-"uni_lemma"

#### Valence
valence <- read_csv("aoa-prediction-master/aoa_prediction/predictors/valence/valence.csv") %>%
  select(Word, V.Mean.Sum, A.Mean.Sum, D.Mean.Sum) %>%
  rename(word = Word, valence = V.Mean.Sum, arousal = A.Mean.Sum,
         dominance = D.Mean.Sum)

replacements_valence <- read_csv("aoa-prediction-master/aoa_prediction/predictors/valence/valence_replace.csv")
uni_valences <- uni_lemmas %>%
  left_join(replacements_valence) %>%
  rowwise() %>%
  mutate(word = if (!is.na(replacement) & replacement != "") replacement else uni_lemma) %>%
  select(-replacement) %>%
  left_join(valence) %>%
  select(-word)

#concretness
concreteness <- read_csv("aoa-prediction-master/aoa_prediction/predictors/concreteness/concreteness.csv")

replacements_concreteness <- read_csv("aoa-prediction-master/aoa_prediction/predictors/concreteness/concreteness_replace.csv")
uni_concreteness <- uni_lemmas %>%
  left_join(replacements_concreteness) %>%
  rowwise() %>%
  mutate(Word = if (!is.na(replacement) & replacement != "") replacement else uni_lemma) %>%
  select(-replacement) %>%
  left_join(concreteness) %>%
  rename(concreteness = Conc.M) %>%
  select(uni_lemma, concreteness)

#Get estimates of iconicity and babiness.
babiness <- read_csv("aoa-prediction-master/aoa_prediction/predictors/babiness_iconicity/english_iconicity.csv") %>%
  group_by(word) %>%
  summarise(iconicity = mean(rating),
            babiness = mean(babyAVG))

replacements_babiness <- read_csv("aoa-prediction-master/aoa_prediction/predictors/babiness_iconicity/babiness_iconicity_replace.csv")
uni_babiness <- uni_lemmas %>%
  left_join(replacements_babiness) %>%
  rowwise() %>%
  mutate(word = if (!is.na(replacement) & replacement != "") replacement else uni_lemma) %>%
  select(-replacement) %>%
  left_join(babiness) %>%
  select(-word)

# get english phonemes and syllabe
phonemes <- read_csv("aoa-prediction-master/aoa_prediction/predictors/phonemes/english_phonemes.csv") %>%
  mutate(num_syllables = unlist(map(strsplit(syllables, " "), length)),
         num_phonemes = nchar(gsub("[', ]", "", syllables))) %>%
  select(-phones, -syllables)

#Put together data and predictors.
uni_joined <- df_IN_CDI %>%
  left_join(uni_childes) %>%
  left_join(uni_valences) %>%
  left_join(uni_babiness) %>%
  left_join(uni_concreteness) %>%
  left_join(phonemes) %>%
  distinct()


#Function to get number of characters from item definitions.
#```{r}
num_characters <- function(words) {
  words %>%
    strsplit(", ") %>%
    map(function(word_set) {
      word_set %>%
        unlist() %>%
        strsplit(" [(].*[)]") %>%
        unlist() %>%
        strsplit("/") %>%
        unlist() %>%
        gsub("[*' ]", "", .) %>%
        nchar() %>%
        mean()
    }) %>%
    unlist()
}

clean_english=lang_data_fun("English", uni_joined, predictors)
lang_model_fun(english, predictors)

formula=prop~.
lm(formula,english, y=TRUE)