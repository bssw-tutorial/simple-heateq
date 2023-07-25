function(install_bins)
    set(targets ${ARGN})
    install(TARGETS ${targets} DESTINATION bin)
endfunction()

# e.g. install_libs(NAME mywrapper TARGETS mpiwrapper testhelpers HEADERS include/a.h include/b.h)
function(install_libs)
	set(oneValueArgs NAME)
	set(multiValueArgs TARGETS HEADERS)
	cmake_parse_arguments(INSTALL_LIBS "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    set(targets ${INSTALL_LIBS_TARGETS})
    set(pkg ${PROJECT_NAME})
	if(DEFINED INSTALL_LIBS_NAME)
		set(pkg ${INSTALL_LIBS_NAME})
	endif()
    message(NOTICE "Will install library targets (${targets}) and headers (${INSTALL_LIBS_HEADERS}) under package name ${pkg}")

    # Attach these libraries to the list of exported libs.
    install(TARGETS ${targets}
            DESTINATION lib
            EXPORT "${pkg}Targets")

    install(FILES ${INSTALL_LIBS_HEADERS} DESTINATION include/${pkg})
  
    # Note: we choose the following location for cmake dependency info:
    # <prefix>/lib/cmake/${PKG}/
    # install the targets to export
    install(EXPORT "${pkg}Targets"
      FILE "${pkg}Targets.cmake"
      NAMESPACE "${pkg}::"
      DESTINATION "lib/cmake/${pkg}"
    )

    # Create a config helper so others can call find_package(${PKG}::${LIBNAME})
    include(CMakePackageConfigHelpers)
    configure_package_config_file(${CMAKE_CURRENT_SOURCE_DIR}/${pkg}.cmake.in
      "${CMAKE_CURRENT_BINARY_DIR}/${pkg}Config.cmake"
      INSTALL_DESTINATION "lib/cmake/${pkg}"
      NO_SET_AND_CHECK_MACRO
      )
    # generate the version file for the config file
    write_basic_package_version_file(
      "${CMAKE_CURRENT_BINARY_DIR}/${pkg}ConfigVersion.cmake"
      VERSION "${${PROJECT_NAME}_VERSION_MAJOR}.${${PROJECT_NAME}_VERSION_MINOR}"
      COMPATIBILITY AnyNewerVersion
    )
    # install the configuration file
    install(FILES
      "${CMAKE_CURRENT_BINARY_DIR}/${pkg}Config.cmake"
      "${CMAKE_CURRENT_BINARY_DIR}/${pkg}ConfigVersion.cmake"
      DESTINATION "lib/cmake/${pkg}"
    )

	# Export a pkg-config file
	configure_file(
	  "${CMAKE_CURRENT_SOURCE_DIR}/${pkg}.pc.in"
	  "${CMAKE_CURRENT_BINARY_DIR}/${pkg}.pc"
	  @ONLY
	)
	install(
	  FILES
	  "${CMAKE_CURRENT_BINARY_DIR}/${pkg}.pc"
	  DESTINATION "lib/pkgconfig"
	)
endfunction()
