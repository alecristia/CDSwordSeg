Once in your lifetime, you'll extract the relevant data and make a folder that will be transferred to oberon and encrypted. Inside this folder, please put three folders:
- data: contains original .rda and extracted versions of the corpora, in language subfolders
- processed: contains derived versions of the corpora (gold, tags, and temps), in language subfolders
- results: will contain results, in language subfolders

Once you're done, create a mounted folder for the encryption:
encfs ABSOLUTEPATHS.acqDivEncrypted ABSOLUTEPATHS/acqDivVisible

The system will ask whether you want to create the "source" and the "destination" folder (one at a time) -- say yes.

Then transfer your files, like this:
scp -r Documents/acqDivVisible/* USERNAME@129.199.81.30:ABSOLUTEPATHS/acqDivVisible

IMPORTANT: you only need to do this once. 

Thereafter, you just need to remember to mount the corpus to decrypt it:
encfs ABSOLUTEPATHS.acqDivEncrypted ABSOLUTEPATHS/acqDivVisible


and don’t forget to unmount it when you are done:

fusermount -u ABSOLUTEPATHS/acqDivVisible



NOTES
- Why are there utterances that are empty or NA? We became aware of this when selecting for language=="Japanese", then the first 150 rows are NA

for Japanese -- We are surprised about:
- there are clusters (issho) -- are you not transcribing devoiced vowels?
- There are words that are a single consonant ("b", "n") 
- There are word-initial geminates (tte, kke)
- How do we deal with allophony? Most s before i is transcribed sh; more rarely ʃ; and sometimes even left as s -- and sometimes sh before other Vs (Taishoo); both ts and t occur before i
- What does ??? mean in for instance in the sequence:
gueibe
Kakka ???
Kakka no
Does it mean "not understood" or are we missing some characters?
- is o: the same as oo?


- Chintang: how do you syllabify diphthongs? What do accents on vowels mean? Should we remove the accent (i.e., they just mark stress) or should we use a different symbol for the vowel (i.e., à means a different quality from a)? What are symbols like this: aa -- a phonetically lengthened vowel (i.e., we should replace aa with a) or a phonologically long vowel (i.e., we should use a different symbol)?


