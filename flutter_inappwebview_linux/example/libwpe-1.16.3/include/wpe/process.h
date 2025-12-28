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

#if !defined(__WPE_H_INSIDE__) && !defined(WPE_COMPILATION)
#error "Only <wpe/wpe.h> can be included directly."
#endif

#ifndef wpe_process_h
#define wpe_process_h

/**
 * SECTION:process
 * @short_description: Process management
 * @title: Process
 */

#if defined(WPE_COMPILATION)
#include "export.h"
#endif

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * wpe_process_type:
 * @WPE_PROCESS_TYPE_WEB: WebKit's WebProcess.
 * @WPE_PROCESS_TYPE_NETWORK: WebKit's NetworkProcess.
 * @WPE_PROCESS_TYPE_GPU: WebKit's GPUProcess.
 * @WPE_PROCESS_TYPE_WEB_AUTHN: WebKit's WebAuthNProcess.
 *
 * Maps to the processes launched by WebKit.
 */
enum wpe_process_type {
    WPE_PROCESS_TYPE_WEB,
    WPE_PROCESS_TYPE_NETWORK,
    WPE_PROCESS_TYPE_GPU,
    WPE_PROCESS_TYPE_WEB_AUTHN,
};

struct wpe_process_provider;

/**
 * wpe_process_provider_interface:
 * @create: create an internal representation of a process provider.
 * @destroy: destroy instance process provider.
 * @launch: launches the specified WebKit process.
 * @terminate: terminates the specified Webkit process.
 *
 * Methods called by WebKit requesting process provider operations to implementator.
 *
 * Since: 1.14
 */
struct wpe_process_provider_interface {
    void* (*create)(struct wpe_process_provider*);
    void (*destroy)(void*);
    int64_t (*launch)(void*, enum wpe_process_type, void*);
    void (*terminate)(void*, int64_t);

    /*< private >*/
    void (*_wpe_reserved1)(void);
    void (*_wpe_reserved2)(void);
    void (*_wpe_reserved3)(void);
    void (*_wpe_reserved4)(void);
    void (*_wpe_reserved5)(void);
};

/**
 * wpe_process_provider_create:
 *
 * This method is called by WPEWebKit.
 *
 * Returns: an opaque object representing the process provider in libwpe.
 *
 * Since: 1.14
 */
WPE_EXPORT
struct wpe_process_provider* wpe_process_provider_create(void);

/**
 * wpe_process_provider_destroy:
 * @provider: opaque libwpe's representation of the process provider.
 *
 * Frees the internal resources used by @provider.
 *
 * This method is called by WPEWebKit.
 *
 * Since: 1.14
 */
WPE_EXPORT
void wpe_process_provider_destroy(struct wpe_process_provider*);

/**
 * wpe_process_launch:
 * @provider: opaque libwpe's representation of the process provider.
 * @type: the process type to launch.
 * @userdata: user data passed needed to launch the process.
 *
 * Launches the specified WebKit process.
 *
 * Returns: an identifier for the process.
 *
 * Since: 1.14
 */
WPE_EXPORT
int64_t wpe_process_launch(struct wpe_process_provider*, enum wpe_process_type, void*);

/**
 * wpe_process_terminate:
 * @provider: opaque libwpe's representation of the process provider.
 * @process: identifier for the process to terminate.
 *
 * Terminates the specified WebKit process.
 *
 * Since: 1.14
 */
WPE_EXPORT
void wpe_process_terminate(struct wpe_process_provider*, int64_t);

/**
 * wpe_process_provider_register_interface:
 * @iface: interface for the process provider.
 *
 * Sets the process provider interface.
 *
 * This method is called by WPEWebKit.
 *
 * Since: 1.14
 */
WPE_EXPORT
void wpe_process_provider_register_interface(const struct wpe_process_provider_interface*);

#ifdef __cplusplus
}
#endif

#endif /* wpe_process_h */
