cmake_minimum_required(VERSION 3.8)

project(multiphys VERSION 1.0 LANGUAGES CXX Fortran)

find_package(fheateq 0.1 CONFIG REQUIRED)
add_executable(multiphys ../src/fheat.f90)
target_link_libraries(multiphys PUBLIC fheateq::fheateq)

install(TARGETS multiphys DESTINATION bin)
