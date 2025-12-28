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

#include "../include/wpe/view-backend-exportable.h"
#include "exported-buffer-shm-private.h"
#include "linux-dmabuf/linux-dmabuf.h"
#include "view-backend-private.h"
#include "ws.h"
#include <cassert>
#include <cstring>

namespace {

class ClientBundleBuffer final : public ClientBundle {
public:
    struct BufferResource {
        struct wl_resource* resource;

        struct wl_list link;
        struct wl_listener destroyListener;

        static void destroyNotify(struct wl_listener*, void*);
    };

    ClientBundleBuffer(const struct wpe_view_backend_exportable_fdo_client* _client, void* data, ViewBackend* viewBackend,
                 uint32_t initialWidth, uint32_t initialHeight)
        : ClientBundle(data, viewBackend, initialWidth, initialHeight)
        , client(_client)
    {
        wl_list_init(&bufferResources);
    }

    virtual ~ClientBundleBuffer()
    {
        BufferResource* resource;
        BufferResource* next;
        wl_list_for_each_safe(resource, next, &bufferResources, link) {
            viewBackend->releaseBuffer(resource->resource);

            wl_list_remove(&resource->link);
            wl_list_remove(&resource->destroyListener.link);
            delete resource;
        }
        wl_list_init(&bufferResources);
    }

    void exportBuffer(struct wl_resource *buffer) override
    {
        auto* resource = new BufferResource;
        resource->resource = buffer;
        resource->destroyListener.notify = BufferResource::destroyNotify;

        wl_resource_add_destroy_listener(buffer, &resource->destroyListener);
        wl_list_insert(&bufferResources, &resource->link);

        client->export_buffer_resource(data, buffer);
    }

    void exportBuffer(const struct linux_dmabuf_buffer *dmabuf_buffer) override
    {
        auto* attributes = &dmabuf_buffer->attributes;

        struct wpe_view_backend_exportable_fdo_dmabuf_resource dmabuf_resource;
        std::memset(&dmabuf_resource, 0, sizeof(struct wpe_view_backend_exportable_fdo_dmabuf_resource));
        dmabuf_resource.buffer_resource = dmabuf_buffer->buffer_resource;
        dmabuf_resource.width = attributes->width;
        dmabuf_resource.height = attributes->height;
        dmabuf_resource.format = attributes->format;

        if (attributes->n_planes >= 0)
            dmabuf_resource.n_planes = attributes->n_planes;
        for (uint8_t i = 0; i < dmabuf_resource.n_planes; ++i) {
            dmabuf_resource.fds[i] = attributes->fd[i];
            dmabuf_resource.strides[i] = attributes->stride[i];
            dmabuf_resource.offsets[i] = attributes->offset[i];
            dmabuf_resource.modifiers[i] = attributes->modifier[i];
        }

        auto* resource = new BufferResource;
        resource->resource = dmabuf_buffer->buffer_resource;
        resource->destroyListener.notify = BufferResource::destroyNotify;

        wl_resource_add_destroy_listener(dmabuf_buffer->buffer_resource, &resource->destroyListener);
        wl_list_insert(&bufferResources, &resource->link);

        client->export_dmabuf_resource(data, &dmabuf_resource);
    }

    void exportBuffer(struct wl_resource* bufferResource, struct wl_shm_buffer* shmBuffer) override
    {
        auto* buffer = new struct wpe_fdo_shm_exported_buffer;
        buffer->resource = bufferResource;
        buffer->shm_buffer = shmBuffer;
        client->export_shm_buffer(data, buffer);
    }

    void exportEGLStreamProducer(struct wl_resource* bufferResource) override
    {
        assert(!"should not be reached");
    }

    struct wpe_dmabuf_pool_entry* createDmabufPoolEntry() override
    {
        assert(!"should not be reached");
        return nullptr;
    }

    void commitDmabufPoolEntry(struct wpe_dmabuf_pool_entry*) override
    {
        assert(!"should not be reached");
    }

    void releaseBuffer(struct wl_resource* buffer)
    {
        BufferResource* matchingResource = nullptr;
        BufferResource* resource;
        wl_list_for_each(resource, &bufferResources, link) {
            if (resource->resource == buffer) {
                matchingResource = resource;
                break;
            }
        }

        if (!matchingResource)
            return;

        viewBackend->releaseBuffer(buffer);

        wl_list_remove(&matchingResource->link);
        wl_list_remove(&matchingResource->destroyListener.link);
        delete matchingResource;
    }

    void releaseBuffer(struct wpe_fdo_shm_exported_buffer* buffer)
    {
        if (buffer->resource)
            viewBackend->releaseBuffer(buffer->resource);
        delete buffer;
    }

    const struct wpe_view_backend_exportable_fdo_client* client;

    struct wl_list bufferResources;
};

void ClientBundleBuffer::BufferResource::destroyNotify(struct wl_listener* listener, void*)
{
    BufferResource* resource;
    resource = wl_container_of(listener, resource, destroyListener);

    wl_list_remove(&resource->link);
    delete resource;
}

} // namespace

extern "C" {

__attribute__((visibility("default")))
struct wpe_view_backend_exportable_fdo*
wpe_view_backend_exportable_fdo_create(const struct wpe_view_backend_exportable_fdo_client* client, void* data, uint32_t width, uint32_t height)
{
    auto clientBundle = std::unique_ptr<ClientBundleBuffer>(new ClientBundleBuffer(client, data, nullptr, width, height));

    struct wpe_view_backend* backend = wpe_view_backend_create_with_backend_interface(&view_backend_private_interface, clientBundle.get());

    return new struct wpe_view_backend_exportable_fdo(std::move(clientBundle), backend);
}

__attribute__((visibility("default")))
void
wpe_view_backend_exportable_fdo_destroy(struct wpe_view_backend_exportable_fdo* exportable)
{
    delete exportable;
}

__attribute__((visibility("default")))
struct wpe_view_backend*
wpe_view_backend_exportable_fdo_get_view_backend(struct wpe_view_backend_exportable_fdo* exportable)
{
    return exportable->backend;
}

__attribute__((visibility("default")))
void
wpe_view_backend_exportable_fdo_dispatch_frame_complete(struct wpe_view_backend_exportable_fdo* exportable)
{
    exportable->clientBundle->viewBackend->dispatchFrameCallbacks();
}

__attribute__((visibility("default")))
void
wpe_view_backend_exportable_fdo_dispatch_release_buffer(struct wpe_view_backend_exportable_fdo* exportable, struct wl_resource* buffer)
{
    static_cast<ClientBundleBuffer*>(exportable->clientBundle.get())->releaseBuffer(buffer);
}

__attribute__((visibility("default")))
void
wpe_view_backend_exportable_fdo_dispatch_release_shm_exported_buffer(struct wpe_view_backend_exportable_fdo* exportable, struct wpe_fdo_shm_exported_buffer* buffer)
{
    static_cast<ClientBundleBuffer*>(exportable->clientBundle.get())->releaseBuffer(buffer);
}

}
