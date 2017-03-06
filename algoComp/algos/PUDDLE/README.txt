To launch the python version of puddle in terminal, here is the command line

ABSPATH=$1
RESFOLDER=$2
OUTPUT=$3
WINDOW=$4

$python puddle_py.py -p $ABSPATH/tags.txt -r $RESFOLDER —o $OUTPUT -w $WINDOW

#$python puddle_py -p '/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/recipes/childes/data/Brent' -r '/Users/elinlarsen/Documents/CDSwordSeg_Pipeline/results/res-brent-CDS/full_corpus/puddle_elin' —o ‘cfgold.txt’ -w 2

window determines the number of phonemes that apply a boundary constraint to add a word chunk to the lexicon
if window==1 then when a word chunk is a candidate to be added to the lexicon, the algorithm check if the phoneme before the candidate belongs to the list of ending phonemes and if the phoneme after the candidate belongs to the list of beginning phonemes.



 


