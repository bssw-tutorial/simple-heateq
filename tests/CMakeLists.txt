enable_testing()

# define a function to simplify adding tests
# (which consist of add_executable/target_link_libraries/add_test commands)
function(do_test target)
  add_executable(${target} ${target}.cc)
  target_include_directories(${target}
                             PUBLIC
                              ${CMAKE_SOURCE_DIR}/include
                              ${PROJECT_BINARY_DIR}/include
                            )
  add_test(NAME ${target} COMMAND ${target})
endfunction(do_test)

# Build a testing application
do_test(includefile)
