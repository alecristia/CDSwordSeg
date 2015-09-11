Readme for AG algo in algocomp study using Lyon's corpus

Base: Readme for segmentation project using function words in AG (Johnson et al., 2014); Updated 09/26/2014

Folder & file organization

Your analysis folder should contain the following subfolders: - <CORPUS>_corpus folder: contains the test corpus and gold, named with the following conventions

GRAMMAR: adaptor grammar to be used for training –> XXXX.lt
GOLD: the BR corpus to be used for evaluation –> XXXX.gold
INPUT: the unsegmented corpus –> br-phono_no_apostrophe.ylt (different from MJ: we expand to the full versions all the apostrophes)
- grammars folder: contains all the grammars that you created, and Xuan Nga can give you some sample ones

- py-cfg-new: contains the AG model

- scripts: all scripts developed by Roland to run and analyze output

- qsubs: contains .sh files (grammars start with “launch”, also list_words

- MUST BE CREATED: For each run, you should export the results to one specific folder. Name it according to grammar and corpus used: res_grammar_corpus. It will eventually contain:

OUTPUT: parse file (br.prs) and segmented file (br.seg) to be evaluated with the gold
Running a segmentation experiment

In order to segment, you must first create and reduce the parse tree representing the grammar built. Thus, if your experiment compares two or more segmentations, you might only need to run the first two steps once, whereas if you are comparing different grammars, you will repeat them as many times as grammars you consider.

STEP 1: Creating the parse tree files

Find an example of launch_job.sh in the qsubs folder and put it in the scripts/ folder. In the file, change the name and path of the grammar + name of output parse file if necessary

Navigate to the script folder and type

for j in 1:8
do ../py-cfg-new/py-cfg -n 2000 -G ../res_C0_fr/fr_run$j.wlt -A ../res_C0_fr/tmp$j.prs -F ../res_C0_fr/tmp$j.trace -E -r $RANDOM -d 101 -a 0.0001 -b 10000 -e 1 -f 1 -g 100 -h 0.01 -R -1 -P -x 10 -u ../lyon_corpus/lyon_AG_phono.ylt -U cat > ../res_C0_fr/fr-phono$j.prs ../grammars/C0_fr.lt < ../lyon_corpus/lyon_AG_phono.ylt


The output file br_run$1.wlt will be the grammar learned by the model and this file will be used later to generate the most frequent learned words

b) Reduce the parse trees:

Find an example of reduce_prs.py MJ does the following: 8 runs for 2000 sweeps. Discard the first 1000 and for the last 1000, for every 10 parse, it uses 1 to segment. –> 100 parses for each run –> 800 parses 

We do the following: for the 2000 sweeps, for every 10 parse, it uses 1 to segment –> 200 parses –> need to remove the first 100 parse to run it: 

go into the result folder and type 
module load python-anaconda/2.7.5 
python ../scripts/reduce_prs.py -n 100 br-phono* 

(-n # = number of parses to be removed / br-phono*: all the parse tree files to be applied - e.g. 8) It will automatically generate parse files with -last appended to the filename.




***stopped here

------------------------------------Steps a) and b) need to be run only once if the segmentation uses the same grammar

c) Segmentation: trees-words.py
Segmenting the parses according to the query: launch_tree.sh
in the file, change the regex (what needs to be segmented), the name and path parse file and segmented file if necessary
to run it: go into the result folder (to be created first following conventions described below) and type qsub ../qsubs/launch_tree.sh 0 (0 for 1st job, 1 for 2nd job...)

d) Extract the most frequent segmentation in the 800 sample segmentations (minimum bayes risk) and to be used in the evaluation
to run it: go into the result folder and type: python ../scripts/mbr.py br-phono*-word.seg > br_phono_mbr-word.seg

e1) Evaluation of the segmentation - individual
to run it: go into the result folder and type: python ../scripts/eval.py -g ../brent_ratner/br-phono.gold < br_phono_mbr-word.seg > eval_word.txt
The evaluation will give the following scores:
token_f-score   token_precision token_recall    boundary_f-score        boundary_precision      boundary_recall

e2) Evaluation of the segmentation - against ALL gold
This will evaluate all the segmented outputs (defined in the grammar) against all the gold (collocs5, collocs4, collocs3, collocs2, collocs1, word, morph, syllable)
Add all the mbr segmented files generated in the grammar and place them in the segmented folder - the gold folder should have all the gold and remain constant
to run it: go into the result folder and python ../scripts/eval_all.py ../brent_ratner/gold ../brent_ratner/segmented/ ../brent_ratner/evals/eval_syll_word.csv

**************************************
Alternative Evaluation: to get the f-score for distinction function words/words:
c) type: bash ../launch_tag.sh
This will create tag files - change extension and regular expression in the launch_tag file
d) mbr file: python ../scripts/mbr.py br-phono*.tag > br_phono_mbr.tag
e) evaluation of the tags: 
python ../scripts/eval_fct.py -g ../brent_ratner/br-phono_tagged_fct_MJ.gold < br_phono_mbr-word-fct.tag > eval_word-fct.txt

