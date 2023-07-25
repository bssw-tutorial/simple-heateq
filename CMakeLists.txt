cmake_minimum_required(VERSION 3.17)

project(heateq VERSION 0.1 LANGUAGES CXX Fortran)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)
include(rpath)
include(install)

# setup all cmake variables
option(BUILD_TESTS "Build the tests accompanying this program." ON)

# create an include directory to hold generated headers and fortran modules
file(MAKE_DIRECTORY include/heateq)
set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/include/heateq)

# generate heat.hpp by substituting in cmake variables
configure_file(include/heateq/heat.hpp.in include/heateq/heat.hpp)

add_library(fheateq src/EnergyField.f90 src/ArgParser.f90)
target_include_directories(fheateq PUBLIC
                         $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include/heateq>
                         $<INSTALL_INTERFACE:include/heateq>
                        )

add_executable(cheat src/cheat.cpp)
add_executable(fheat src/fheat.f90)
target_link_libraries(fheat PUBLIC fheateq)

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
                          $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
                          $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include>
                          $<INSTALL_INTERFACE:include>
                         )

if(BUILD_TESTS)
  add_subdirectory(tests)
endif()

install_bins(cheat fheat)
install_libs(NAME fheateq TARGETS fheateq)
install(DIRECTORY include/heateq DESTINATION include)
install(DIRECTORY ${PROJECT_BINARY_DIR}/include/heateq DESTINATION include)
