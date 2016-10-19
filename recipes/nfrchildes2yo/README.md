Notes recipe creation: 
Extrapolation to all CHILDES Northern French databases
with kids under 2yo.
-------

- Since in this case we want to collapse over several CHILDES corpora, I use as inspiration the childes recipe folder and renamed it nfrchildes2yo


# Step 1: Database creation
	- the childes recipe was missing step 1 - I find Xuan Nga's wrapper "wrapper_clean_many_files.sh" inside database_creation and made a copy in nfrchildes2yo: 1_clean_many_files.sh
	- I opened & edited lines 1-32 (wondered what the append items do -- to revisit)
	- I edited the lines that govern which files are analyzed (now all, not just those with a single adult)
	- I added lines to create the participant selection on the fly for each file, based on the specified roles
	- I created a new version of cha2sel that uses that selection and changed the cha2sel being called inside 1_clean_many_files.sh
	- finally I did:
cd CDSWordSeg/recipes/nfrchildes2yo/
chmod +x 1_clean_many_files.sh  
./1_clean_many_files.sh
	- Note: on my mac got ERROR! illegal byte sequence --> probably a problem of encoding; but this issue does NOT occur on oberon, where all files are treated correctly. No known fix for mac users not working on oberon.


# Step 2: Phonologization --> created an issue, to be done with Mathieu in a few months
