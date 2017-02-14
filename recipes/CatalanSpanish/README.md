Notes recipe creation: 
Analisis of a small coprus of Catalan and Spanish plus creation of a Bilingual mixed corpus
-------

# Step 1: Database creation

- I used as basis nfrchildes2yo: 1_clean_many_files.sh
- I opened & edited lines 1-32, adapting the paths
- I simplified the rest of the script, removing the re-creation of the cha files
- I left in the lines to create the participant selection on the fly for each file, based on the specified roles
- I use the version of cha2sel that uses that speaker selection 
- I didn't need to edit the section selcha2clean
- finally I did:
cd CDSWordSeg/recipes/nfrchildes2yo/
chmod +x 1_clean_many_files.sh  
./1_clean_many_files.sh


TODO:

- add separation of child and adult directed speech. This should occur just before the cha2sel; look at the bernstein corpus for inspiration? -> thus, we could create three versions: all, CDS, and ADS
- there's still the possibility that the speaker filter is not perfect - check lucasyoel NI1 and NI2

# Step 2: Phonologization

- I used as basis Laia's latest wrapper_oneFilePerCorpus.sh which contains transcription for Spanish
! I adapted it to castillan spanish and catalan 

- changed ORTHO definition to a loop because we have many files

# Step 3: Concatenation

- Mixing each 2 and 100 lines from catalan and spanish files.
- There is one script for the concatenation of the monolingual corpus and a different one for the bilingual coprus. 
ToDo: 
- Try new changes (to exclude the last lines of the script) --> look at the coprus 2k versus 100k and check that they contain the same. 

# Step 4: Segmentation 

- Segment the coprus with several algorithms. You can choose which ones you want to use by includeing them in the script (line X)

# Step 5: Compilation

- This setp extracts all the results and compilates them in a single .txt. 
- Currently includes a patch (blanck line problem)

# Bigwrap: By runing it you go thought all the previous steps

TODO:

phonologiser for cat include vowels /o/ and /e/ 

inspect the results & make some decisions

write the AG grammar for the mix