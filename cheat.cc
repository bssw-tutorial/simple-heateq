#include <stdlib.h>
#include <vector>
#include <iostream>
#include <string>

using real = double;

enum class IC { Const, Sin };

std::ostream& operator<<(std::ostream& os, const IC& init) {
    switch(init) {
    case IC::Const:
        os << "const";
        break;
    case IC::Sin:
        os << "sin";
        break;
    }
    return os;
}

struct Params {
    real alpha;
    real u0, u1;
    real dx, dt;
    int Nx, Nt;
    IC init;

    Params() : alpha(1.0), u0(0.0), u1(0.0),
               dx(1.0), dt(0.001), Nx(10), Nt(10),
               init(IC::Const) {}
    void show() {
        std::cout << "Nx = " << Nx << std::endl;
        std::cout << "Nt = " << Nt << std::endl;
        std::cout << "bc = " << u0 << " " << u1 << std::endl;
        std::cout << "alpha = " << alpha << std::endl;
        std::cout << "dx = " << dx << std::endl;
        std::cout << "dt = " << dt << std::endl;
        std::cout << "ic = " << init << std::endl;
    }
};

void usage(const char *prog) {
    std::cout << "Usage: " << prog << " [options]\n";
    std::cout << "  Options:\n";
    std::cout << "     -Nx <int>               Number of grid-points (10)\n";
    std::cout << "     -Nt <int>               Number of time-steps (10)\n";
    std::cout << "     -bc <real u0> <real u1> Dirichlet boundary conditions (0 0)\n";
    std::cout << "     -alpha <real>           Diffusion coefficient (1 cm^2/s)\n";
    std::cout << "     -dx <real>              Grid spacing (1 cm)\n";
    std::cout << "     -dt <real>              Time step    (0.001 s)\n";
    std::cout << "     -ic [const|sin]         Initial Condition (const)\n";
}

int get_ic(std::string t, IC &init) {
    if(t == "const") {
        init = IC::Const;
        return 0;
    }
    if(t == "sin") {
        init = IC::Sin;
        return 0;
    }
    return 1;
}

Params parse_args(int argc, char *argv[]) {
    Params ret;

    char *prog = argv[0];
    while(argc >= 2) {
        std::string s(argv[1]);

        if(argc >= 3) { // check all 1-parameter options
            bool found = true;
            if(s == "-Nx") {
                ret.Nx = std::stoi(argv[2]);
            } else if(s == "-Nt") {
                ret.Nt = std::stoi(argv[2]);
            } else if(s == "-alpha") {
                ret.alpha = std::stod(argv[2]);
            } else if(s == "-dx") {
                ret.dx = std::stod(argv[2]);
            } else if(s == "-dt") {
                ret.dt = std::stod(argv[2]);
            } else if(s == "-ic") {
                if( get_ic(argv[2], ret.init) ) {
                    usage(prog);
                    exit(1);
                }
            } else {
                found = false;
            }
            if(found) {
                argc -= 2;
                argv += 2;
                continue;
            }
        }
        if(argc >= 4) { // check all 2-parameter options
            bool found = true;
            if(s == "-bc") {
                ret.u0 = std::stod(argv[2]);
                ret.u1 = std::stod(argv[3]);
            } else {
                found = false;
            }
            if(found) {
                argc -= 3;
                argv += 3;
                continue;
            }
        }
        usage(prog);
        exit(1);
    }

    return ret;
}

int main(int argc, char *argv[]) {
    Params p = parse_args(argc, argv);
    p.show();
    return 0;
}
