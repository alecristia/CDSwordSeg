Notes recipe creation: 
Analisis of Bernstein CHILDES transcriptions
-------
# Note
all steps had already been created by Mathieu, just taking notes about minor considerations/edits since then

# 2016

- using absolute paths rather than relative ones or symlinks ({.1} notation)
- rerun the whole pipeline this way and found about .03 differences in puddle, tp, dibs compared to results we had before
- it may be that I'm not using the same data
- or it may be changes to intermediate steps
- I notice that we are using cha2sel here; we should be using the cha2selwithinputp etc -- in this case, it makes NO difference, so leaving it as is
- culprit is not cha2sel: last edit there was Mathieu's
- culprit is most probably selcha2clean --> this file should split into several because the rewrite rules are corpus specific, and I see all the ones I wrote for bernstein are commented out
- unlikely that it's the phonologizer - this part hasn't changed much
- no changes to algos, so that should be OK

- CONCLUSION: edit selcha2clean & rerun