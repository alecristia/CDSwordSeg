# this script looks at the effect  of some linguistic parameters on the proportion of infants reported to understand a word
# for different ages

#suppose you have prop_data 
# see get_prop.R

library(gam)
library(readr)
library(plyr)

library(dplyr)
library(tidyr)
library(purrr)
library(ggplot2)
library(langcog)
library(wordbankr)
library(boot)
library(lazyeval)
library(ggrepel)
library(knitr)

library(lme4)
require(GGally)
require(reshape2)
require(compiler)
require(parallel)
require(boot)

library(corrgram)

library(robustbase)

setwd("~/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/Analysis_algos_CDI/")

#PropUnderstandCDI <- read_delim("~/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/Analysis_algos_CDI/CDI_data/PropUnderstandCDI.csv", "\t", escape_double = FALSE, trim_ws = TRUE)
#CDI_NbInfantByAge <- read_delim("~/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/Analysis_algos_CDI/CDI_data/CDI_NbInfantByAge.csv", 
#                                +     ";", escape_double = FALSE, trim_ws = TRUE)`
#NbInfantByAge=sapply(CDI_NbInfantByAge, rep.int, times=length(PropUnderstandCDI$prop)/length(CDI_NbInfantByAge$age))
#success=PropUnderstandCDI$prop*NbInfantByAge[,2]
#failure=NbInfantByAge[,2]-success
#PropUnderstandCDI$success=success
#PropUnderstandCDI$failure=failure

english_all_data_understand <- read_delim("~/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/Analysis_algos_CDI/CDI_data/english_all_data_understand.csv", 
                              "\t", escape_double = FALSE, trim_ws = TRUE)

eng_understand=english_all_data_understand %>%
  rename(Type=uni_lemma)

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

eng_prop_understand<- eng_understand%>%
  group_by(lexical_class, Type, age, data_id)%>%
  summarise(uni_value = any(value)) %>%
  group_by(lexical_class, Type,age) %>%
  summarise(num_true = sum(uni_value, na.rm = TRUE),
            num_false = n() - num_true,
            prop = mean(uni_value, na.rm = TRUE))

eng_prop_understand_13<-eng_prop_understand%>%
  filter(age==13)

# get frequency of items / type in brent corpus

freq_brent <- read_delim("~/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/Analysis_algos_CDI/freq_brent.csv", "\t", escape_double = FALSE, trim_ws = TRUE, col_names = TRUE)%>%
  mutate(word_count=Freqgold,
          log_freq=log(word_count/sum(word_count)),
         log_freq_std=scale(log_freq,center=TRUE, scale=TRUE)) %>% # centered at 0, and divided by standard deviation
  select(Type, word_count, log_freq, log_freq_std)

hist(freq_brent$word_count)
hist(freq_brent$log_freq)
hist(freq_brent$log_freq_std)

# frequency of CDI word types in Brent corpus
brent_cdi=merge(freq_brent, eng_prop_understand_13, on='Type', how='inner')%>%
  select( Type, lexical_class, log_freq, log_freq_std, word_count, age, prop)

barplot(height=table(brent_cdi$lexical_class), ylab='Number of words in each lexical class', xlab='Lexical class', main="Histogram of words in the CDI comprehensiond database")
boxplot(log_freq ~ lexical_class,brent_cdi, main="Log Frequency of CDI words in the Brent-Sisking corpus", 
        xlab="Lexical class", ylab="Log Frequency")

### TPS freq  
freq_tps <- read_delim("~/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/full_corpus/TPs/syllable/freq-words.txt", 
                       "\t", escape_double = FALSE, trim_ws = TRUE)%>%
  mutate(
    word_count_tps=Freq,
    log_freq_tps=log(word_count_tps/sum(word_count_tps)),
    log_freq_tps_std=scale(log(Freq), center=TRUE, scale=TRUE)
  )%>%
  select(Type, word_count_tps,log_freq_tps, log_freq_tps_std )

# frequency of word types in CDI-TPs lexicon
brent_cdi_tps=merge(freq_tps, brent_cdi)
barplot(height=table(brent_cdi_tps$lexical_class))
boxplot(log_freq_tps ~ lexical_class,brent_cdi_tps, main="Log Frequency of CDI words segmented by TPs in the Brent-Sisking corpus", 
        xlab="Lexical class", ylab="Log Frequency")

# get concreteness of items
concreteness <- read_csv("~/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/Analysis_algos_CDI/concreteness/concreteness.csv")%>%
  mutate(
    Type=Word,
    #concreteness=scale(Conc.M, center=TRUE, scale=TRUE)
    concreteness=round(Conc.M),
    concreteness_std=scale(Conc.M, center=TRUE, scale=TRUE)
  )%>%
  select(Type, concreteness, Conc.M, concreteness_std) 
hist(concreteness$concreteness)
hist(concreteness$concreteness_std)

write.table(concreteness,file="concreteness.csv", sep="\t", append=FALSE)


dat_conc=merge(concreteness, brent_cdi_tps, on='Type' ,how='inner')%>%
  select(Type, Conc.M, concreteness, concreteness_std, lexical_class, log_freq, log_freq_tps )
hist(dat_conc$Conc.M, xlab='Continuous measure of words concreteness', ylab= 'Frequency of words in the TPs-CDI lexicon', main='Histogram of the concreteness factor')
hist(dat_conc$concreteness, xlab='Categorical measure of words concreteness', ylab= 'Frequency of words in the TPs-CDI lexicon', main='Histogram of the concreteness factor')
#hist(dat_conc$concreteness_std, xlab='Standardized categorical measure of words concreteness', ylab= 'Frequency of words in the TPs-CDI lexicon', main='Histogram of the concreteness factor')

dat_conc_2=subset(dat_conc, concreteness==2)
dat_conc_1=subset(dat_conc, concreteness==1)
dat_conc_3=subset(dat_conc, concreteness==3)
dat_conc_4=subset(dat_conc, concreteness==4)
dat_conc_5=subset(dat_conc, concreteness==5)


data=merge(dat_conc, length_type, on='Type', how='inner')
boxplot(Conc.M ~ lexical_class,dat_conc, ylab="Continuous measure of concreteness", xlab="Lexical class", main="Box plot of concreteness among different lexical classes in the CDI-TPs lexicon")
boxplot(concreteness ~ lexical_class,dat_conc, ylab="Categorical measure of concreteness", xlab="Lexical class", main="Box plot of concreteness among different lexical classes in the CDI-TPs lexicon")

ggpairs(data %>%
          select(lexical_class, concreteness, num_syllables)
)


ggpairs(data %>%
          select(Conc.M,log_freq, log_freq_tps, num_syllables)
)

corrgram( data %>%
          select( concreteness,log_freq, log_freq_tps, num_syllables), 
          lower.panel=panel.ellipse,
          upper.panel=panel.pts, text.panel=panel.txt,
          diag.panel=panel.minmax, main="Correlation between variables") 

# get babiness of items
english_iconicity <- read_csv("~/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/Analysis_algos_CDI/babiness_iconicity/english_iconicity.csv")%>%
  rename(Type=word)%>% 
  mutate(
    babiness=scale(babyAVG, center=TRUE, scale=TRUE)
  )%>%
  select(Type, babiness)

babiness=aggregate(english_iconicity[, 2], list(english_iconicity$Type), mean)%>%
  rename(Type=Group.1)

hist(babiness$babiness)


# get valence of items
valence <- read_csv("~/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/Analysis_algos_CDI/valence/valence.csv")%>%
  select(Word, V.Mean.Sum, A.Mean.Sum) %>%
  rename(Type = Word) %>%
  mutate(
    valence=scale(V.Mean.Sum, center=TRUE, scale=TRUE), # need to center and scale all predictor to have comparable units
    arousal=scale(A.Mean.Sum, center=TRUE, scale=TRUE)
  )%>%
  select(Type, valence, arousal)
  
hist(valence$valence)
hist(valence$arousal)


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


# merge all dataframes 
#dat=merge(tp_groups, eng_prop_understand, by='Type')

dat=merge(freq_tps, eng_prop_understand)
dat=merge(dat, length_type, by='Type')
dat=merge(dat, concreteness, by='Type')
dat=merge(dat, babiness, by='Type')
dat=merge(dat,valence, by='Type')


dat=merge(freq_brent, dat)

# get a 1 or 0 code if each infant understand or not a word, for each word
dat$response=as.integer(dat$value == "TRUE")


# visualize data
ggpairs(dat %>%
          select(lexical_class, concreteness)
        )

ggpairs(dat %>%
          select(lexical_class, frequency)
)

dat_group=merge(dat, tp_groups, by='Type')
boxplot(prop~ group,dat_group, xlab= "Groups of words with high and low occurences in TP lexicon", ylab="Mean proportion of infants understanding words of the two groups")

HF=subset(dat_group, group=='HF')
LF=subset(dat_group, group=='LF')
t.test(HF$prop, LF$prop)
# linear mixed effect models account for  by-infant and by-word variation
# different intercepts for different subjects, we now also have different
# intercepts for different items

    '''
see "http://www.bodowinter.com/tutorial/bw_LME_tutorial2.pdf" 
    Note the efficiency and elegance of this model. Before, people used to do a lot of
    averaging. For example, in psycholinguistics, people would average over items
    for a subjects-analysis (each data point comes from one subject, assuring
    independence), and then they would also average over subjects for an itemsanalysis
    (each data point comes from one item). There’s a whole literature on the
    advantages and disadvantages of this approach (Clark, 1973; Forster & Dickinson,
    1976; Wike & Church, 1976; Raaijmakers, Schrijnemakers, & Gremmen, 1999;
    Raaijmakers, 2003; Locker, Hoffman, & Bovaird, 2007; Baayen, Davidson, &
    Bates, 2008; Barr, Levy, Scheepers, & Tilly, 2013).

    '''
l=length(dat$Type)
ratio=5/10 # training on dataset
u=sample(1:l, l*ratio)    

## train set 
train=dat[u,]
    
## test set 
test=dat[-u,]

boxplot(concreteness ~ group,dat,main="Concreteness", xlab="High and low frequency groups of words", ylab="Concreteness of words segmented by TPs")

boxplot(response ~ age,dat,main="Effect of age on frequency of segmented words ", xlab="Age (months)", ylab="Occurences of words segmented by TPs")

boxplot(Freqgold ~ lexical_class,dat,main="Effect of lexical classes on frequency of words in CDS corpus ", xlab="Lexical classes", ylab="Occurences of words in Brent corpus")


### use the adaptive Gauss-Hermite quadrature to approximate the likelihood

coef_fun <- function(model) {
  broom::tidy(lang_model) %>%
    filter(term != "(Intercept)") %>%
    select(term, estimate, std.error)
}

## linear model 
m_lc<-lm(prop~age + lexical_class, dat)
summary(m_lc)

m0_tps<-lm(prop~age + log_freq, dat)
summary(m0_tps)

m0_gold<-lm(prop~age+ frequency, dat)
summary(m0_gold)

m_tps<-lm(prop~age+ log_freq+lexical_class, dat)
summary(m_tps)

m_gold<-lm(prop~age+ frequency+lexical_class, dat)
summary(m_gold)

ages=c(8:18)
algos=c('tps', 'gold')

df=data.frame(matrix(NA, nrow=11, ncol=2))
names(df)=c( 'tps', 'gold')

for (i in ages)
{
  
  df[i,1]=summary(lm(prop~log_freq, subset(dat, age==i)))$r.squared
  df[i,2]=summary(lm(prop~frequency, subset(dat, age==i)))$r.squared
  
}
m0_tps_age<-lm(prop~log_freq, subset(dat, age==8))
summary(m0_tps_age)$r.squared
df

m0_gold_age<-lm(prop~frequency, subset(dat, age==8))
summary(m0_gold_age)$r.squared

# random intercept mode by item only
m0_fixed_e_age_group= glm(response  ~ age  + group ,family = "binomial", data = train) #AIC 57861

m_group=glmer(response  ~ age  + group + (1 | group) ,
              family = "binomial", data = train, nAGQ=0) #BIC 57897.50

m_group_random_slope_age=glmer(response  ~ age  + group + (1 +age| group) ,
              family = "binomial", data = train, nAGQ=0) # 57885.3 corr variance group/age =-1 => dont explain more variance

m_subject<- glmer(response  ~ age  + group + (1 | data_id) ,
                    family = "binomial", data = train, nAGQ=0) # BIC 53576.54 

m_group_subject<- glmer(response  ~ age + group +  (1 | data_id),
           family = "binomial", data = train, nAGQ=0) #BIC 53576.5

m_group_subject_age<- glmer(response  ~ age + group +  (1 | data_id) + (1| age),
                        family = "binomial", data = train, nAGQ=0) # BIC 53587.1

m_group_subject_slope_by_age<- glmer(response  ~ age + (1|group)+  (1 +age| data_id),
                        family = "binomial", data = train, nAGQ=0)

m_random_slope_lex_class<- glmer(response  ~ age + (1|lexical_class)+  (1 | data_id),
                                       family = "binomial", data = train, nAGQ=0) # BIC 49908.0

m_group_random_slope_lex_class<- glmer(response  ~ age + group+ (1|lexical_class)+  (1 | data_id),
                                 family = "binomial", data = train, nAGQ=0) # BIC 48894.69

m_group_lc_random_slope_lc<- glmer(response  ~ age + group+ lexical_class + (1|lexical_class)+  (1 | data_id),
                                       family = "binomial", data = train, nAGQ=0) # BIC 48896.5
m_group_random_slope_lc_age<- glmer(response  ~ group+ (1|age) + (1|lexical_class)+  (1 | data_id),
                                   family = "binomial", data = train, nAGQ=0) # BIC 48936.9


# random slope mode by item only
m_type_age<- glmer(response  ~ age + (1 +age | Type),
           family = "binomial", data = train, nAGQ=0)
coef_m01=coef_fun(m01) 

# random slope mode by subject only
m02<- glmer(response  ~ age + (1|group)+ (1 +age | data_id),
            family = "binomial", data = train, nAGQ=0)
coef_m02=coef_fun(m02) 

# random intercept model by subject and by item
m10<- glmer(response  ~ age + frequency + (1 | Type) +(1 | data_id),
           family = "binomial", data = train, nAGQ=0)
coef_m10=coef_fun(m10) 

# random slope model by item and random intercept by subject 
m110<- glmer(response  ~ age +  (1 +age | Type) +(1 | data_id),
            family = "binomial", data = train, nAGQ=0)
coef_m110=coef_fun(m110) 

m101<- glmer(response  ~ age +  (1 | Type) +(1 + age| data_id),
             family = "binomial", data = train, nAGQ=0)


# random slope model by subject and by item : the understanding of word is not the same depending on age
m11<- glmer(response  ~ age + (1 +age | group) +(1 +age | data_id),
                    family = "binomial", data = train, nAGQ=0)
coef_m11=coef_fun(m11) 


## intergating the predictors
predictors <- c("group", "lexical_class", "concreteness",  "arousal", "babiness")

# random slope by item only
predictor_formula <- as.formula(
  sprintf("response ~ (1 +age | Type)  + age + %s", paste(predictors, collapse = " + "))
)

# random slope by item and by subject
predictor_formula <- as.formula(
  sprintf("response ~  (1|lexical_class)+(1 | data_id) + age + %s", paste(predictors, collapse = " + "))
)

# no_interact # BIC 44919.7
no_interact_random_int_by_lc_subject <- glmer(predictor_formula, family = "binomial", data = train,nAGQ=0,
                     control=glmerControl(optimizer="bobyqa")) 

## interaction between predictors
interaction_formula <- as.formula(
  sprintf("response  ~ (1 +age | Type) + (1 +age | data_id) + age + %s + %s",
          paste(predictors, collapse = " + "),
          paste(sprintf("age * %s", predictors), collapse = " + "))
)

interact <- glmer(interaction_formula, family = "binomial", data = train,
                  control = glmerControl(optCtrl = list(maxfun = 1e5)))


## question : how many infants do I need to get a statistical significance ?


