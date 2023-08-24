set(MODULE_NAME ${PROJECT_NAME})

project(${MODULE_NAME}_tests LANGUAGES CXX)

add_executable(${PROJECT_NAME}
  main.cc
)

target_link_libraries(${PROJECT_NAME}
  PRIVATE
  GTest::GTest
  GTest::Main
)

GTEST_ADD_TESTS(${PROJECT_NAME} "" AUTO)
