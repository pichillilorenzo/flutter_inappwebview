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

#if !defined(__WPE_H_INSIDE__) && !defined(WPE_COMPILATION)
#error "Only <wpe/wpe.h> can be included directly."
#endif

#ifndef wpe_input_xkb_h
#define wpe_input_xkb_h

/**
 * SECTION:input
 * @short_description: Input Handling
 * @title: Input
 */

#if defined(WPE_ENABLE_XKB) && WPE_ENABLE_XKB

#if defined(WPE_COMPILATION)
#include "export.h"
#endif

#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

struct xkb_compose_state;
struct xkb_compose_table;
struct xkb_context;
struct xkb_keymap;
struct xkb_state;

struct wpe_input_xkb_context;

struct wpe_input_xkb_keymap_entry {
    uint32_t hardware_key_code;
    int32_t layout;
    int32_t level;
};

WPE_EXPORT
struct wpe_input_xkb_context*
wpe_input_xkb_context_get_default();

WPE_EXPORT
struct xkb_context*
wpe_input_xkb_context_get_context(struct wpe_input_xkb_context*);

WPE_EXPORT
struct xkb_keymap*
wpe_input_xkb_context_get_keymap(struct wpe_input_xkb_context*);

WPE_EXPORT
void
wpe_input_xkb_context_set_keymap(struct wpe_input_xkb_context*, struct xkb_keymap*);

WPE_EXPORT
struct xkb_state*
wpe_input_xkb_context_get_state(struct wpe_input_xkb_context*);

WPE_EXPORT
struct xkb_compose_table*
wpe_input_xkb_context_get_compose_table(struct wpe_input_xkb_context*);

WPE_EXPORT
void
wpe_input_xkb_context_set_compose_table(struct wpe_input_xkb_context*, struct xkb_compose_table*);

WPE_EXPORT
struct xkb_compose_state*
wpe_input_xkb_context_get_compose_state(struct wpe_input_xkb_context*);

WPE_EXPORT
uint32_t
wpe_input_xkb_context_get_modifiers(struct wpe_input_xkb_context*, uint32_t depressed, uint32_t latched, uint32_t locked, uint32_t group);

WPE_EXPORT
uint32_t
wpe_input_xkb_context_get_key_code(struct wpe_input_xkb_context*, uint32_t hardware_key_code, bool pressed);

WPE_EXPORT
void
wpe_input_xkb_context_get_entries_for_key_code(struct wpe_input_xkb_context*, uint32_t key_code, struct wpe_input_xkb_keymap_entry**, uint32_t* n_entries);

#ifdef __cplusplus
}
#endif

#endif /* defined(WPE_ENABLE_XKB) && WPE_ENABLE_XKB */

#endif /* wpe_input_xkb_h */
