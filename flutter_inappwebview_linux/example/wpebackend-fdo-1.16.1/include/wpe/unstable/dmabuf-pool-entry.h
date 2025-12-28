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

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

struct wpe_dmabuf_pool_entry;

struct wpe_dmabuf_pool_entry_init {
    uint32_t width;
    uint32_t height;
    uint32_t format;

    unsigned num_planes;
    int fds[4];
    uint32_t strides[4];
    uint32_t offsets[4];
    uint64_t modifiers[4];
};

struct wpe_dmabuf_pool_entry*
wpe_dmabuf_pool_entry_create(const struct wpe_dmabuf_pool_entry_init*);

void
wpe_dmabuf_pool_entry_destroy(struct wpe_dmabuf_pool_entry*);

void
wpe_dmabuf_pool_entry_set_user_data(struct wpe_dmabuf_pool_entry*, void*);

void*
wpe_dmabuf_pool_entry_get_user_data(struct wpe_dmabuf_pool_entry*);

#ifdef __cplusplus
}
#endif
