

heat: heat.cc
	g++ -std=c++11 -o heat heat.cc

# relevant flags, e.g.
# CXXFLAGS += -std=c++11
# FFLAGS += -std=f2008
.o.f08:
	$(FC) $(FFLAGS) -c -o $@ $^
