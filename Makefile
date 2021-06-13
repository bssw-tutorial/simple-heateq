CXX = g++
FC = gfortran

# relevant flags
CXXSTD = -std=c++11
FSTD = -std=f2008

all: cheat fheat

cheat: obj/cheat.o
	$(CXX) -o $@ $^

fheat: obj/fheat.o
	$(FC) -o $@ $^

obj/%.o: src/%.cc
	$(CXX) $(CXXSTD) $(CXXFLAGS) -c -o $@ $^

obj/%.o: src/%.f90
	$(FC) $(FSTD) $(FFLAGS) -c -o $@ $^
