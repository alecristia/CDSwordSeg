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

IN SUM: this is now working OK for alex but it only contains CDS -- ALVARO had as homework to add the ADS



# Step 2: Phonologization

- I used as basis Laia's latest wrapper_oneFilePerCorpus.sh which contains transcription for Spanish
- changed ORTHO definition to a loop because we have many files

IN SUM:  this is also working okay

ALVARO please also change this file to process both CDS and ADS AND each NS separately

# Step 3: Concatenate corpus

- In the future we could use the fancy scripts that Laia will create, but for now we just do a brute merge of all files within CDS.

# Step 4: concatenate results
- minor edits in the one from bernstein to specify the absolute path, and remove the for loop given that we only have one version for now (to be changed in the future!)