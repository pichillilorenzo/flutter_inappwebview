/*
 * Copyright (C) 2018 Igalia S.L.
 * All rights reserved.
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

#if !defined(__WPE_H_INSIDE__) && !defined(WPE_COMPILATION)
#error "Only <wpe/wpe.h> can be included directly."
#endif

#ifndef wpe_version_deprecated_h
#define wpe_version_deprecated_h

#if defined(WPE_COMPILATION)
#include "export.h"
#endif

#include "libwpe-version.h"

#ifdef __cplusplus
extern "C" {
#endif

#define WPE_BACKEND_MAJOR_VERSION WPE_MAJOR_VERSION
#define WPE_BACKEND_MINOR_VERSION WPE_MINOR_VERSION
#define WPE_BACKEND_MICRO_VERSION WPE_MICRO_VERSION

#define WPE_BACKEND_CHECK_VERSION(major, minor, micro) \
    (WPE_BACKEND_MAJOR_VERSION > (major) || \
    (WPE_BACKEND_MAJOR_VERSION == (major) && WPE_BACKEND_MINOR_VERSION > (minor)) || \
    (WPE_BACKEND_MAJOR_VERSION == (major) && WPE_BACKEND_MINOR_VERSION == (minor) && \
     WPE_BACKEND_MICRO_VERSION >= (micro)))

/**
 * wpe_backend_get_major_version:
 *
 * Returns: Major version of the `libwpe` library.
 *
 * Deprecated: Since `libwpe` version 1.0.0, use wpe_get_major_version()
 *     instead.
 */
WPE_EXPORT unsigned wpe_backend_get_major_version(void);

/**
 * wpe_backend_get_minor_version:
 *
 * Returns: Minor version of the `libwpe` library.
 *
 * Deprecated: Since `libwpe` version 1.0.0, use wpe_get_minor_version()
 *     instead.
 */
WPE_EXPORT unsigned wpe_backend_get_minor_version(void);

/**
 * wpe_backend_get_micro_version:
 *
 * Returns: Micro version of the `libwpe` library.
 *
 * Deprecated: Since `libwpe` version 1.0.0, use wpe_get_micro_version()
 *     instead.
 */
WPE_EXPORT unsigned wpe_backend_get_micro_version(void);

#ifdef __cplusplus
}
#endif

#endif /* wpe_version_deprecated_h */
