# - Try to find libxkbcommon.
# Once done, this will define
#
#  XkbCommon::libxkbcommon
#  LIBXKBCOMMON_FOUND - system has libxkbcommon.
#  LIBXKBCOMMON_INCLUDE_DIR - directory containing the xkbcommon include directories
#  LIBXKBCOMMON_LIBRARY - link these to use libxkbcommon.
#
# Copyright (C) 2014, 2019 Igalia S.L.
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
pkg_check_modules(LIBXKBCOMMON IMPORTED_TARGET xkbcommon)

find_path(
    LIBXKBCOMMON_INCLUDE_DIR
    NAMES xkbcommon/xkbcommon.h
    HINTS ${LIBXKBCOMMON_INCLUDEDIR} ${LIBXKBCOMMON_INCLUDE_DIRS}
)
find_library(
    LIBXKBCOMMON_LIBRARY
    NAMES xkbcommon
    HINTS ${LIBXKBCOMMON_LIBDIR} ${LIBXKBCOMMON_LIBRARY_DIRS}
)

# If pkg-config has not found the module but find_path+find_library have
# figured out where the header and library are, create the
# XkbCommon::Libxkbcommon imported target anyway with the found paths.
#
if (LIBXKBCOMMON_LIBRARY AND NOT TARGET XkbCommon::libxkbcommon)
    add_library(XkbCommon::libxkbcommon INTERFACE IMPORTED)
    if (TARGET PkgConfig::LIBXKBCOMMON)
        set_property(
            TARGET XkbCommon::libxkbcommon PROPERTY INTERFACE_LINK_LIBRARIES PkgConfig::LIBXKBCOMMON
        )
    else ()
        set_property(
            TARGET XkbCommon::libxkbcommon PROPERTY INTERFACE_LINK_LIBRARIES ${LIBXKBCOMMON_LIBRARY}
        )
        set_property(
            TARGET XkbCommon::libxkbcommon PROPERTY INTERFACE_INCLUDE_DIRECTORIES
                                                    ${LIBXKBCOMMON_INCLUDE_DIR}
        )
    endif ()
endif ()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    LIBXKBCOMMON REQUIRED_VARS LIBXKBCOMMON_LIBRARY LIBXKBCOMMON_INCLUDE_DIR
)
