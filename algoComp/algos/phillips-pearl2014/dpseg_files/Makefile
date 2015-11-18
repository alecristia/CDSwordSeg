############################################################
#                                                          #
#                      Run jobs                            #
#                                                          #
############################################################

PROGRAM=dpseg

TARGETS=$(PROGRAM)

top: $(PROGRAM)

all: top

############################################################
#                                                          #
#                    Program build                         #
#                                                          #
############################################################

# MAC FLAGS
# CFLAGS_BASE = -MMD -O6 -Wall -ffast-math -Wno-deprecated -finline-functions -fomit-frame-pointer -fstrict-aliasing $(GCCFLAGS)
# debug compile for mac flags
# CFLAGS_BASE = -v -MMD -O0 -Wall $(GCCFLAGS) -g -DNDEBUG
CFLAGS_BASE = -MMD -O6 -Wall -ffast-math -Wno-deprecated -finline-functions -fomit-frame-pointer -fstrict-aliasing $(GCCFLAGS)  -g -DNDEBUG
# Goldwater original flags
#CFLAGS_BASE = -MMD -O6 -Wall -ffast-math -finline-functions -fomit-frame-pointer -fstrict-aliasing $(GCCFLAGS)# -DNDEBUG 
LDFLAGS_BASE = -Wall -O6
ifeq ($(OSTYPE),windows)
CFLAGS = $(CFLAGS_BASE) -DOS_WINDOWS -I /usr/include/boost-1_33_1/
LDFLAGS = $(LDFLAGS_BASE) -enable-auto-import -L /usr/lib/
LIBS = boost_program_options-gcc-mt
CXX = g++-4
else
#CFLAGS = $(CFLAGS_BASE) -DOS_LINUX  -I /opt/local/include/gcc44/c++/boost/ 
# CFLAGS = $(CFLAGS_BASE) -DOS_LINUX  -I /opt/local/include/boost/ 
CFLAGS = $(CFLAGS_BASE) -DOS_LINUX -I /usr/local/include/boost/
LDFLAGS = $(LDFLAGS_BASE) -L /usr/lib/
#LDFLAGS = $(LDFLAGS_BASE) 

#######################################################
# CHANGE THIS TO WHEREVER BOOST INSTALLS LIBRARY      #
# FILES. CHANGE VERSION NUMBER TO MATCH YOUR CURRENT  #
# BOOST VERSION                                       #
#######################################################
LIBS = /usr/lib64/libboost_program_options.so -lstdc++ -lm

# using GCC 4.4 from macports
CXX = gcc
endif
CC = $(CXX)
EXEC = time
#
# debugging
#
# CFLAGS = -g -MMD -Wall -ffast-math -fstrict-aliasing $(GCCFLAGS) # -D_GLIBCXX_DEBUG # -D_GLIBCXX_CONCEPT_CHECKS 
# LDFLAGS = -g -Wall
# EXEC = valgrind --tool=memcheck --leak-check=full
#
# profiling
#
# CFLAGS = -g -pg -O6 -MMD -Wall -ffast-math -fno-default-inline -fno-inline $(GCCFLAGS)
# CFLAGS = -g -pg -O -MMD -Wall -ffast-math $(GCCFLAGS)
# LDFLAGS = -g -pg

CXXFLAGS =  $(CFLAGS)

SOURCES = stimseg.cc main.cc Estimators.cc Data.cc Sentence.cc Scoring.cc gammadist.c mt19937ar.c mygamma.c
OBJECTS = $(patsubst %.l,%.o,$(patsubst %.c,%.o,$(SOURCES:%.cc=%.o)))

dpseg: main.o Estimators.o Data.o Sentence.o Scoring.o gammadist.o mt19937ar.o
	$(CXX) $(LDFLAGS) $^ $(LIBS) -o $@

stimseg: stimseg.o Estimators.o Data.o Sentence.o Scoring.o gammadist.o mt19937ar.o
	$(CXX) $(LDFLAGS) $^ -l $(LIBS) -o $@

.PHONY: 
clean:
	rm -fr *.o *.d core 

.PHONY:
real-clean: clean
	rm -fr $(TARGETS)

# this command tells GNU make to look for dependencies in *.d files
-include $(patsubst %.l,%.d,$(patsubst %.c,%.d,$(SOURCES:%.cc=%.d)))
