# Copyright 2017 Mathieu Bernard
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

# TODO stimseg do not compile for now

# output directory with object code and binaries
BUILDDIR = ./build

# directory with C++ sources (must be *.cc extension) and headers
SRCDIR	= ./src
INCDIR	= ./include

# C++ compiler to use and option passed during compilation and link
CXX	= g++
CFLAGS	= -Wall -Wno-deprecated -O3 -I$(INCDIR)
LFLAGS	= -Wall -O3 -lboost_program_options

# source files must be *.cc files in $(SRCDIR)
SOURCES	= Data Estimators Scoring Sentence gammadist mt19937ar
OBJECTS	= $(SOURCES:%=$(BUILDDIR)/%.o)

.PHONY: all clean

# main executables to compile
all: build wordseg-dmcmc  # stimseg

clean:
	rm -rf $(BUILDDIR)

build:
	mkdir -p $(BUILDDIR)

$(BUILDDIR)/%.o: $(SRCDIR)/%.cc
	$(CXX) $(CFLAGS) -o $@ -c $?

wordseg-dmcmc: $(OBJECTS) $(BUILDDIR)/wordseg-dmcmc.o
	$(CXX) $(LFLAGS) -o $(BUILDDIR)/$@ $^

# stimseg: $(OBJECTS) $(BUILDDIR)/stimseg.o
# 	$(CXX) $(LFLAGS) -o $(BUILDDIR)/$@ $^
