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


#include "../include/wpe/unstable/view-backend-exportable-eglstream.h"
#include "view-backend-private.h"
#include <cassert>

namespace {

class ClientBundleEGLStream final : public ClientBundle {
public:
    ClientBundleEGLStream(const struct wpe_view_backend_exportable_fdo_eglstream_client* client,
        void* data, ViewBackend* viewBackend, uint32_t width, uint32_t height)
        : ClientBundle(data, viewBackend, width, height)
        , client(client)
    {
    }

    virtual ~ClientBundleEGLStream() = default;

    void exportBuffer(struct wl_resource *buffer) override
    {
        // The Wayland integration with EGLStream in NVIDIA drivers is a bit strange.
        // For each swap call, the client will first attach the frame's output buffer
        // and commit that state before doing a round-trip through the EGLStream
        // consumer, after which another commit on the surface is done. We wait for
        // this second commit, detecting it based on the buffer resource being null
        // here (since the first received commit cleared out the buffer resource in
        // ImplEGLStream::surfaceCommit().
        if (!!buffer)
            return;

        client->notify_eglstream_frame(data);
    }

    void exportBuffer(const struct linux_dmabuf_buffer *dmabuf_buffer) override
    {
        assert(!"should not be reached");
    }

    void exportBuffer(struct wl_resource* bufferResource, struct wl_shm_buffer* shmBuffer) override
    {
        assert(!"should not be reached");
    }

    void exportEGLStreamProducer(struct wl_resource* bufferResource) override
    {
        client->export_eglstream_producer_resource(data, bufferResource);
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

    const struct wpe_view_backend_exportable_fdo_eglstream_client* client;
};

} // namespace

extern "C" {

__attribute__((visibility("default")))
struct wpe_view_backend_exportable_fdo*
wpe_view_backend_exportable_fdo_eglstream_create(const struct wpe_view_backend_exportable_fdo_eglstream_client* client, void* data, uint32_t width, uint32_t height)
{
    auto clientBundle = std::unique_ptr<ClientBundleEGLStream>(new ClientBundleEGLStream(client, data, nullptr, width, height));
    struct wpe_view_backend* backend = wpe_view_backend_create_with_backend_interface(&view_backend_private_interface, clientBundle.get());

    return new struct wpe_view_backend_exportable_fdo(std::move(clientBundle), backend);
}

}
