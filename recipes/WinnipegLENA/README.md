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

- need to check whether cha2sel or cha2selwithinputp used (makes NO difference here)
- need to check whether selcha2clean is being used
- launched phonologizer but since long queue, gave up waiting
- in any case, I could check that indeed 2_cha2ortho.sh generates LS and HS versions that have different number of words --> this needs to be fixed!!

