cmake_minimum_required(VERSION 3.15)
project(libpst VERSION 0.6.76 LANGUAGES C CXX)
set(VERSION ${PROJECT_VERSION})
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}")

# Match Autotools defaults where reasonable
option(ENABLE_LIBPST_SHARED "Build libpst as a shared library" OFF)
option(ENABLE_PYTHON "Build Python bindings" OFF)
option(ENABLE_DII "Build pst2dii (requires ImageMagick + gd)" ON)
option(ENABLE_PROFILING "Enable -pg profiling" OFF)
option(ENABLE_PST_DEBUG "Enable libpst debug dump file creation (DEBUG_ALL)" OFF)
option(ENABLE_STATIC_TOOLS "Link command line tools with libpst statically" OFF)
option(NEED_XGETOPT "Use bundled XGetopt" OFF)

if(ENABLE_PROFILING)
    add_compile_options(-pg)
endif()

include(CheckIncludeFile)

# Check for standard headers
check_include_file(string.h HAVE_STRING_H)
check_include_file(ctype.h HAVE_CTYPE_H)
check_include_file(errno.h HAVE_ERRNO_H)
check_include_file(errno.h HAVE_UNISTD_H)
check_include_file(iconv.h HAVE_ICONV)
check_include_file(regex.h HAVE_REGEX_H)
check_include_file(dirent.h HAVE_DIRENT_H)
check_include_file(sys/stat.h HAVE_SYS_STAT_H)

#check_include_file(limits.h HAVE_LIMITS_H)
#check_include_file(wchar.h HAVE_WCHAR_H)
#check_include_file(signal.h HAVE_SIGNAL_H)
#check_include_file(gd.h HAVE_GD_H)

# Configure a header file with the results
configure_file(config.h.in config.h)

# Define HAVE_CONFIG_H for the target
add_compile_definitions(HAVE_CONFIG_H)

# Make sure the build can find config.h
include_directories(${CMAKE_CURRENT_BINARY_DIR})


# Find tools / libs
#find_package(PkgConfig REQUIRED)
#pkg_check_modules(GSF QUIET libgsf-1)
find_package(GSF REQUIRED) # if not installed, install libgsf-1-dev (Debian/Ubuntu)
find_package(ZLIB REQUIRED) # if not installed, install zlib1g-dev (Debian/Ubuntu)
#find_package(Threads REQUIRED)

# iconv: optional; link if found
#find_library(ICONV iconv REQUIRED     )

# expose pkgconfig results for downstream
if(GSF_FOUND)
    message(STATUS "Found libgsf: ${GSF_VERSION}")
    foreach(_inc ${GSF_INCLUDE_DIR})
        list(APPEND EXTRA_INC ${_inc})
    endforeach()
    list(APPEND EXTRA_LIBS ${GSF_LIBRARIES})
endif()

if(ZLIB_FOUND)
    list(APPEND EXTRA_LIBS ${ZLIB_LIBRARIES})
endif()

# Provide variables to subdirs
set(LIBPST_EXTRA_INCLUDES ${EXTRA_INC})
set(LIBPST_EXTRA_LIBS ${EXTRA_LIBS})
set(LIBPST_BUILD_SHARED ${ENABLE_LIBPST_SHARED})
#set(LIBPST_ENABLE_DII ${ENABLE_DII})
#set(LIBPST_NEED_XGETOPT ${NEED_XGETOPT})
#set(LIBPST_PST_DEBUG ${ENABLE_PST_DEBUG})
#set(LIBPST_STATIC_TOOLS ${ENABLE_STATIC_TOOLS})

add_subdirectory(src)

if(ENABLE_PYTHON)
#    add_subdirectory(python)
endif()

# Install config / pkgconfig placeholder
# (You can extend install rules as needed)