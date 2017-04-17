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


# C++ compiler to use
CXX	= g++

# directory with C++ sources (must be *.cc extension)
SRCDIR	= ./src

# directory with C++ headers
INCDIR	= ./include

# directories object code and binaries
BINDIR	= ./bin
OBJDIR	= ./build

# option passed at compilation time
CFLAGS	= -Wall -Wno-deprecated -O3 -I$(INCDIR)

# option passed at link time
LFLAGS	= -Wall -O3 -lboost_program_options

# source files must be *.cc files in $(SRCDIR)
SOURCES	= Data Estimators Scoring Sentence gammadist mt19937ar
OBJECTS	= $(SOURCES:%=$(OBJDIR)/%.o)

.PHONY: all clean

# main executables to compile TODO stimseg do not compile for now
all: dpseg  # stimseg

clean:
	rm -rf $(OBJDIR)/*
	rm -rf $(BINDIR)/*

$(OBJDIR)/%.o: $(SRCDIR)/%.cc
	$(CXX) $(CFLAGS) -o $@ -c $^

dpseg: $(OBJECTS) $(OBJDIR)/dpseg.o
	$(CXX) $(LFLAGS) -o $(BINDIR)/$@ $^

stimseg: $(OBJECTS) $(OBJDIR)/stimseg.o
	$(CXX) $(LFLAGS) -o $(BINDIR)/$@ $^
