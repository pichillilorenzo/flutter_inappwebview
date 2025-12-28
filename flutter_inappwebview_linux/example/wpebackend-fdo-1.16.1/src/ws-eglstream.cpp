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

#include "ws-eglstream.h"

#include "wayland-eglstream-controller-server-protocol.h"
#include <cassert>
#include <epoxy/egl.h>

#ifndef EGL_WL_bind_wayland_display
typedef EGLBoolean (EGLAPIENTRYP PFNEGLBINDWAYLANDDISPLAYWL) (EGLDisplay dpy, struct wl_display *display);
#endif

namespace WS {

static PFNEGLBINDWAYLANDDISPLAYWL s_eglBindWaylandDisplayWL;

static const struct wl_eglstream_controller_interface s_eglstreamControllerInterface = {
    // attach_eglstream_consumer
    [](struct wl_client*, struct wl_resource*, struct wl_resource* surfaceResource, struct wl_resource* bufferResource)
    {
        auto& surface = *static_cast<Surface*>(wl_resource_get_user_data(surfaceResource));

        if (surface.apiClient)
            surface.apiClient->exportEGLStreamProducer(bufferResource);
    },
    // attach_eglstream_consumer_attribs
    [](struct wl_client*, struct wl_resource*, struct wl_resource* surfaceResource, struct wl_resource* bufferResource, struct wl_array* attribs)
    {
        auto& surface = *static_cast<Surface*>(wl_resource_get_user_data(surfaceResource));

        if (surface.apiClient)
            surface.apiClient->exportEGLStreamProducer(bufferResource);
    },
};

ImplEGLStream::ImplEGLStream() = default;

ImplEGLStream::~ImplEGLStream()
{
    if (m_eglstreamController)
        wl_global_destroy(m_eglstreamController);
}

void ImplEGLStream::surfaceAttach(Surface& surface, struct wl_resource* bufferResource)
{
    if (surface.bufferResource)
        wl_buffer_send_release(surface.bufferResource);
    surface.bufferResource = bufferResource;
}

void ImplEGLStream::surfaceCommit(Surface& surface)
{
    if (!surface.apiClient)
        return;

    struct wl_resource* bufferResource = surface.bufferResource;
    surface.bufferResource = nullptr;

    surface.apiClient->exportBufferResource(bufferResource);
}

bool ImplEGLStream::initialize(EGLDisplay eglDisplay)
{
    m_eglstreamController = wl_global_create(display(), &wl_eglstream_controller_interface, 2, this,
        [](struct wl_client* client, void*, uint32_t version, uint32_t id)
        {
            struct wl_resource* resource = wl_resource_create(client, &wl_eglstream_controller_interface, version, id);
            if (!resource) {
                wl_client_post_no_memory(client);
                return;
            }

            wl_resource_set_implementation(resource, &s_eglstreamControllerInterface, nullptr, nullptr);
        });

    s_eglBindWaylandDisplayWL = reinterpret_cast<PFNEGLBINDWAYLANDDISPLAYWL>(eglGetProcAddress("eglBindWaylandDisplayWL"));
    if (!s_eglBindWaylandDisplayWL || !s_eglBindWaylandDisplayWL(eglDisplay, display()))
        return false;

    m_initialized = true;
    return true;
}

} // namespace WS
