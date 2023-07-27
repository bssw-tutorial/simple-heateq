# Hello Numerical World

This repository includes programs computing the time-dependent
solution of the heat equation in 1D.

This simple problem is used to show some best-practices in
object-oriented programming and numerical simulation:

  * Encapsulate program state in high-level objects.
    Here, we use Params to collect run-time parameters
    Energy to store coefficients of the energy function.

    Better definition in your data structures can often
    lead to simpler, smaller main-loops.

  * Resource-aquisition-is-initialization (RAII) pattern.
    The Params and Energy objects automatically allocate
    memory on creation and de-allocate on destruction.

    Ideally, all resources are allocated (objects are created)
    outside the main loop.  This prevents wasting simulation time.

  * Parameterize floating-point types.  Often, codes
    can achieve speedup by using mixed-precision.
    This requires testing the solution accuracy
    with different precisions used for each part of
    the calculation.

  * Parse input parameters (or include configuration code) to
    support multiple run configurations.  This is more of
    a necessity to avoid repeating code fragments (DRY principle).

  * Keep only small instruction-lists in main() (and other
    imperative functions like simulate()).  This allows later
    code to organize sequences of instruction-listing code.

  * Minimize loops and function calls in python.
    Rely on the numpy external module API instead.

The included code also provides a demonstration of
make and cmake build styles.  The cmake build includes
tests.


## Using heateq in your C++ project

heateq installs a header-only C++ library
into `<prefix>/include/heateq/`.

For convenience with cmake projects, you can import a CMake
target that references this project using,

```
find_package(heateq REQUIRED)
...
target_link_libraries(<your target name> PRIVATE heateq::cheateq)
```

To make the installed heateq project discoverable, add its install
prefix to `CMAKE_PREFIX_PATH`.


For other projects, you can fall-back to pkg-config using,
```
$ pkg-config --cflags cheateq
$ pkg-config --libs cheateq
```

For pkg-config to find its config file, you will need to
add `<prefix>/pkgconfig`  to `PKG_CONFIG_PATH`.


## Using heateq in your Fortran project

The heateq library exports CMake package files and pkg-config files
you can reference to include heateq in other projects.
The package files are located in the library directory in
the installation prefix.

For CMake projects, find and link to heateq with,

```
find_package(heateq REQUIRED)
...
target_link_libraries(<your target name> PRIVATE heateq::fheateq)
```

To make the installed heateq project discoverable, add its install
prefix to `CMAKE_PREFIX_PATH`.


For other projects, you can fall-back to pkg-config using,
```
$ pkg-config --cflags fheateq
$ pkg-config --libs fheateq
```

For pkg-config to find its config file, you will need to
add `<heateq install prefix>/pkgconfig`  to `PKG_CONFIG_PATH`.


## References

Several references that helped me write this include:

  * [C++ string reference](https://www.cplusplus.com/reference/string)
  * [OOP Fortran constructor/destructor](https://dannyvanpoucke.be/oop-fortran-tut4-en/)
  * [OOP Fortran paper](https://www.clear.rice.edu/mech517/F90_docs/EC_oop_f90.pdf)
  * [gfortran reference](https://gcc.gnu.org/onlinedocs/gfortran)
  * [fortran90 best practices](https://www.fortran90.org/src/best-practices.html)
  * [Fortran Wiki](https://en.wikibooks.org/wiki/Fortran/Fortran_procedures_and_functions#Function)
  * [Allocate in Fortran](http://www.personal.psu.edu/jhm/f90/lectures/20.html)
  * [Derived target](https://github.com/j3-fortran/fortran_proposals/issues/28)
  * [Fortran stdlib project](https://github.com/fortran-lang/stdlib)
