# research/py-cfg/Makefile
#
# Mark Johnson, version of 2nd May, 2013
#
# Usage:
#
#   production:
#
#      make clean py-cfg
#
#   debugging:
#
#      make clean run-toy NDEBUG=
#
# Other targets:
#
#  py-cfg-quad: uses quad-precision instead of double floats (doesn't underflow as much)
#
#  py-cfg-mp: uses OpenMP multi-threaded computation (try -ftree-parallelize-loops with g++ 4.8)
#
#  py-cfg-quad-mp: uses quad-precision and OpenMP

TARGETS=py-cfg py-cfg-quad py-cfg-mp py-cfg-quad-mp

top: $(TARGETS)

.PHONY: run-toy
run-toy: py-cfg py-cfg-quad testengger.lt testeng.yld
	$(EXEC) py-cfg -r 1234 -P -D -R -1 -d 100 -a 1e-2 -b 1 -e 1 -f 1 -g 1e2 -h 1e-2 -n 10 -C -E -A testeng.prs -N 10 -F testeng.trace -G testeng.wlt testengger.lt -X "cat > testeng.X1.prs" -X "cat > testeng.X2.prs" -u testeng1.yld -U "cat > testeng1.prs" -v testeng2.yld -V "cat > testeng2.prs" < testeng.yld
	$(EXEC) py-cfg-quad -r 1234 -P -D -R -1 -d 100 -a 1e-2 -b 1 -e 1 -f 1 -g 1e2 -h 1e-2 -n 10 -C -E -A q-testeng.prs -N 10 -F q-testeng.trace -G q-testeng.wlt testengger.lt -X "cat > q-testeng.X1.prs" -X "cat > q-testeng.X2.prs" -u testeng1.yld -U "cat > q-testeng1.prs" -v testeng2.yld -V "cat > q-testeng2.prs" < testeng.yld

############################################################
#                                                          #
#                    Program build                         #
#                                                          #
############################################################

NDEBUG=-DNDEBUG

SHELL=/bin/bash

ifeq ($(NDEBUG),-DNDEBUG)
  #
  # production
  #
  # CC = $(CXX)
  CFLAGS = -MMD -O6 -Wall -ffast-math -fno-finite-math-only -finline-functions -fomit-frame-pointer -fstrict-aliasing $(GCCFLAGS)
  LDFLAGS = -Wall -O6 $(GCCLDFLAGS)
  EXEC = time
else
  #
  # debugging
  #
  CFLAGS = -g -O0 -MMD -Wall $(GCCFLAGS)
  LDFLAGS = -g -Wall $(GCCLDFLAGS)
  EXEC = valgrind --tool=memcheck --leak-check=full
endif

#
# profiling
#
# CFLAGS = -g -pg -O6 -MMD -Wall -ffast-math -fno-default-inline -fno-inline $(GCCFLAGS)
# CFLAGS = -g -pg -O -MMD -Wall -ffast-math $(GCCFLAGS)
# LDFLAGS = -g -pg

CXXFLAGS = $(CFLAGS) 

SOURCES = gammadist.c mt19937ar.c py-cfg.cc xtree.cc sym.cc
OBJECTS = $(patsubst %.l,%.o,$(patsubst %.c,%.o,$(SOURCES:%.cc=%.o)))

py-cfg: gammadist.o py-cfg.o mt19937ar.o sym.o
	$(CXX) $^ -lm $(LDFLAGS) -o $@

py-cfg-quad: gammadist.o py-cfg-quad.o mt19937ar.o sym.o
	$(CXX) $^ -lm $(LDFLAGS) -o $@

py-cfg-mp:  gammadist.o py-cfg-mp.o mt19937ar.o sym.o
	$(CXX) -fopenmp $^ -lm $(LDFLAGS) -o $@

py-cfg-quad-mp: gammadist.o py-cfg-quad-mp.o mt19937ar.o sym.o
	$(CXX) -fopenmp $^ -lm $(LDFLAGS) -o $@

py-cfg-quad.o: py-cfg.cc
	$(CXX) -c $(CXXFLAGS) -DQUADPREC $< -o $@

py-cfg-mp.o: py-cfg.cc
	$(CXX) -c $(CXXFLAGS) -fopenmp $^ -o $@

py-cfg-quad-mp.o: py-cfg.cc
	$(CXX) -c $(CXXFLAGS) -fopenmp -DQUADPREC $< -o $@

gammadist.o: gammadist.c
	$(CXX) -c $(CXXFLAGS) $< -o $@
#	$(CC) -c $(CFLAGS) -std=c99 $< -o $@

mt19937ar.o: mt19937ar.c
	$(CXX) -c $(CFLAGS) $< -o $@
#	$(CC) -c $(CFLAGS) $< -o $@

.PHONY: 
clean: 
	rm -fr *.o *.d *.prs *.trace *.wlt *~ core

.PHONY: real-clean
real-clean: clean 
	rm -fr $(TARGETS)

# this command tells GNU make to look for dependencies in *.d files
-include $(patsubst %.l,%.d,$(patsubst %.c,%.d,$(SOURCES:%.cc=%.d)))
