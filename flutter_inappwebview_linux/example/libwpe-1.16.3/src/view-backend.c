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

#include "view-backend-private.h"

#include "alloc-private.h"
#include "loader-private.h"
#include <assert.h>
#include <stdlib.h>


struct wpe_view_backend*
wpe_view_backend_create()
{
    struct wpe_view_backend_interface* backend_interface = wpe_load_object("_wpe_view_backend_interface");
    if (!backend_interface)
        return 0;

    return wpe_view_backend_create_with_backend_interface(backend_interface, 0);
}

struct wpe_view_backend*
wpe_view_backend_create_with_backend_interface(struct wpe_view_backend_interface* interface, void* interface_user_data)
{
    struct wpe_view_backend* backend = wpe_calloc(1, sizeof(struct wpe_view_backend));

    backend->base.interface = interface;
    backend->base.interface_data = backend->base.interface->create(interface_user_data, backend);

    return backend;
}

void
wpe_view_backend_destroy(struct wpe_view_backend* backend)
{
    backend->base.interface->destroy(backend->base.interface_data);
    backend->base.interface_data = 0;

    backend->backend_client = 0;
    backend->backend_client_data = 0;

    backend->input_client = 0;
    backend->input_client_data = 0;

    backend->fullscreen_client = NULL;
    backend->fullscreen_client_data = NULL;

    backend->pointer_lock_handler = NULL;
    backend->pointer_lock_handler_data = NULL;

    backend->activity_state = 0;
    backend->refresh_rate = 0;

    wpe_free(backend);
}

static void
wpe_view_backend_notify_activity_state_changed(struct wpe_view_backend* backend)
{
    if (backend->backend_client && backend->backend_client->activity_state_changed)
        backend->backend_client->activity_state_changed(backend->backend_client_data, backend->activity_state);
}

void
wpe_view_backend_set_backend_client(struct wpe_view_backend* backend, const struct wpe_view_backend_client* client, void* client_data)
{
    backend->backend_client = client;
    backend->backend_client_data = client_data;
    if (backend->activity_state)
        wpe_view_backend_notify_activity_state_changed(backend);
}

void
wpe_view_backend_set_input_client(struct wpe_view_backend* backend, const struct wpe_view_backend_input_client* client, void* client_data)
{
    backend->input_client = client;
    backend->input_client_data = client_data;
}

void
wpe_view_backend_set_fullscreen_client(struct wpe_view_backend* backend, const struct wpe_view_backend_fullscreen_client* client, void* client_data)
{
    backend->fullscreen_client = client;
    backend->fullscreen_client_data = client_data;
}

void
wpe_view_backend_initialize(struct wpe_view_backend* backend)
{
    backend->base.interface->initialize(backend->base.interface_data);
}

int
wpe_view_backend_get_renderer_host_fd(struct wpe_view_backend* backend)
{
    return backend->base.interface->get_renderer_host_fd(backend->base.interface_data);
}

void
wpe_view_backend_dispatch_set_size(struct wpe_view_backend* backend, uint32_t width, uint32_t height)
{
    if (backend->backend_client)
        backend->backend_client->set_size(backend->backend_client_data, width, height);
}

void
wpe_view_backend_dispatch_frame_displayed(struct wpe_view_backend* backend)
{
    if (backend->backend_client)
        backend->backend_client->frame_displayed(backend->backend_client_data);
}

void
wpe_view_backend_add_activity_state(struct wpe_view_backend* backend, uint32_t state)
{
    const uint32_t new_state = backend->activity_state | state;
    if (backend->activity_state != new_state) {
        backend->activity_state = new_state;
        wpe_view_backend_notify_activity_state_changed(backend);
    }
}

void
wpe_view_backend_remove_activity_state(struct wpe_view_backend* backend, uint32_t state)
{
    const uint32_t new_state = backend->activity_state & ~state;
    if (backend->activity_state != new_state) {
        backend->activity_state = new_state;
        wpe_view_backend_notify_activity_state_changed(backend);
    }
}

uint32_t
wpe_view_backend_get_activity_state(struct wpe_view_backend* backend)
{
    return backend->activity_state;
}

void*
wpe_view_backend_dispatch_get_accessible(struct wpe_view_backend* backend)
{
    if (backend->backend_client && backend->backend_client->get_accessible)
        return backend->backend_client->get_accessible(backend->backend_client_data);
    return NULL;
}

void
wpe_view_backend_dispatch_set_device_scale_factor(struct wpe_view_backend* backend, float scale)
{
    if (scale < 0.05f || scale > 5.0f) {
        assert(!"Scale factor not in the [0.05, 5.0] range");
        return;
    }

    if (backend->backend_client && backend->backend_client->set_device_scale_factor)
        backend->backend_client->set_device_scale_factor(backend->backend_client_data, scale);
}

void
wpe_view_backend_set_target_refresh_rate(struct wpe_view_backend* backend, uint32_t rate)
{
    if (backend->refresh_rate != rate) {
        backend->refresh_rate = rate;
        if (backend->backend_client && backend->backend_client->target_refresh_rate_changed)
            backend->backend_client->target_refresh_rate_changed(backend->backend_client_data, backend->refresh_rate);
    }
}

uint32_t
wpe_view_backend_get_target_refresh_rate(struct wpe_view_backend* backend)
{
    return backend->refresh_rate;
}

void
wpe_view_backend_dispatch_keyboard_event(struct wpe_view_backend* backend, struct wpe_input_keyboard_event* event)
{
    if (backend->input_client)
        backend->input_client->handle_keyboard_event(backend->input_client_data, event);
}

void
wpe_view_backend_dispatch_pointer_event(struct wpe_view_backend* backend, struct wpe_input_pointer_event* event)
{
    if (backend->input_client)
        backend->input_client->handle_pointer_event(backend->input_client_data, event);
}

void
wpe_view_backend_dispatch_pointer_lock_event(struct wpe_view_backend*             backend,
                                             struct wpe_input_pointer_lock_event* event)
{
    if (backend->input_client)
        backend->input_client->handle_pointer_lock_event(backend->input_client_data, event);
}

void
wpe_view_backend_dispatch_axis_event(struct wpe_view_backend* backend, struct wpe_input_axis_event* event)
{
    if (backend->input_client)
        backend->input_client->handle_axis_event(backend->input_client_data, event);
}

void
wpe_view_backend_dispatch_touch_event(struct wpe_view_backend* backend, struct wpe_input_touch_event* event)
{
    if (backend->input_client)
        backend->input_client->handle_touch_event(backend->input_client_data, event);
}

void
wpe_view_backend_set_fullscreen_handler(struct wpe_view_backend* backend, wpe_view_backend_fullscreen_handler handler, void* userdata)
{
    assert(!backend->fullscreen_handler);

    backend->fullscreen_handler = handler;
    backend->fullscreen_handler_data = userdata;
}

bool
wpe_view_backend_platform_set_fullscreen(struct wpe_view_backend* backend, bool fullscreen)
{
    if (backend->fullscreen_handler)
        return backend->fullscreen_handler(backend->fullscreen_handler_data, fullscreen);
    return false;
}

void
wpe_view_backend_dispatch_did_enter_fullscreen(struct wpe_view_backend* backend)
{
    if (backend->fullscreen_client)
        backend->fullscreen_client->did_enter_fullscreen(backend->fullscreen_client_data);
}

void
wpe_view_backend_dispatch_did_exit_fullscreen(struct wpe_view_backend* backend)
{
    if (backend->fullscreen_client)
        backend->fullscreen_client->did_exit_fullscreen(backend->fullscreen_client_data);
}

void
wpe_view_backend_dispatch_request_enter_fullscreen(struct wpe_view_backend* backend)
{
    if (backend->fullscreen_client)
        backend->fullscreen_client->request_enter_fullscreen(backend->fullscreen_client_data);
}

void
wpe_view_backend_dispatch_request_exit_fullscreen(struct wpe_view_backend* backend)
{
    if (backend->fullscreen_client)
        backend->fullscreen_client->request_exit_fullscreen(backend->fullscreen_client_data);
}

void
wpe_view_backend_set_pointer_lock_handler(struct wpe_view_backend*              backend,
                                          wpe_view_backend_pointer_lock_handler handler,
                                          void*                                 userdata)
{
    assert(!backend->pointer_lock_handler);

    backend->pointer_lock_handler = handler;
    backend->pointer_lock_handler_data = userdata;
}

bool
wpe_view_backend_request_pointer_lock(struct wpe_view_backend* backend)
{
    if (backend->pointer_lock_handler)
        return backend->pointer_lock_handler(backend->pointer_lock_handler_data, true);
    return false;
}

bool
wpe_view_backend_request_pointer_unlock(struct wpe_view_backend* backend)
{
    if (backend->pointer_lock_handler)
        return backend->pointer_lock_handler(backend->pointer_lock_handler_data, false);
    return false;
}
