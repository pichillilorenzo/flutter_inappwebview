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

#pragma once

#include "ipc.h"
#include "ws.h"

#include <gio/gio.h>
#include <wpe/wpe.h>
#include <vector>

class ViewBackend;

class ClientBundle {
public:
    ClientBundle(void* _data, ViewBackend* _viewBackend, uint32_t _initialWidth, uint32_t _initialHeight)
        : data(_data)
        , viewBackend(_viewBackend)
        , initialWidth(_initialWidth)
        , initialHeight(_initialHeight)
    {
    }

    virtual ~ClientBundle() = default;

    virtual void exportBuffer(struct wl_resource *bufferResource) = 0;
    virtual void exportBuffer(const struct linux_dmabuf_buffer *dmabuf_buffer) = 0;
    virtual void exportBuffer(struct wl_resource* bufferResource, struct wl_shm_buffer* shmBuffer) = 0;
    virtual void exportEGLStreamProducer(struct wl_resource *bufferResource) = 0;

    virtual struct wpe_dmabuf_pool_entry* createDmabufPoolEntry() = 0;
    virtual void commitDmabufPoolEntry(struct wpe_dmabuf_pool_entry*) = 0;

    void* data;
    ViewBackend* viewBackend;
    uint32_t initialWidth;
    uint32_t initialHeight;
};

class ViewBackend final : public WS::APIClient, public FdoIPC::MessageReceiver {
public:
    ViewBackend(ClientBundle* clientBundle, struct wpe_view_backend* backend);
    ~ViewBackend();

    void initialize();
    int clientFd();
    void exportBufferResource(struct wl_resource* bufferResource) override;
    void exportLinuxDmabuf(const struct linux_dmabuf_buffer *dmabuf_buffer) override;
    void exportShmBuffer(struct wl_resource* bufferResource, struct wl_shm_buffer* shmBuffer) override;
    void exportEGLStreamProducer(struct wl_resource*) override;

    struct wpe_dmabuf_pool_entry* createDmabufPoolEntry() override;
    void commitDmabufPoolEntry(struct wpe_dmabuf_pool_entry*) override;

    void bridgeConnectionLost(uint32_t id) override
    {
         unregisterSurface(id);
    }

    void dispatchFrameCallbacks();
    void releaseBuffer(struct wl_resource* buffer_resource);

private:
    void didReceiveMessage(uint32_t messageId, uint32_t messageBody) override;

    void registerSurface(uint32_t);
    void unregisterSurface(uint32_t);

    static gboolean s_socketCallback(GSocket*, GIOCondition, gpointer);

    std::vector<uint32_t> m_bridgeIds;

    ClientBundle* m_clientBundle;
    struct wpe_view_backend* m_backend;

    std::unique_ptr<FdoIPC::Connection> m_socket;
    int m_clientFd { -1 };
};

struct wpe_view_backend_private {
    wpe_view_backend_private(std::unique_ptr<ClientBundle>&& clientBundle, struct wpe_view_backend* backend)
        : clientBundle(std::move(clientBundle))
        , backend(backend)
    {
    }

    ~wpe_view_backend_private()
    {
        wpe_view_backend_destroy(backend);
    }

    std::unique_ptr<ClientBundle> clientBundle;
    struct wpe_view_backend* backend { nullptr };
};

struct wpe_view_backend_exportable_fdo : wpe_view_backend_private {
    wpe_view_backend_exportable_fdo(std::unique_ptr<ClientBundle>&& clientBundle, struct wpe_view_backend* backend)
        : wpe_view_backend_private(std::move(clientBundle), backend)
    {
    }
};

struct wpe_view_backend_dmabuf_pool_fdo : wpe_view_backend_private {
    wpe_view_backend_dmabuf_pool_fdo(std::unique_ptr<ClientBundle>&& clientBundle, struct wpe_view_backend* backend)
        : wpe_view_backend_private(std::move(clientBundle), backend)
    {
    }
};

static struct wpe_view_backend_interface view_backend_private_interface = {
    // create
    [](void* data, struct wpe_view_backend* backend) -> void*
    {
        auto* clientBundle = reinterpret_cast<ClientBundle*>(data);
        return new ViewBackend(clientBundle, backend);
    },
    // destroy
    [](void* data)
    {
        auto* backend = reinterpret_cast<ViewBackend*>(data);
        delete backend;
    },
    // initialize
    [](void* data)
    {
        auto& backend = *reinterpret_cast<ViewBackend*>(data);
        backend.initialize();
    },
    // get_renderer_host_fd
    [](void* data) -> int
    {
        auto& backend = *reinterpret_cast<ViewBackend*>(data);
        return backend.clientFd();
    }
};
