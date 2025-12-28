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

#if !defined(__WPE_FDO_DMABUF_H_INSIDE__) && !defined(WPE_FDO_COMPILATION)
#error "Only <wpe/unstable/fdo-dmabuf.h> can be included directly."
#endif

#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#include <wpe/wpe.h>

struct wpe_dmabuf_pool_entry;

struct wpe_view_backend_dmabuf_pool_fdo_client {
    struct wpe_dmabuf_pool_entry* (*create_entry)(void*);
    void (*destroy_entry)(void*, struct wpe_dmabuf_pool_entry*);
    void (*commit_entry)(void*, struct wpe_dmabuf_pool_entry*);

    void (*_wpe_reserved0)(void);
    void (*_wpe_reserved1)(void);
    void (*_wpe_reserved2)(void);
    void (*_wpe_reserved3)(void);
};

struct wpe_view_backend_dmabuf_pool_fdo*
wpe_view_backend_dmabuf_pool_fdo_create(const struct wpe_view_backend_dmabuf_pool_fdo_client*, void*, uint32_t width, uint32_t height);

void
wpe_view_backend_dmabuf_pool_fdo_destroy(struct wpe_view_backend_dmabuf_pool_fdo*);

struct wpe_view_backend*
wpe_view_backend_dmabuf_pool_fdo_get_view_backend(struct wpe_view_backend_dmabuf_pool_fdo*);

void
wpe_view_backend_dmabuf_pool_fdo_dispatch_frame_complete(struct wpe_view_backend_dmabuf_pool_fdo*);

void
wpe_view_backend_dmabuf_pool_fdo_dispatch_release_entry(struct wpe_view_backend_dmabuf_pool_fdo*, struct wpe_dmabuf_pool_entry*);

#ifdef __cplusplus
}
#endif
