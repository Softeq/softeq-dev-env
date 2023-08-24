cmake_minimum_required(VERSION 3.2 FATAL_ERROR)
project(example VERSION 0.1.0 LANGUAGES C)

# Build a release version by default
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()
if(NOT "${CMAKE_BUILD_TYPE}" STREQUAL "Debug"
    AND NOT "${CMAKE_BUILD_TYPE}" STREQUAL "Release")
  message(FATAL_ERROR "* Unsupported CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")
endif()
message(STATUS "* Build type: ${CMAKE_BUILD_TYPE}")

set(PRODUCT_NAMESPACE "softeq")

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_FIND_USE_PACKAGE_REGISTRY YES)
set (CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/tools/cmake" ${CMAKE_MODULE_PATH})

include (FindPkgConfig)
include(CTest)

if (BUILD_TESTING)
  find_package(GTest REQUIRED)
  option(BUILD_COVERAGE "Enable tests coverage" OFF)
endif()

add_executable(${PROJECT_NAME} src/main.c)

if (BUILD_TESTING)
  # Each library has unit tests, of course
  message(STATUS "* Tests are added to build")
  enable_testing()
  add_subdirectory(tests)

  if (BUILD_COVERAGE AND CMAKE_BUILD_TYPE STREQUAL "Debug")
    include(CodeCoverage)
    target_append_coverage_compiler_flags(${PROJECT_NAME})

    message(STATUS "* Tests coverage is added to build")

    add_custom_target(coverage
      # Create folder
      COMMAND ${CMAKE_COMMAND} -E make_directory ${PROJECT_BINARY_DIR}/Coverage
      # Running gcovr
      COMMAND ${GCOVR_PATH}
      --exclude-throw-branches
      --exclude-unreachable-branches
      --filter ${PROJECT_SOURCE_DIR}/src
      --filter ${PROJECT_SOURCE_DIR}/include
      --html --html-details
      --print-summary
      --output=${PROJECT_BINARY_DIR}/Coverage/index.html
      --sonarqube=${PROJECT_BINARY_DIR}/Coverage/sonarcube.xml
      WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
      COMMENT "Running 'gcovr' to produce code coverage report."
      )
    add_custom_command(TARGET coverage POST_BUILD
      COMMAND ;
      COMMENT "Open file://${PROJECT_BINARY_DIR}/Coverage/index.html in your browser to view the coverage report."
      )
  endif ()

  add_custom_target(test_memcheck
    COMMAND ${CMAKE_CTEST_COMMAND} ${CMAKE_CTEST_ARGUMENTS} --force-new-ctest-process --test-action memcheck
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
    COMMENT "Running unit tests with 'Valgrind'."
    )
endif()
