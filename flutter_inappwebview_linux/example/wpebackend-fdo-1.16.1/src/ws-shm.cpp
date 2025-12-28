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

#include "ws-shm.h"

namespace WS {

ImplSHM::ImplSHM() = default;
ImplSHM::~ImplSHM() = default;

void ImplSHM::surfaceAttach(Surface& surface, struct wl_resource* bufferResource)
{
    surface.shmBuffer = wl_shm_buffer_get(bufferResource);

    if (surface.bufferResource)
        wl_buffer_send_release(surface.bufferResource);
    surface.bufferResource = bufferResource;
}

void ImplSHM::surfaceCommit(Surface& surface)
{
    if (!surface.apiClient)
        return;

    struct wl_resource* bufferResource = surface.bufferResource;
    surface.bufferResource = nullptr;

    if (surface.shmBuffer)
        surface.apiClient->exportShmBuffer(bufferResource, surface.shmBuffer);
    else
        surface.apiClient->exportBufferResource(bufferResource);
}

bool ImplSHM::initialize()
{
    // wl_display_init_shm() returns `0` on success.
    if (wl_display_init_shm(display()) != 0)
        return false;

    m_initialized = true;
    return true;
}

} // namespace WS
