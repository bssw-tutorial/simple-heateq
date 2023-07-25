#ifndef _HEAT_ENERGY_HPP
#define _HEAT_ENERGY_HPP

#include <vector>
#include <algorithm> /* std::swap */

namespace heateq {
/* Class storing the energy as a function of position
 * at a single time.  The internal representation uses a grid
 * with N intervals and spacing dx.
 *
 * The grid values are stored at the end-points of each
 * interval, making the internal vector size N+1.
 *
 */
struct Energy {
    const int N;
    const real dx;
    std::vector<real> u, u_last;

    Energy(const Params &p)
      : N(p.Nx), dx(p.dx)
      , u(N+1, 1.0)
      , u_last(N+1) {}

    /* Update the solution, u and u_last */
    void step(real alpha, real dt) {
        // time-constant for updating
        real k = alpha*dt / (dx*dx);
        // Start by swapping u and last
        std::swap(u, u_last);
        // Now paint new solution into u

        // update (N-1) interior points
        // partial u/partial t = alpha partial^2 u/partial x^2
        // \Delta u = (dt*alpha/dx^2) D^2 u
        for(int i=1; i<N; i++) {
            u[i] = u_last[i] + k*(u_last[i-1]-2*u_last[i]+u_last[i+1]);
        }
        u[0] = u_last[0];
        u[N] = u_last[N];
    }
    void set_bc(const real u0, const real u1) {
        u[0] = u0;
        u[N] = u1;
    }
    real en() {
        // C++17 parallel reduce [#include<numeric>]
        //real ans = std::reduce(std::execution::par, u.cbegin(), u.cend());
        real ans = 0.5*(u[0]+u[N]);
        for(int i=1; i<N; i++) {
            ans += u[i];
        }
        return ans*dx;
    }
};
}
#endif
