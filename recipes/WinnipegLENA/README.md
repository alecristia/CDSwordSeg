Notes recipe creation: 
Analisis of Bernstein CHILDES transcriptions
-------
# Note
all steps had already been created by Mathieu, just taking notes about minor considerations/edits since then

# 2016

- using absolute paths rather than relative ones or symlinks ({.1} notation)
- this is happening inside step 1: inappropriate, as in the next step we run it through selcha2clean!
        # NOTE some hmm, hmmm are badly phonologized, replace them by hum
        sed -r 's/hmm+/hum/g' |

- broke down selcha2clean into two portions
- in any case, I could check that indeed at the level of ortho, LS and HS versions that have different number of words --> this needs to be fixed!!
To fix it, I did the diff between ADS-LS and -HS, which differ in nb of words as follows: 8215 versus 8256
Reasons for divergence: systematically, this was due to human coding errors (i.e., change of speaker in a sentence that was supposed to be a continuation of the preceding one). Since this has very slight effects (40 words for ADS, 8 words for CDS) leaving everything as is

