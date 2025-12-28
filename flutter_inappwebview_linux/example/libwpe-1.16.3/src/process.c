/*
 * Copyright (C) 2022 Sony Interactive Entertainment Inc.
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

#include "../include/wpe/process.h"
#include <stdlib.h>

struct wpe_process_provider {
    void* backend;
};

static const struct wpe_process_provider_interface* provider_interface = NULL;

struct wpe_process_provider*
wpe_process_provider_create()
{
    if (!provider_interface)
        return NULL;

    struct wpe_process_provider* provider = calloc(1, sizeof(struct wpe_process_provider));
    if (!provider)
        return NULL;

    if (provider_interface->create)
        provider->backend = provider_interface->create(provider);

    return provider;
}

void
wpe_process_provider_destroy(struct wpe_process_provider* provider)
{
    if (!provider)
        return;

    if (provider_interface && provider_interface->destroy)
        provider_interface->destroy(provider);
    provider->backend = NULL;
    free(provider);
}

int64_t
wpe_process_launch(struct wpe_process_provider* provider, enum wpe_process_type type, void* userdata)
{
    if (provider && provider_interface && provider_interface->launch)
        return provider_interface->launch(provider->backend, type, userdata);
    return -1;
}

void
wpe_process_terminate(struct wpe_process_provider* provider, int64_t process)
{
    if (provider && provider_interface && provider_interface->terminate)
        provider_interface->terminate(provider->backend, process);
}

void
wpe_process_provider_register_interface(const struct wpe_process_provider_interface* iface)
{
    if (iface && !provider_interface)
        provider_interface = iface;
}
