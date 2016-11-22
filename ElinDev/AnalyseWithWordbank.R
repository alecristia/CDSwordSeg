# created by elin larsen november 20th 2016
# use the wordbankr package created by http://wordbank.stanford.edu/ team
# #Frank, M. C., Braginsky, M., Yurovsky, D., & Marchman, V. A. (in press). 
# Wordbank: An open repository for developmental vocabulary data. Journal of Child Language.
# another useful website : http://mb-cdi.stanford.edu/

# goal : check if word segmented by all algos (puddle, dibs, TPs, ngrams and AGu) 
# belongs MacArthur-Bates CDIs in English and Spanish with children 8-30 months. 

# 

library(wordbankr)
library(magrittr)
library( dplyr)
library(assertthat)
library(stringr)
library(ggplot2)

library(knitr)
opts_chunk$set(message = FALSE, warning = FALSE, cache = TRUE, fig.align = "center")
library(dplyr)
library(tidyr)
library(purrr)
library(readr)

install.packages("devtools")
devtools::install_github("langcog/langcog")
library(langcog)
library(ggrepel)
library(directlabels)


### Abbreviations :
# WS : words and sentences
# WG : words and gestures
#  %>% : pipe symbole used in the library magrittr that put the LHS argument into the Right hand side

# Iconicity : the conceived similarity or analogy between the form of a sign 
#(linguistic or otherwise) and its meaning, as opposed to arbitrariness.

english_ws_admins <- get_administration_data("English", "WS")
english_ws_items <- get_item_data("English", "WS")




items <- get_item_data("English") %>%
  mutate(num_item_id = as.numeric(substr(item_id, 6, nchar(item_id))),
         definition = tolower(definition))

words <- items %>%
  filter(type == "word", !is.na(uni_lemma), form == "WG")

uni_lemmas <- words %>%
  filter(language == "English") %>%
  select(lexical_class, uni_lemma)



