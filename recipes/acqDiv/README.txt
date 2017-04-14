Before any of the following, remember to mount the corpus to decrypt it:

encfs ../../../.acqDivEncrypted ../../../acqDivVisible

and don’t forget to unmount it when you are done:

fusermount -u ../../../acqDivVisible

The R script used to extract utterances from the corpus doesn't need to be rerun each time, as, after all, those data will not ever change. Therefore, I'm not including it in the bigwrap script


NOTES
why use Z for sh?
3 appeared as an onset and as a vowel
please check my onset, vowel files