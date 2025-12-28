/*
 * Copyright (C) 2015, 2016, 2022 Igalia S.L.
 * All rights reserved.
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

#include "../include/wpe/renderer-backend-egl.h"

#include "alloc-private.h"
#include "loader-private.h"
#include "renderer-backend-egl-private.h"

struct wpe_renderer_backend_egl*
wpe_renderer_backend_egl_create(int host_fd)
{
    struct wpe_renderer_backend_egl* backend = wpe_calloc(1, sizeof(struct wpe_renderer_backend_egl));

    backend->base.interface = wpe_load_object("_wpe_renderer_backend_egl_interface");
    if (!backend->base.interface) {
        wpe_free(backend);
        return 0;
    }

    backend->base.interface_data = backend->base.interface->create(host_fd);

    return backend;
}

void
wpe_renderer_backend_egl_destroy(struct wpe_renderer_backend_egl* backend)
{
    backend->base.interface->destroy(backend->base.interface_data);
    backend->base.interface_data = 0;

    wpe_free(backend);
}

EGLNativeDisplayType
wpe_renderer_backend_egl_get_native_display(struct wpe_renderer_backend_egl* backend)
{
    return backend->base.interface->get_native_display(backend->base.interface_data);
}

uint32_t
wpe_renderer_backend_egl_get_platform(struct wpe_renderer_backend_egl* backend)
{
    if (backend->base.interface->get_platform)
        return backend->base.interface->get_platform(backend->base.interface_data);
    return 0;
}

struct wpe_renderer_backend_egl_target*
wpe_renderer_backend_egl_target_create(int host_fd)
{
    struct wpe_renderer_backend_egl_target* target = wpe_calloc(1, sizeof(struct wpe_renderer_backend_egl_target));

    target->base.interface = wpe_load_object("_wpe_renderer_backend_egl_target_interface");
    if (!target->base.interface) {
        wpe_free(target);
        return 0;
    }

    target->base.interface_data = target->base.interface->create(target, host_fd);

    return target;
}

void
wpe_renderer_backend_egl_target_destroy(struct wpe_renderer_backend_egl_target* target)
{
    target->base.interface->destroy(target->base.interface_data);
    target->base.interface_data = 0;

    target->client = 0;
    target->client_data = 0;

    wpe_free(target);
}

void
wpe_renderer_backend_egl_target_set_client(struct wpe_renderer_backend_egl_target* target, const struct wpe_renderer_backend_egl_target_client* client, void* client_data)
{
    target->client = client;
    target->client_data = client_data;
}

void
wpe_renderer_backend_egl_target_initialize(struct wpe_renderer_backend_egl_target* target, struct wpe_renderer_backend_egl* backend, uint32_t width, uint32_t height)
{
    target->base.interface->initialize(target->base.interface_data, backend->base.interface_data, width, height);
}

EGLNativeWindowType
wpe_renderer_backend_egl_target_get_native_window(struct wpe_renderer_backend_egl_target* target)
{
    return target->base.interface->get_native_window(target->base.interface_data);
}

void
wpe_renderer_backend_egl_target_resize(struct wpe_renderer_backend_egl_target* target, uint32_t width, uint32_t height)
{
    target->base.interface->resize(target->base.interface_data, width, height);
}

void
wpe_renderer_backend_egl_target_frame_will_render(struct wpe_renderer_backend_egl_target* target)
{
    target->base.interface->frame_will_render(target->base.interface_data);
}

void
wpe_renderer_backend_egl_target_frame_rendered(struct wpe_renderer_backend_egl_target* target)
{
    target->base.interface->frame_rendered(target->base.interface_data);
}

void
wpe_renderer_backend_egl_target_deinitialize(struct wpe_renderer_backend_egl_target* target)
{
    if (target->base.interface->deinitialize)
        target->base.interface->deinitialize(target->base.interface_data);
}

struct wpe_renderer_backend_egl_offscreen_target*
wpe_renderer_backend_egl_offscreen_target_create()
{
    struct wpe_renderer_backend_egl_offscreen_target* target =
        wpe_calloc(1, sizeof(struct wpe_renderer_backend_egl_offscreen_target));

    target->base.interface = wpe_load_object("_wpe_renderer_backend_egl_offscreen_target_interface");
    if (!target->base.interface) {
        wpe_free(target);
        return 0;
    }

    target->base.interface_data = target->base.interface->create();

    return target;
}

void
wpe_renderer_backend_egl_offscreen_target_destroy(struct wpe_renderer_backend_egl_offscreen_target* target)
{
    target->base.interface->destroy(target->base.interface_data);
    target->base.interface_data = 0;

    wpe_free(target);
}

void
wpe_renderer_backend_egl_offscreen_target_initialize(struct wpe_renderer_backend_egl_offscreen_target* target, struct wpe_renderer_backend_egl* backend)
{
    target->base.interface->initialize(target->base.interface_data, backend->base.interface_data);
}

EGLNativeWindowType
wpe_renderer_backend_egl_offscreen_target_get_native_window(struct wpe_renderer_backend_egl_offscreen_target* target)
{
    return target->base.interface->get_native_window(target->base.interface_data);
}

void
wpe_renderer_backend_egl_target_dispatch_frame_complete(struct wpe_renderer_backend_egl_target* target)
{
    if (target->client)
        target->client->frame_complete(target->client_data);
}
