/*
 * Copyright (C) 2019 Igalia S.L.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 * PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#if !defined(__WPE_FDO_H_INSIDE__) && !defined(WPE_FDO_COMPILATION)
#error "Only <wpe/fdo.h> can be included directly."
#endif

#ifndef __wpe_fdo_version_h__
#define __wpe_fdo_version_h__

#include "wpebackend-fdo-version.h"

/**
 * WPE_FDO_MAJOR_VERSION:
 *
 * Major version of the headers being used at compilation time.
 */

/**
 * WPE_FDO_MINOR_VERSION:
 *
 * Minor version of the headers being used at compilation time.
 */

/**
 * WPE_FDO_MICRO_VERSION:
 *
 * Micro version of the headers being used at compilation time.
 */

/**
 * WPE_FDO_CHECK_VERSION:
 *
 * @param major: major version number (e.g. `1` for version `1.2.5`)
 * @param minor: minor version number (e.g. `2` for version `1.2.5`)
 * @param micro: micro version number (e.g. `5` for version `1.2.5`)
 *
 * Returns: Whether the version of the WPEBackend-fdo header files is the same
 *     as or newer than the version passed.
 */
#define WPE_FDO_CHECK_VERSION(major, minor, micro) \
    (WPE_FDO_MAJOR_VERSION > (major) || \
    (WPE_FDO_MAJOR_VERSION == (major) && WPE_FDO_MINOR_VERSION > (minor)) || \
    (WPE_FDO_MAJOR_VERSION == (major) && WPE_FDO_MINOR_VERSION == (minor) && \
     WPE_FDO_MICRO_VERSION >= (micro)))

#ifdef __cplusplus
extern "C" {
#endif

/**
 * wpe_fdo_get_major_version:
 *
 * Returns: Major version of the `WPEBackend-fdo` library.
 */
unsigned wpe_fdo_get_major_version(void);

/**
 * wpe_fdo_get_minor_version:
 *
 * Returns: Minor version of the `WPEBackend-fdo` library.
 */
unsigned wpe_fdo_get_minor_version(void);

/**
 * wpe_fdo_get_micro_version:
 *
 * Returns: Micro version of the `WPEBackend-fdo` library.
 */
unsigned wpe_fdo_get_micro_version(void);

#ifdef __cplusplus
}
#endif

#endif /* __wpe_fdo_version_h__ */
