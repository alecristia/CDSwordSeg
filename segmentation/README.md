Setup
-----

* create a new Python 3 virtual environment

        conda create --name wordseg python=3 ipython flake8 joblib
        source activate wordseg

* install the phonemizer from https://github.com/bootphon/phonemizer

* install the wordseg package (this will install the commandline tools
  in your $HOME and make them callable from the terminal)

        python setup.py install

* then have a check, for exemple have a look to the TP segmentation algorithm

        wordseg-tp --help

* you can make sure all is running well by running our little exemple

        ./wordseg_exemple.sh