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

#include "ws-dmabuf-pool.h"

#include "dmabuf-pool-entry-private.h"
#include "wpe-dmabuf-pool-server-protocol.h"

namespace WS {

ImplDmabufPool::ImplDmabufPool() = default;
ImplDmabufPool::~ImplDmabufPool() = default;

void ImplDmabufPool::surfaceAttach(Surface& surface, struct wl_resource* bufferResource)
{
    if (surface.bufferResource)
        wl_buffer_send_release(surface.bufferResource);
    surface.bufferResource = bufferResource;
}

void ImplDmabufPool::surfaceCommit(Surface& surface)
{
    if (!surface.apiClient)
        return;

    struct wl_resource* bufferResource = surface.bufferResource;
    surface.bufferResource = nullptr;
    if (!bufferResource)
        return;

    auto* entry = static_cast<struct wpe_dmabuf_pool_entry*>(wl_resource_get_user_data(bufferResource));
    surface.apiClient->commitDmabufPoolEntry(entry);
}

struct wpe_dmabuf_pool_entry* ImplDmabufPool::createDmabufPoolEntry(Surface& surface)
{
    if (!surface.apiClient)
        return nullptr;

    return surface.apiClient->createDmabufPoolEntry();
}

bool ImplDmabufPool::initialize()
{
    m_initialized = true;
    return true;
}

} // namespace WS
