cmake_minimum_required(VERSION 3.17)

project(heat VERSION 0.1 LANGUAGES CXX Fortran)

# setup all cmake variables
option(BUILD_TESTS "Build the tests accompanying this program." ON)

# generate heat.hh by substituting in cmake variables
configure_file(include/heat.hh.in include/heat.hh)

add_executable(cheat src/cheat.cc)
add_executable(fheat src/fheat.f90)

# To include dependencies, e.g. MPI, use
#
# find_package(MPI 2.0 REQUIRED)
# target_link_libraries(cheat PUBLIC MPI::MPI_CXX)
# target_link_libraries(fheat PUBLIC MPI::MPI_Fortran)
#
# Several packages are pre-defined by cmake, for example:
# https://cmake.org/cmake/help/latest/module/FindMPI.html

target_compile_features(cheat PUBLIC cxx_std_11)
#target_compile_features(fheat PUBLIC fortran_std_08)
target_include_directories(cheat
                           PUBLIC
                            ${CMAKE_CURRENT_SOURCE_DIR}/include
                            ${PROJECT_BINARY_DIR}/include
                          )

if(BUILD_TESTS)
  add_subdirectory(tests)
endif()

install(TARGETS cheat fheat
        DESTINATION bin)
