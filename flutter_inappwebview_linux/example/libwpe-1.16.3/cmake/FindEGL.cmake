# - Try to Find EGL
# Once done, this will define
#
#  GL::egl - an imported library target.
#  EGL_FOUND - a boolean variable.
#  EGL_INCLUDE_DIR - directory containing the EGL/egl.h header.
#  EGL_LIBRARY - path to the EGL library.
#
# Copyright (C) 2019 Igalia S.L.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1.  Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
# 2.  Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER AND ITS CONTRIBUTORS ``AS
# IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR ITS
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

find_package(PkgConfig)
pkg_check_modules(EGL IMPORTED_TARGET egl)

find_path(
    EGL_INCLUDE_DIR
    NAMES EGL/egl.h
    HINTS ${EGL_INCLUDEDIR} ${EGL_INCLUDE_DIRS}
)
find_library(
    EGL_LIBRARY
    NAMES ${EGL_NAMES} egl EGL
    HINTS ${EGL_LIBDIR} ${EGL_LIBRARY_DIRS}
)
mark_as_advanced(EGL_INCLUDE_DIR EGL_LIBRARY)

# If pkg-config has not found the module but find_path+find_library have
# figured out where the header and library are, create the PkgConfig::EGL
# imported target anyway with the found paths.
if (EGL_LIBRARY AND NOT TARGET GL::egl)
    add_library(GL::egl INTERFACE IMPORTED)
    if (TARGET PkgConfig::EGL)
        set_property(TARGET GL::egl PROPERTY INTERFACE_LINK_LIBRARIES PkgConfig::EGL)
    else ()
        set_property(TARGET GL::egl PROPERTY INTERFACE_LINK_LIBRARIES ${EGL_LIBRARY})
        set_property(TARGET GL::egl PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${EGL_INCLUDE_DIR})
    endif ()
endif ()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(EGL
    FOUND_VAR EGL_FOUND
    REQUIRED_VARS EGL_LIBRARY EGL_INCLUDE_DIR
)
