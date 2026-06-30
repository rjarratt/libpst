# src/CMakeLists.txt -- builds libpst and the command-line tools
cmake_minimum_required(VERSION 3.15)

# Library sources (from src/Makefile.am)
set(COMMON_HEADERS
    common.h
    define.h
    libpst.h
    libstrfunc.h
    lzfu.h
    timeconv.h
    vbuf.h
)

set(COMMON_SOURCES
    debug.c
    libpst.c
    libstrfunc.c
    lzfu.c
    timeconv.c
    vbuf.c
)

if(LIBPST_NEED_XGETOPT)
    list(APPEND COMMON_SOURCES XGetopt.c)
    list(APPEND COMMON_HEADERS XGetopt.h)
endif()

# Expose include dir
#target_include_directories_global()
set(SRC_ROOT "${CMAKE_CURRENT_SOURCE_DIR}")

# Create library target
if(LIBPST_BUILD_SHARED)
    add_library(pst SHARED ${COMMON_SOURCES} ${COMMON_HEADERS})
    set_target_properties(pst PROPERTIES OUTPUT_NAME libpst)
else()
    add_library(pst STATIC ${COMMON_SOURCES} ${COMMON_HEADERS})
    set_target_properties(pst PROPERTIES OUTPUT_NAME pst)
endif()

# Public include dir
target_include_directories(pst PUBLIC
    $<BUILD_INTERFACE:${SRC_ROOT}>
    $<INSTALL_INTERFACE:include>
)

# Link extra libs (pkgconfig results forwarded from top-level)
if(LIBPST_EXTRA_LIBS)
    target_link_libraries(pst PUBLIC ${LIBPST_EXTRA_LIBS})
endif()

# Iconv support
add_compile_definitions(ICONV_CONST=)
#target_link_libraries(pst PUBLIC Threads::Threads)

# Add compile definition for debug if requested
if(LIBPST_PST_DEBUG)
    target_compile_definitions(pst PUBLIC DEBUG_ALL=1)
endif()

# Tools (executables)
# Each program uses the common headers plus its own source file(s).
add_executable(lspst lspst.c ${COMMON_HEADERS})
target_include_directories(lspst PRIVATE ${ICONV_INCLUDE_DIR})
target_link_directories(lspst PRIVATE ${ICONV_LIBRARY_DIR})
target_link_libraries(lspst PRIVATE pst ${LIBPST_EXTRA_LIBS})

add_executable(readpst readpst.c msg.cpp msg.h ${COMMON_HEADERS})
target_include_directories(readpst PRIVATE ${ICONV_INCLUDE_DIR})
target_link_directories(readpst PRIVATE ${ICONV_LIBRARY_DIR})
target_link_libraries(readpst PRIVATE pst ${LIBPST_EXTRA_LIBS})

#add_executable(pst2ldif pst2ldif.cpp ${COMMON_HEADERS})
#target_link_libraries(pst2ldif PRIVATE pst ${LIBPST_EXTRA_LIBS})
#
#add_executable(nick2ldif nick2ldif.cpp ${COMMON_HEADERS})
#target_link_libraries(nick2ldif PRIVATE pst ${LIBPST_EXTRA_LIBS})
#
#add_executable(deltasearch deltasearch.cpp ${COMMON_HEADERS})
#target_link_libraries(deltasearch PRIVATE pst ${LIBPST_EXTRA_LIBS})
#
#add_executable(dumpblocks dumpblocks.c ${COMMON_HEADERS})
#target_link_libraries(dumpblocks PRIVATE pst ${LIBPST_EXTRA_LIBS})
#
#add_executable(getidblock getidblock.c ${COMMON_HEADERS})
#target_link_libraries(getidblock PRIVATE pst ${LIBPST_EXTRA_LIBS})

if(LIBPST_ENABLE_DII)
    find_library(GD_LIB gd)
    if(GD_LIB)
        add_executable(pst2dii pst2dii.cpp ${COMMON_HEADERS})
        target_link_libraries(pst2dii PRIVATE pst ${GD_LIB} ${LIBPST_EXTRA_LIBS})
    else()
        message(WARNING "pst2dii requested but libgd not found; pst2dii will not be built")
    endif()
endif()

# Per-target include flags like libgsf's flags (if provided via pkg-config)
if(LIBPST_EXTRA_INCLUDES)
    foreach(_inc ${LIBPST_EXTRA_INCLUDES})
        target_include_directories(pst PUBLIC ${_inc})
        target_include_directories(lspst PRIVATE ${_inc})
        target_include_directories(readpst PRIVATE ${_inc})
        target_include_directories(pst2ldif PRIVATE ${_inc})
        target_include_directories(nick2ldif PRIVATE ${_inc})
        target_include_directories(deltasearch PRIVATE ${_inc})
        target_include_directories(dumpblocks PRIVATE ${_inc})
        target_include_directories(getidblock PRIVATE ${_inc})
        if(TARGET pst2dii)
            target_include_directories(pst2dii PRIVATE ${_inc})
        endif()
    endforeach()
endif()

# Provide a library alias matching expected name
add_library(libpst::libpst ALIAS pst)