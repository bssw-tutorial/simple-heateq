CXX = g++
FC = gfortran

# relevant flags
CXXSTD = -std=c++11
FSTD = -std=f2008

all: cheat fheat

cheat: cheat.o
	$(CXX) -o $@ $^

fheat: fheat.o
	$(FC) -o $@ $^

%.o: %.cc
	$(CXX) $(CXXSTD) $(CXXFLAGS) -c -o $@ $^

%.o: %.f08
	$(FC) $(FSTD) $(FFLAGS) -c -o $@ $^
