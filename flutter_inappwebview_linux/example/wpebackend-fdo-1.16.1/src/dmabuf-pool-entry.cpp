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

#include "dmabuf-pool-entry-private.h"

extern "C" {

__attribute__((visibility("default")))
struct wpe_dmabuf_pool_entry*
wpe_dmabuf_pool_entry_create(const struct wpe_dmabuf_pool_entry_init* entry_init)
{
    auto* entry = new struct wpe_dmabuf_pool_entry;
    entry->data = nullptr;

    entry->width = entry_init->width;
    entry->height = entry_init->height;
    entry->format = entry_init->format;

    entry->num_planes = entry_init->num_planes;
    for (unsigned i = 0; i < entry->num_planes; ++i) {
        entry->fds[i] = entry_init->fds[i];
        entry->strides[i] = entry_init->strides[i];
        entry->offsets[i] = entry_init->offsets[i];
        entry->modifiers[i] = entry_init->modifiers[i];
    }

    return entry;
}

__attribute__((visibility("default")))
void
wpe_dmabuf_pool_entry_destroy(struct wpe_dmabuf_pool_entry* entry)
{
    delete entry;
}

__attribute__((visibility("default")))
void
wpe_dmabuf_pool_entry_set_user_data(struct wpe_dmabuf_pool_entry* entry, void* data)
{
    entry->data = data;
}

__attribute__((visibility("default")))
void*
wpe_dmabuf_pool_entry_get_user_data(struct wpe_dmabuf_pool_entry* entry)
{
    return entry->data;
}

} // extern "C"
