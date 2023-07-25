CXX = g++
FC = gfortran

# relevant flags
CXXSTD = -std=c++11
FSTD = -std=f2008
FFLAGS += -Iobj

all: cheat fheat

cheat: obj/cheat.o
	$(CXX) -o $@ $^

fheat: obj/fheat.o obj/ArgParser.o obj/EnergyField.o
	$(FC) $(FFLAGS) -o $@ $^

obj/fheat.o: obj/ArgParser.o obj/EnergyField.o
obj/EnergyField.o: obj/ArgParser.o

obj/%.o: src/%.cpp
	$(CXX) $(CXXSTD) $(CXXFLAGS) -c -o $@ $<

obj/%.o: src/%.f90
	$(FC) $(FSTD) $(FFLAGS) -J obj -c -o $@ $<
