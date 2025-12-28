/*
 * If not stated otherwise in this file or this component's Licenses.txt file the
 * following copyright and licenses apply:
 *
 * Copyright 2020 RDK Management
 * Copyright 2022 Igalia, S.L.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "../include/wpe/gamepad.h"

#include "alloc-private.h"
#include <stdint.h>

struct wpe_gamepad_provider {
    void*                                               backend;
    const struct wpe_gamepad_provider_client_interface* client_interface;
    void*                                               client_data;
};

struct wpe_gamepad {
    void*                                      backend;
    const struct wpe_gamepad_client_interface* client_interface;
    void*                                      client_data;
};

static const struct wpe_gamepad_provider_interface* provider_interface = NULL;
static const struct wpe_gamepad_interface*          gamepad_interface = NULL;

struct wpe_gamepad_provider*
wpe_gamepad_provider_create(void)
{
    if (!provider_interface)
        return NULL;

    struct wpe_gamepad_provider* provider = wpe_calloc(1, sizeof(struct wpe_gamepad_provider));
    if (provider_interface->create)
        provider->backend = provider_interface->create(provider);
    return provider;
}

void
wpe_gamepad_provider_destroy(struct wpe_gamepad_provider* provider)
{
    if (!provider)
        return;

    if (provider_interface && provider_interface->destroy)
        provider_interface->destroy(provider->backend);
    provider->backend = NULL;
    wpe_free(provider);
}

void
wpe_gamepad_provider_set_client(struct wpe_gamepad_provider*                        provider,
                                const struct wpe_gamepad_provider_client_interface* client_interface,
                                void*                                               client_data)
{
    if (!provider)
        return;

    provider->client_interface = client_interface;
    provider->client_data = client_data;
}

void
wpe_gamepad_provider_start(struct wpe_gamepad_provider* provider)
{
    if (provider && provider_interface && provider_interface->start)
        provider_interface->start(provider->backend);
}

void
wpe_gamepad_provider_stop(struct wpe_gamepad_provider* provider)
{
    if (provider && provider_interface && provider_interface->stop)
        provider_interface->stop(provider->backend);
}

void*
wpe_gamepad_provider_get_backend(struct wpe_gamepad_provider* provider)
{
    if (provider)
        return provider->backend;
    return NULL;
}

struct wpe_view_backend*
wpe_gamepad_provider_get_view_backend(struct wpe_gamepad_provider* provider, struct wpe_gamepad* gamepad)
{
    if (provider && provider_interface && provider_interface->get_view_backend && gamepad)
        return provider_interface->get_view_backend(provider->backend, gamepad->backend);
    return NULL;
}

void
wpe_gamepad_provider_dispatch_gamepad_connected(struct wpe_gamepad_provider* provider, uintptr_t gamepad_id)
{
    if (provider && provider->client_interface && provider->client_interface->connected)
        provider->client_interface->connected(provider->client_data, gamepad_id);
}

void
wpe_gamepad_provider_dispatch_gamepad_disconnected(struct wpe_gamepad_provider* provider, uintptr_t gamepad_id)
{
    if (provider && provider->client_interface && provider->client_interface->disconnected)
        provider->client_interface->disconnected(provider->client_data, gamepad_id);
}

struct wpe_gamepad*
wpe_gamepad_create(struct wpe_gamepad_provider* provider, uintptr_t gamepad_id)
{
    if (!gamepad_interface)
        return NULL;

    struct wpe_gamepad* gamepad = wpe_calloc(1, sizeof(struct wpe_gamepad));
    if (gamepad_interface->create)
        gamepad->backend = gamepad_interface->create(gamepad, provider, gamepad_id);
    return gamepad;
}

void
wpe_gamepad_destroy(struct wpe_gamepad* gamepad)
{
    if (!gamepad)
        return;

    if (gamepad_interface && gamepad_interface->destroy)
        gamepad_interface->destroy(gamepad->backend);
    gamepad->backend = NULL;
    wpe_free(gamepad);
}

void
wpe_gamepad_set_client(struct wpe_gamepad*                        gamepad,
                       const struct wpe_gamepad_client_interface* client_interface,
                       void*                                      client_data)
{
    if (gamepad) {
        gamepad->client_interface = client_interface;
        gamepad->client_data = client_data;
    }
}

const char*
wpe_gamepad_get_id(struct wpe_gamepad* gamepad)
{
    if (gamepad && gamepad_interface && gamepad_interface->get_id)
        return gamepad_interface->get_id(gamepad->backend);
    return "Unknown device";
}

void
wpe_gamepad_dispatch_analog_button_changed(struct wpe_gamepad* gamepad, enum wpe_gamepad_button button, double value)
{
    if (gamepad && gamepad->client_interface && gamepad->client_interface->analog_button_changed)
        gamepad->client_interface->analog_button_changed(gamepad->client_data, button, value);
}

void
wpe_gamepad_dispatch_button_changed(struct wpe_gamepad* gamepad, enum wpe_gamepad_button button, bool pressed)
{
    if (gamepad && gamepad->client_interface && gamepad->client_interface->button_changed)
        gamepad->client_interface->button_changed(gamepad->client_data, button, pressed);
}

void
wpe_gamepad_dispatch_axis_changed(struct wpe_gamepad* gamepad, enum wpe_gamepad_axis axis, double value)
{
    if (gamepad && gamepad->client_interface && gamepad->client_interface->axis_changed)
        gamepad->client_interface->axis_changed(gamepad->client_data, axis, value);
}

void
wpe_gamepad_set_handler(const struct wpe_gamepad_provider_interface* provider_iface,
                        const struct wpe_gamepad_interface*          gamepad_iface)
{
    if (provider_iface && !provider_interface && gamepad_iface && !gamepad_interface) {
        provider_interface = provider_iface;
        gamepad_interface = gamepad_iface;
    }
}
