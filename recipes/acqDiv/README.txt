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


-------Questions
it turns out that we have some initial results, but, before we believe them, we would like your opinion on some of our observations concerning the corpora.

NOTES
- Why are there utterances that are empty or NA? We became aware of this when selecting for language=="Japanese", then the first 150 rows are NA

for Japanese -- We are surprised about:
- there are clusters (issho) -- are you not transcribing devoiced vowels?
- There are words that are a single consonant ("b", "n") 
- There are word-initial geminates (tte, kke)
- How do we deal with allophony? Most s before i is transcribed sh; more rarely ʃ; and sometimes even left as s -- and sometimes sh before other Vs (Taishoo); both ts and t occur before i
--many one-letter words (sometimes repetitive) p.e. "ŋ" or "n" in japanese corpus "ŋ ŋ ŋ ŋ ŋ ŋ ka ka ka ka ka ka " or " n janai"

In both corpora,
- What does ??? mean in for instance in the sequence:
gueibe
???
Kakka ???
Kakka no in japanese
or kanchi salima ??? in chintang
Does it mean "not understood" or are we missing some characters?


Chintang:

- is o: the same as oo?

- how do you syllabify diphthongs? What do accents on vowels mean? Should we remove the accent (i.e., they just mark stress) or should we use a different symbol for the vowel (i.e., à means a different quality from a)? What are symbols like this: aa -- a phonetically lengthened vowel (i.e., we should replace aa with a) or a phonologically long vowel (i.e., we should use a different symbol)?
- what do all different symbols such as -,  _, ~, mean found in both texts? should we ignore them?


#-chintang avg word length 4.14
#-japanese avg word length 3.65


---------Answers
First of all, let me emphasize that all of our corpora are far from perfect. Each of them has their own issues and whether those impede you or not depends a lot on what you want to do. Since we don't have the resources to correct all the problems in the source data, our general approach is that a corpus is okay to work with if the biggest part of it is good. 

Now to your questions: 
What does "???" mean? 
We insert this string in the processing when we know there should be an element in this place but we don't know what it looks like. Typically this is the result of gaps in the source data. For instance, in a number of CHAT corpora, all dependent morphemes are glossed but no phonological string is specified (for instance, we know that there is a plural suffix but we don't know what it looks like). In this case, morphemes.gloss will be "PL" and morphemes.morpheme will be "???". This is very frequent in Japanese because the corpus simply is designed like that but should be rather rare in Chintang, where in principle all morphemes have phonological and semantic representations, so "???" is due to occasional "bugs" in the annotations (let me know if otherwise and we can look at the details). 
What do symbols such as  -,  _ , ~ mean i.e. "Dooru_izumi-chan" (japanese)?
Most of this is occasional source data garbage. "_" is inserted where compounds found in the source data are merged to a single word for reasons of consistency (I can tell you more if you're interested, but all in all it's not that exciting). 
As far as Japanese is concerned, the following are unusual:
clusters i.e. "issho" - are you not transcribing devoiced vowels?
As you probably know, there are a number of competing Romanization traditions for Japanese. "issho" is standard Hepburn, now probably the most widespread system. <ssh> represents /ɕɕ/ or /ɕː/ or /sj/ depending on your phonological preferences, but there are definitely no devoiced vowels here (vowel devoicing is a rather late superficial process in Japanese and is therefore not rendered in any of the Romanization systems, just in narrow phonetic transcriptions, which these corpora don't have, at least not consistently). 
single-consonant words, sometimes repetitive i.e. "ŋ ŋ ŋ ŋ ŋ ŋ ka ka ka ", " n janai", "kono b da"
Japanese children can pronounce more things than adults :-). The corpora sometimes make compromises, so even though <b> isn't possible within the frame of the standard Romanizations they allow it in child speech because <bu> would be less accurate. 
word-initial geminates i.e."tte", "kke"
These exist. Simple fact of Japanese phonology. Both tte and kke are in fact particles. 
Also, how do we deal with allophony? It seems that most /s/ before i are transcribed sh, more rarely ʃ or even left as s. Sometimes, there is sh before other vowels (i.e. "Taishoo") and both ts and t occur before i.
That's Hepburn, so very much standard. If you're really interested in Japanese phonology it would probably be a good idea to learn more about Romanization systems, e.g. Hepburn <shi> = Nihonshiki <si> etc. https://en.wikipedia.org/wiki/Romanization_of_Japanese is a good place to start. 
Moreover, regarding Chintang:
what are symbols like "aa"? Is it a phonetically lengthened vowel (i.e., we should replace aa with a) or a phonologically long vowel (i.e., we should use a different symbol)?
Chintang doesn't have phonologically long vowels. However, at the time the corpus was created there were no strict rules for what to do with phonetically long vowels, which are very frequent in informal language, especially when produced by children. So <aa>, <aaa> etc. are frequent and probably indicate phonetic lengthening, but phonologically they're always equivalent to <a>. Also, not all phonetically long vowels have been marked that way, so I think it would be better to normalize all these to <a>. 
is "o:" the same as "oo"?
I don't know - this is one of the occasional "bugs" I already mentioned. Overall this should be very rare and hence irrelevant (again let me know if I'm wrong). 
what do accents on vowels mean? Should we remove them (i.e., they just mark stress) or use a different symbol for the vowel (i.e., à means a different quality from a)? 
That's also occasional digressions from the transcription conventions - the Chintang transcribers were native speakers with a rough training. Best replace <á/à> by <a> etc.
And, finally, how should we syllabify diphthongs?
That's a complex question because many diphthongs are shallow (i.e. it's still pretty obvious that they go back to VC) and diphthongs in Nepali words behave differently than in Chintang words. The simple answer is "diphthongs are monosyllabic", but let me know if you need to know more about the subtleties. 
