This python code aims at analyzing this output of several word segmentation algorithms in a specified corpus. 
For the study, the corpus has been divided in 10 creating « sub corpus » or « sub » in order to look at the robustness of the algorithm’ segmentation. 

The idea is : 
1. to look at the multiple possible intersection between different word segmentation output. 
2. compare the output to the word understood (and in a second step produced) by children (that are listed in CDI). 

We used
- algos : 
	▪	dibs ( diphone based segmentation algorithm) : Robert Daland and Janet B Pierrehumbert. Learning diphone-based segmentation.
	▪	TPs (transitional probabilities): Amanda Saksida, Alan Langus, and Marina Nespor. Co-occurrence statistics as a language-dependent cue for speech segmentation.)
	▪	AGu (adaptor grammar) : Johnson et al., 2014)
	▪	puddle : Padraic Monaghan and Morten H. Christiansen.Words in puddles of sound: modelling psycholinguistic effec tsin speech segmentation.
-  Brent corpus of child directed speech 
-  the http://wordbank.stanford.edu/ database

Python code is divided by function purpose : 

- read.py takes text files input such as « freq-top.txt » (results of segmentation) or read data frames (such as the CDI data frames and transforms it into respectively in list or data frame

- divide.py divides the corpus in ten sub corpus (euclidian division). Input : text files. Output : create in the same directory ten folder containing a folder with the name of algo with text files

- translate.py translates phonological form to orthographic ones by creating a dictionary . 

- analyze.py different function to analyse the results of algo

- visualize.py plot CDI score versus Algos score for different ages and compare to the gold. Histogram and fitted regression is also plotted.

- model.py lists the possible linear or logistic regression between the proportion of infants understanding a word —belonging for in CDI and in the lexicon build by the algo — and the lexicon of the algo (the number of occurrences of a word segmented by the algo). It also provide a function that look at the correlation for a certain subset of the lexicon (subset by lexical class, or length of phoneme, etc, )

- visualize.py : plot correlation for linear regression, logistic regression, subset by parameter or not. Plot also the lexicon build the algo against the lexicon in the corpus

- categorize.py : get the lexical class of each token in the corpus studied. Used the part of speech tagger of the python library NLTK

- robustness.py : look at invariance of the f-score across different sub-corpus

These scripts are used for studying the segmentation of a corpus by different algo and and by looking their correlation with the words in CDI (correlation_brent_algo_CDI.py and correlation_bernstein_algo_CDI.py). Thus, scripts are made to look at the characteristics of the brent corpus (brent_cds.py), the bernstein corpus (bernstein_cds.py) and the CDI (CDI.py)



