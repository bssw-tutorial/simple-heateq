#include <iostream>
#include <string>

#include <heateq/params.hpp>
#include <heateq/energy.hpp>

using namespace heateq;

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

int get_ic(const std::string &t, IC &init) {
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

void simulate(Params &p) {
    Energy E(p);

    std::cout << "Time Energy\n";
    for(int n=0; n<p.Nt; n++) {
        E.set_bc(p.u0, p.u1);
        E.step(p.alpha, p.dt);
        if(n%10 == 0)
            std::cout << (n+1)*p.dt << " "
                      << E.en() << std::endl;
    }
}

int main(int argc, char *argv[]) {
    Params p = parse_args(argc, argv);
    p.show();

    simulate(p);

    return 0;
}
