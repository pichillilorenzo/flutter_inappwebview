/*
 * Copyright (C) 2015, 2016 Igalia S.L.
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

#ifndef wpe_view_backend_private_h
#define wpe_view_backend_private_h

#include "../include/wpe/view-backend.h"

#ifdef __cplusplus
extern "C" {
#endif

struct wpe_view_backend {
    struct wpe_view_backend_base base;

    const struct wpe_view_backend_client* backend_client;
    void* backend_client_data;

    const struct wpe_view_backend_input_client* input_client;
    void* input_client_data;

    const struct wpe_view_backend_fullscreen_client* fullscreen_client;
    void* fullscreen_client_data;

    wpe_view_backend_fullscreen_handler fullscreen_handler;
    void* fullscreen_handler_data;

    wpe_view_backend_pointer_lock_handler pointer_lock_handler;
    void*                                 pointer_lock_handler_data;

    uint32_t activity_state;
    uint32_t refresh_rate;
};

#ifdef __cplusplus
}
#endif

#endif // wpe_view_backend_private_h
