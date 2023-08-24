function(add_doxygen_generation_target)
  if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile.in)
    set(DOXYGEN_IN ${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile.in)
  else()
    set(DOXYGEN_IN /usr/share/softeq/Doxyfile.in)
  endif()
  find_package(Doxygen)
  if (DOXYGEN_FOUND)
      set(DOXYGEN_OUT ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile)
      set(DOXYGEN_PROJECT_NAME ${PROJECT_NAME})
      configure_file(${DOXYGEN_IN} ${DOXYGEN_OUT})

      add_custom_target(doc_doxygen
          COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYGEN_OUT}
          WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
          COMMENT "Generating API documentation with Doxygen"
          VERBATIM )
  else (DOXYGEN_FOUND)
    message(WARNING "Doxygen need to be installed to generate the doxygen documentation")
  endif (DOXYGEN_FOUND)
endfunction(add_doxygen_generation_target)
