Notes recipe creation: 
Analisis of audio 1 of the longitudinal transcriptions from Argentina
-------

# Step 1: Database creation

- I used as basis nfrchildes2yo: 1_clean_many_files.sh
- I opened & edited lines 1-32, adapting the paths
- I simplified the rest of the script, removing the re-creation of the cha files
- I left in the lines to create the participant selection on the fly for each file, based on the specified roles
- I use the version of cha2sel that uses that speaker selection 
- I didn't need to edit the section selcha2clean
- finally I did:
cd CDSwordSeg/recipes/nfrchildes2yo/
chmod +x 1_clean_many_files.sh  
./1_clean_many_files.sh


TODO:

- add separation of child and adult directed speech. This should occur just before the cha2sel; look at the bernstein corpus for inspiration? -> thus, we could create three versions: all, CDS, and ADS
- there's still the possibility that the speaker filter is not perfect - check lucasyoel NI1 and NI2
ALVARO - esto esta o no???

# Step 2: Phonologization

- I used as basis Laia's latest wrapper_oneFilePerCorpus.sh which contains transcription for Spanish
! note, we know that there is a bug in the perl section

- changed ORTHO definition to a loop because we have many files

# Step 3: Concatenate corpus

- In the future we could use the fancy scripts that Laia will create, but for now we just do a brute merge.

TODO:

apply phonologizer to Arg files

try the new descriptive file

inspect the results & make some decisions

write the concatenator

segment the Spanish

Do all of the above with Catalan and Castillan

write the language mixer

write the AG grammar for the mix
