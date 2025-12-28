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
#include "view-backend-private.h"
#include "wpe/unstable/view-backend-dmabuf-pool-fdo.h"

class ClientBundleDmabufPool final : public ClientBundle {
public:
    ClientBundleDmabufPool(const struct wpe_view_backend_dmabuf_pool_fdo_client* _client, void* data, ViewBackend* viewBackend,
                 uint32_t initialWidth, uint32_t initialHeight)
        : ClientBundle(data, viewBackend, initialWidth, initialHeight)
        , client(_client)
    { }

    virtual ~ClientBundleDmabufPool() { }

    void exportBuffer(struct wl_resource *buffer) override { }
    void exportBuffer(const struct linux_dmabuf_buffer *dmabuf_buffer) override { }
    void exportBuffer(struct wl_resource* bufferResource, struct wl_shm_buffer* shmBuffer) override { }
    void exportEGLStreamProducer(struct wl_resource* bufferResource) override { }

    struct wpe_dmabuf_pool_entry* createDmabufPoolEntry() override
    {
        return client->create_entry(data);
    }

    void commitDmabufPoolEntry(struct wpe_dmabuf_pool_entry* entry) override
    {
        client->commit_entry(data, entry);
    }

    void releaseDmabufPoolEntry(struct wpe_dmabuf_pool_entry* entry)
    {
        viewBackend->releaseBuffer(entry->bufferResource);
    }

    const struct wpe_view_backend_dmabuf_pool_fdo_client* client;
};

extern "C" {

__attribute__((visibility("default")))
struct wpe_view_backend_dmabuf_pool_fdo*
wpe_view_backend_dmabuf_pool_fdo_create(const struct wpe_view_backend_dmabuf_pool_fdo_client* client, void* data, uint32_t width, uint32_t height)
{
    auto clientBundle = std::unique_ptr<ClientBundleDmabufPool>(new ClientBundleDmabufPool(client, data, nullptr, width, height));

    struct wpe_view_backend* backend = wpe_view_backend_create_with_backend_interface(&view_backend_private_interface, clientBundle.get());
    return new struct wpe_view_backend_dmabuf_pool_fdo(std::move(clientBundle), backend);
}

__attribute__((visibility("default")))
void
wpe_view_backend_dmabuf_pool_fdo_destroy(struct wpe_view_backend_dmabuf_pool_fdo* exportable)
{
    wpe_view_backend_destroy(exportable->backend);
    delete exportable;
}

__attribute__((visibility("default")))
struct wpe_view_backend*
wpe_view_backend_dmabuf_pool_fdo_get_view_backend(struct wpe_view_backend_dmabuf_pool_fdo* exportable)
{
    return exportable->backend;
}

__attribute__((visibility("default")))
void
wpe_view_backend_dmabuf_pool_fdo_dispatch_frame_complete(struct wpe_view_backend_dmabuf_pool_fdo* exportable)
{
    exportable->clientBundle->viewBackend->dispatchFrameCallbacks();
}

__attribute__((visibility("default")))
void
wpe_view_backend_dmabuf_pool_fdo_dispatch_release_entry(struct wpe_view_backend_dmabuf_pool_fdo* exportable, struct wpe_dmabuf_pool_entry* entry)
{
    reinterpret_cast<ClientBundleDmabufPool*>(exportable->clientBundle.get())->releaseDmabufPoolEntry(entry);
}

} // extern "C"
