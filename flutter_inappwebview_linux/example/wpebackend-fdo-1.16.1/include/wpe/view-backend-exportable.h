/*
 * Copyright (C) 2017, 2018 Igalia S.L.
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

#ifndef __view_backend_exportable_h__
#define __view_backend_exportable_h__

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

struct wl_resource;

struct wpe_fdo_shm_exported_buffer;
struct wpe_view_backend_exportable_fdo;

struct wpe_view_backend_exportable_fdo_dmabuf_resource {
    struct wl_resource* buffer_resource;
    uint32_t width;
    uint32_t height;
    uint32_t format;
    uint8_t n_planes;
    int fds[4];
    uint32_t strides[4];
    uint32_t offsets[4];
    uint64_t modifiers[4];
};

struct wpe_view_backend_exportable_fdo_client {
    void (*export_buffer_resource)(void* data, struct wl_resource* buffer_resource);
    void (*export_dmabuf_resource)(void* data, struct wpe_view_backend_exportable_fdo_dmabuf_resource* dmabuf_resource);
    void (*export_shm_buffer)(void* data, struct wpe_fdo_shm_exported_buffer*);
    void (*_wpe_reserved0)(void);
    void (*_wpe_reserved1)(void);
};

struct wpe_view_backend_exportable_fdo*
wpe_view_backend_exportable_fdo_create(const struct wpe_view_backend_exportable_fdo_client*, void*, uint32_t width, uint32_t height);

void
wpe_view_backend_exportable_fdo_destroy(struct wpe_view_backend_exportable_fdo*);

struct wpe_view_backend*
wpe_view_backend_exportable_fdo_get_view_backend(struct wpe_view_backend_exportable_fdo*);

void
wpe_view_backend_exportable_fdo_dispatch_frame_complete(struct wpe_view_backend_exportable_fdo*);

void
wpe_view_backend_exportable_fdo_dispatch_release_buffer(struct wpe_view_backend_exportable_fdo*, struct wl_resource*);

void
wpe_view_backend_exportable_fdo_dispatch_release_shm_exported_buffer(struct wpe_view_backend_exportable_fdo*, struct wpe_fdo_shm_exported_buffer*);

#ifdef __cplusplus
}
#endif

#endif /* __view_backend_exportable_h___ */
