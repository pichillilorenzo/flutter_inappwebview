/*
 * Copyright (C) 2018 Igalia S.L.
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

#include "ipc-messages.h"
#include "view-backend-private.h"
#include <cassert>
#include <sys/types.h>
#include <sys/socket.h>
#include <algorithm>

ViewBackend::ViewBackend(ClientBundle* clientBundle, struct wpe_view_backend* backend)
    : m_clientBundle(clientBundle)
    , m_backend(backend)
{
    m_clientBundle->viewBackend = this;
}

ViewBackend::~ViewBackend()
{
    while (!m_bridgeIds.empty())
        unregisterSurface(m_bridgeIds.front());

    if (m_clientFd != -1)
        close(m_clientFd);
}

void ViewBackend::initialize()
{
    int sockets[2];
    int ret = socketpair(AF_UNIX, SOCK_STREAM | SOCK_CLOEXEC, 0, sockets);
    if (ret == -1)
        return;

    m_socket = FdoIPC::Connection::create(sockets[0], this);
    if (!m_socket) {
        close(sockets[0]);
        close(sockets[1]);
        return;
    }

    m_clientFd = sockets[1];

    wpe_view_backend_dispatch_set_size(m_backend,
                                       m_clientBundle->initialWidth,
                                       m_clientBundle->initialHeight);
}

int ViewBackend::clientFd()
{
    return dup(m_clientFd);
}

void ViewBackend::exportBufferResource(struct wl_resource* bufferResource)
{
    m_clientBundle->exportBuffer(bufferResource);
}

void ViewBackend::exportLinuxDmabuf(const struct linux_dmabuf_buffer *dmabuf_buffer)
{
    m_clientBundle->exportBuffer(dmabuf_buffer);
}

void ViewBackend::exportShmBuffer(struct wl_resource* bufferResource, struct wl_shm_buffer* shmBuffer)
{
    m_clientBundle->exportBuffer(bufferResource, shmBuffer);
}

void ViewBackend::exportEGLStreamProducer(struct wl_resource* bufferResource)
{
    m_clientBundle->exportEGLStreamProducer(bufferResource);
}

struct wpe_dmabuf_pool_entry* ViewBackend::createDmabufPoolEntry()
{
    return m_clientBundle->createDmabufPoolEntry();
}

void ViewBackend::commitDmabufPoolEntry(struct wpe_dmabuf_pool_entry* entry)
{
    m_clientBundle->commitDmabufPoolEntry(entry);
}

void ViewBackend::dispatchFrameCallbacks()
{
    if (G_LIKELY(!m_bridgeIds.empty())) {
        if (WS::Instance::singleton().dispatchFrameCallbacks(m_bridgeIds.back()))
            wpe_view_backend_dispatch_frame_displayed(m_backend);
    }
}

void ViewBackend::releaseBuffer(struct wl_resource* buffer_resource)
{
    wl_buffer_send_release(buffer_resource);
    wl_client_flush(wl_resource_get_client(buffer_resource));
}

void ViewBackend::registerSurface(uint32_t bridgeId)
{
    m_bridgeIds.push_back(bridgeId);
    WS::Instance::singleton().registerViewBackend(m_bridgeIds.back(), *this);
}

void ViewBackend::unregisterSurface(uint32_t bridgeId)
{
    auto it = std::find(m_bridgeIds.begin(), m_bridgeIds.end(), bridgeId);
    if (it == m_bridgeIds.end())
        return;

    m_bridgeIds.erase(it);
    WS::Instance::singleton().unregisterViewBackend(bridgeId);
    // Dispatch frame callbacks in case there's any pending callback from previous bridge.
    if (!m_bridgeIds.empty())
        dispatchFrameCallbacks();
}

void ViewBackend::didReceiveMessage(uint32_t messageId, uint32_t messageBody)
{
    switch (messageId) {
    case FdoIPC::Messages::RegisterSurface:
        registerSurface(messageBody);
        break;
    case FdoIPC::Messages::UnregisterSurface:
        unregisterSurface(messageBody);
        break;
    default:
        assert(!"WPE fdo received an invalid IPC message");
    }
}
