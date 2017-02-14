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

- brent_cds.py compile the different functions of the other python files to the purpose : the analyze of the CDS brent corpus

