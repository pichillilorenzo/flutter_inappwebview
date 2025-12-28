/*
 * Copyright (C) 2020 Igalia S.L.
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

#if !defined(__WPE_FDO_EGLSTREAM_H_INSIDE__) && !defined(WPE_FDO_COMPILATION)
#error "Only <wpe/unstable/fdo-eglstream.h> can be included directly."
#endif

#ifndef __view_backend_exportable_eglstream_h__
#define __view_backend_exportable_eglstream_h__

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

struct wl_resource;
struct wpe_view_backend_exportable_fdo;

struct wpe_view_backend_exportable_fdo_eglstream_client {
    void (*export_eglstream_producer_resource)(void* data, struct wl_resource* buffer_resource);
    void (*notify_eglstream_frame)(void* data);
    void (*_wpe_reserved0)(void);
    void (*_wpe_reserved1)(void);
    void (*_wpe_reserved2)(void);
};

struct wpe_view_backend_exportable_fdo*
wpe_view_backend_exportable_fdo_eglstream_create(const struct wpe_view_backend_exportable_fdo_eglstream_client*, void*, uint32_t width, uint32_t height);

#ifdef __cplusplus
}
#endif

#endif /* __view_backend_exportable_egl_h___ */
