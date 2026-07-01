# FindGSF.cmake

cmake_minimum_required(VERSION 3.15)

find_path(GSF_INCLUDE_DIR
    NAMES gsf-input-stdio.h gsf-infile.h gsf-infile-stdio.h gsf-output-stdio.h gsf-outfile.h gsf-outfile-msole.h
    PATHS
        /usr/include
    PATH_SUFFIXES libgsf-1 libgsf-1/gsf
    REQUIRED
)
find_library(GSF_LIBRARY_DIR NAMES libgsf-1.so libgsf-1.a REQUIRED)

mark_as_advanced(GSF_INCLUDE_DIR GSF_LIBRARY_DIR)

if (GSF_INCLUDE_DIR AND GSF_LIBRARIES)
    set(GSF_FOUND TRUE)
else()
    set(GSF_FOUND FALSE)
endif()
