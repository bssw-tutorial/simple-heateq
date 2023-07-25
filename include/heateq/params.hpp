#ifndef _HEAT_PARAM_HPP
#define _HEAT_PARAM_HPP

#include <iostream>
#include <heateq/heat.hpp>

namespace heateq {

enum class IC { Const, Sin };

/** inline declaration prevents this from appearing in the
 *  object file - so it's safe to put in a header and include into
 *  every compilation unit.
 */
inline std::ostream& operator<<(std::ostream& os, const IC& init) {
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

}
#endif
