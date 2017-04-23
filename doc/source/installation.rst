Installation
============

.. note::

   Before going further, please clone the repository from
   github and go in it's root directory::

     git clone https://github.com/alecristia/CDSwordSeg.git
     cd CDSwordSeg
     git checkout mathieu-dev

Dependencies
------------

* You need a **python3** installation with conda_ installed. On
  Debina/Ubuntu, have a::

    sudo apt-get install python3
    sudo pip install conda

* The ``wordseg`` package depends on phonemizer_ (a text-to-phonemes
  converter), which in turns depends on espeak_ and festival_ (two
  text-to-speech programs). Follow the above links for installation
  guidelines. On Debian/Ubuntu simply run::

    sudo apt-get install festival espeak


System-wide installation
------------------------

This is the recommanded installation if you want to use ``wordseg`` on
your personal computer (and you do not want to contribute to the code).

Install the wordseg package (this will usually install the wordseg tools
in ``/usr/bin``)::

  sudo python setup.py install


Installation in a virtual environment
-------------------------------------

* Create a new Python 3 virtual environment and install the required dependencies::

  conda create --name wordseg python=3 pytest pytest-runner sphinx sphinx_rtd_theme boost joblib numpy pandas

* Activate your virtual environment::

  source activate wordseg

* Install the wordseg package (this will install the commandline tools
  in your $HOME and make them callable from the terminal). If you do
  not want to edit the code::

     python setup.py install

  Or if you want to edit the code::

     python setup.py develop


* Then have a check, for exemple have a look to the TP segmentation algorithm::

    wordseg-tp --help

* You can make sure all is running well by running our little exemple::

    ./wordseg_exemple.sh


Running the tests
-----------------

* To run the test suite (this requires ``pytest`` and ``phonemizer``),
  to execute it have a::

    python setup.py test

* The tests are located in ``segmentation/test`` and are executed by
  pytest_. ``python setup.py test`` is in fact an alias for ``pytest
  --verbose``, which supports a lot of options. For instance to stop
  execution at the first failure: ``pytest -x``, or to execute a
  single test function: ``pytest
  segmentation/test/test_separator.py::test_bad_separators``.


Build the documentation
-----------------------

To build the html documentation (the one you are currently reading),
have a::

  python setup.py build_sphinx

The main page is then ``./doc/build/html/index.html``. From the
``./doc`` directory, the documentation can also be generated with
``make html``.


.. _conda: https://conda.io/miniconda.html
.. _phonemizer: https://www.github.com/bootphon/phonemizer
.. _espeak: http://espeak.sourceforge.net/download.html
.. _festival: http://www.festvox.org/docs/manual-2.4.0/festival_6.html#Installation
.. _pytest: https://docs.pytest.org/en/latest/
