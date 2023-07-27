cmake_minimum_required(VERSION 3.8)

project(multiphys VERSION 1.0 LANGUAGES CXX Fortran)

find_package(heateq 0.1 CONFIG REQUIRED)
add_executable(multiphys ../src/fheat.f90)
target_link_libraries(multiphys PRIVATE heateq::fheateq)

add_executable(test_cpp ../src/cheat.cpp)
target_link_libraries(test_cpp PRIVATE heateq::cheateq)

install(TARGETS multiphys DESTINATION bin)
install(TARGETS test_cpp DESTINATION bin)
