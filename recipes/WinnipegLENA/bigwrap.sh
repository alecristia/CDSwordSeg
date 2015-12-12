#!/usr/bin/env bash
# Wrapper to run WinnipegLENA experiments 201511
# Alex Cristia <alecristia@gmail.com> 2015-11-26
# Mathieu Bernard

# Create the trs folder and put Winnipeg trs files in it
#./0_gettrs.sh

# Turn the trs files into cha-like format
./1_trs2cha.sh

# Turn the cha-like files into a single clean file per type
./2_cha2ortho.sh

# Phonologize the ortholines files
./3_ortho2phono.sh

# Add length-matched versions of the CDS corpora
./4_special_step.sh

# Analyze
# ./5_analyze.sh
# ./6_collapse_results.sh
