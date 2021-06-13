#!/usr/bin/env python3

import numpy as np

real = np.float64

class Params:
    def __init__(self):
        self.alpha = 1.0
        self.u0 = 0.0
        self.u1 = 0.0
        self.dx = 1.0
        self.dt = 0.001
        self.Nx = 10
        self.Nt = 10
        self.init = "const"

    def __str__(self):
        # Write in free-format, then
        # remove leading spaces from each line.
        return '\n'.join(
            line.strip() for line in
            f"""Nx = {self.Nx}
                Nt = {self.Nt}
                bc = {self.u0} {self.u1}
                alpha = {self.alpha}
                dx = {self.dx}
                dt = {self.dt}
                ic = {self.init}""".split('\n')
            )

def usage(prog):
    print(f"Usage: {prog} [options]")
    print("  Options:")
    print("     -Nx <int>               Number of grid-points (10)")
    print("     -Nt <int>               Number of time-steps (10)")
    print("     -bc <real u0> <real u1> Dirichlet boundary conditions (0 0)")
    print("     -alpha <real>           Diffusion coefficient (1 cm^2/s)")
    print("     -dx <real>              Grid spacing (1 cm)")
    print("     -dt <real>              Time step    (0.001 s)")
    print("     -ic [const|sin]         Initial Condition (const)")

def get_ic(t):
    if t in ["const", "sin"]:
        return t
    return None
        
def parse_args(argv):
    prog = argv[0]
    ret = Params()

    while len(argv) > 1:
        s = argv[1]
        if len(argv) > 2:
            found = True
            if s == "-Nx":
                ret.Nx = int(argv[2])
            elif s == "-Nt":
                ret.Nt = int(argv[2])
            elif s == "-alpha":
                ret.alpha = float(argv[2])
            elif s == "-dx":
                ret.dx = float(argv[2])
            elif s == "-dt":
                ret.dt = float(argv[2])
            elif s == "-ic":
                ret.init = get_ic(argv[2])
                if ret.init is None:
                    usage(prog)
                    exit(1)
            else:
                found = False
            if found:
                del argv[1:3]
                continue
        if len(argv) > 3:
            found = True
            if s == "-bc":
                ret.u0 = float(argv[2])
                ret.u1 = float(argv[3])
            else:
                found = False
            if found:
                del argv[1:4]
                continue
        usage(prog)
        exit(1)

    return ret

class Energy:
    def __init__(self, p):
        self.N = p.Nx
        self.dx = p.dx
        self.u = np.zeros(p.Nx+1, real) + 1.0
        self.u_last = np.zeros(p.Nx+1, real) + 1.0

    def step(self, alpha, dt):
        # time-constant for updating
        k = alpha*dt/self.dx**2
        # Start by swapping u and last
        u = self.u_last
        u_last = self.u
        self.u = u
        self.u_last = u_last
        # Now paint new solution into u

        # update (N-1) interior points
        # partial u/partial t = alpha partial^2 u/partial x^2
        # \Delta u = (dt*alpha/dx^2) D^2 u
        u[1:-1] = u_last[1:-1] + k*(u_last[:-2]-2*u_last[1:-1]+u_last[2:])
        u[0] = u_last[0]
        u[-1] = u_last[-1]

    def set_bc(self, u0, u1):
        self.u[0]  = u0
        self.u[-1] = u1

    def en(self):
        ans = 0.5*(self.u[0]+self.u[-1])
        ans += self.u[1:-1].sum()
        return ans*self.dx

def simulate(p):
    E = Energy(p)

    print("Time Energy")
    for n in range(p.Nt):
        E.set_bc(p.u0, p.u1)
        E.step(p.alpha, p.dt)
        if n % 10 == 0:
            t = (n+1)*p.dt
            print(f"{t} {E.en()}")

def heat(argv):
    p = parse_args(argv)
    print(p)

    simulate(p)

if __name__ == "__main__":
    import sys
    heat(sys.argv)
