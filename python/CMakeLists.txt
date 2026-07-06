# python/CMakeLists.txt -- optional Python binding (Boost.Python + python dev headers)
cmake_minimum_required(VERSION 3.15)

if(NOT LIBPST_EXTRA_LIBS)
    # Still ok; we link pst target directly
endif()

find_package(Python3 COMPONENTS Interpreter Development REQUIRED)
find_package(Boost COMPONENTS python REQUIRED)

if(NOT Boost_FOUND)
    message(WARNING "Boost.Python not found. Python bindings will not be built.")
    return()
endif()

# Example target name: python-libpst (shared module)
set(PY_SRC python-libpst.cpp)
add_library(python_libpst MODULE ${PY_SRC})
target_include_directories(python_libpst PRIVATE ${CMAKE_SOURCE_DIR}/src ${Boost_INCLUDE_DIRS} ${Python3_INCLUDE_DIRS})
target_link_libraries(python_libpst PRIVATE pst ${Boost_LIBRARIES} ${Python3_LIBRARIES} ${LIBPST_EXTRA_LIBS})

# Ensure proper extension naming on Unix
set_target_properties(python_libpst PROPERTIES PREFIX "" OUTPUT_NAME "libpst")