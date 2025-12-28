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

#if defined(WPE_ENABLE_XKB) && WPE_ENABLE_XKB

#include "../include/wpe/input-xkb.h"
#include "../include/wpe/input.h"

#include "alloc-private.h"
#include <locale.h>
#include <stdlib.h>
#include <xkbcommon/xkbcommon-compose.h>
#include <xkbcommon/xkbcommon.h>

struct wpe_input_xkb_context {
    struct xkb_context* context;
    struct xkb_state* state;
    struct xkb_compose_state* compose_state;
};

struct wpe_input_xkb_context*
wpe_input_xkb_context_get_default()
{
    static struct wpe_input_xkb_context* s_xkb_context = NULL;
    if (!s_xkb_context) {
        struct xkb_context* context = xkb_context_new(XKB_CONTEXT_NO_FLAGS);
        if (context) {
            s_xkb_context = wpe_calloc(1, sizeof(struct wpe_input_xkb_context));
            s_xkb_context->context = context;
        }
    }

    return s_xkb_context;
}

struct xkb_context*
wpe_input_xkb_context_get_context(struct wpe_input_xkb_context* xkb_context)
{
    return xkb_context->context;
}

static void
wpe_input_xkb_context_try_ensure_keymap(struct wpe_input_xkb_context* xkb_context)
{
    if (xkb_context->state)
        return;

    struct xkb_rule_names names = { "evdev", "pc105", "us", "", "" };
    struct xkb_keymap* keymap = xkb_keymap_new_from_names(xkb_context->context, &names, XKB_KEYMAP_COMPILE_NO_FLAGS);
    if (keymap) {
        xkb_context->state = xkb_state_new(keymap);
        xkb_keymap_unref(keymap);
    }
}

struct xkb_keymap*
wpe_input_xkb_context_get_keymap(struct wpe_input_xkb_context* xkb_context)
{
    struct xkb_state* state = wpe_input_xkb_context_get_state(xkb_context);

    return state ? xkb_state_get_keymap(state) : NULL;
}

void
wpe_input_xkb_context_set_keymap(struct wpe_input_xkb_context* xkb_context, struct xkb_keymap* keymap)
{
    if (!keymap)
        return;

    if (xkb_context->state)
        xkb_state_unref(xkb_context->state);
    xkb_context->state = xkb_state_new(keymap);
}

struct xkb_state*
wpe_input_xkb_context_get_state(struct wpe_input_xkb_context* xkb_context)
{
    wpe_input_xkb_context_try_ensure_keymap(xkb_context);

    return xkb_context->state;
}

static void
wpe_input_xkb_context_try_ensure_compose_table(struct wpe_input_xkb_context* xkb_context)
{
    if (xkb_context->compose_state)
        return;

    struct xkb_compose_table* compose_table = xkb_compose_table_new_from_locale(xkb_context->context, setlocale(LC_CTYPE, NULL), XKB_COMPOSE_COMPILE_NO_FLAGS);
    if (compose_table) {
        xkb_context->compose_state = xkb_compose_state_new(compose_table, XKB_COMPOSE_STATE_NO_FLAGS);
        xkb_compose_table_unref(compose_table);
    }
}

struct xkb_compose_table*
wpe_input_xkb_context_get_compose_table(struct wpe_input_xkb_context* xkb_context)
{
    struct xkb_compose_state* state = wpe_input_xkb_context_get_compose_state(xkb_context);

    return state ? xkb_compose_state_get_compose_table(state) : NULL;
}

void
wpe_input_xkb_context_set_compose_table(struct wpe_input_xkb_context* xkb_context, struct xkb_compose_table* compose_table)
{
    if (!compose_table)
        return;

    if (xkb_context->compose_state)
        xkb_compose_state_unref(xkb_context->compose_state);
    xkb_context->compose_state = xkb_compose_state_new(compose_table, XKB_COMPOSE_STATE_NO_FLAGS);
}

struct xkb_compose_state*
wpe_input_xkb_context_get_compose_state(struct wpe_input_xkb_context* xkb_context)
{
    wpe_input_xkb_context_try_ensure_compose_table(xkb_context);

    return xkb_context->compose_state;
}

uint32_t
wpe_input_xkb_context_get_modifiers(struct wpe_input_xkb_context* xkb_context, uint32_t depressed, uint32_t latched, uint32_t locked, uint32_t group)
{
    wpe_input_xkb_context_try_ensure_keymap(xkb_context);
    if (!xkb_context->state)
        return 0;

    xkb_state_update_mask(xkb_context->state, depressed, latched, locked, 0, 0, group);
    xkb_mod_mask_t mask = xkb_state_serialize_mods(xkb_context->state, XKB_STATE_MODS_DEPRESSED | XKB_STATE_MODS_LATCHED);

    struct xkb_keymap* keymap = xkb_state_get_keymap(xkb_context->state);
    uint32_t retval = 0;
    if (mask & (1 << xkb_keymap_mod_get_index(keymap, XKB_MOD_NAME_SHIFT)))
        retval |= wpe_input_keyboard_modifier_shift;
    if (mask & (1 << xkb_keymap_mod_get_index(keymap, XKB_MOD_NAME_CTRL)))
        retval |= wpe_input_keyboard_modifier_control;
    if (mask & (1 << xkb_keymap_mod_get_index(keymap, XKB_MOD_NAME_ALT)))
        retval |= wpe_input_keyboard_modifier_alt;
    if (mask & (1 << xkb_keymap_mod_get_index(keymap, "Meta")))
        retval |= wpe_input_keyboard_modifier_meta;
    return retval;
}

uint32_t
wpe_input_xkb_context_get_key_code(struct wpe_input_xkb_context* xkb_context, uint32_t hardware_key_code, bool pressed)
{
    wpe_input_xkb_context_try_ensure_keymap(xkb_context);
    if (!xkb_context->state)
        return 0;

    uint32_t sym = xkb_state_key_get_one_sym(xkb_context->state, hardware_key_code);
    if (!pressed)
        return sym;

    wpe_input_xkb_context_try_ensure_compose_table(xkb_context);
    if (!xkb_context->compose_state)
        return sym;

    if (xkb_compose_state_feed(xkb_context->compose_state, sym) != XKB_COMPOSE_FEED_ACCEPTED)
        return sym;

    switch (xkb_compose_state_get_status(xkb_context->compose_state)) {
    case XKB_COMPOSE_COMPOSING:
    case XKB_COMPOSE_CANCELLED:
        return 0;
    case XKB_COMPOSE_COMPOSED:
        return xkb_compose_state_get_one_sym(xkb_context->compose_state);
    case XKB_COMPOSE_NOTHING:
    default:
        break;
    }

    return sym;
}

void
wpe_input_xkb_context_get_entries_for_key_code(struct wpe_input_xkb_context* xkb_context, uint32_t key, struct wpe_input_xkb_keymap_entry** entries, uint32_t* n_entries)
{
    wpe_input_xkb_context_try_ensure_keymap(xkb_context);
    if (!xkb_context->state) {
        *entries = NULL;
        *n_entries = 0;

        return;
    }

    struct wpe_input_xkb_keymap_entry* array = NULL;
    unsigned array_allocated_size = 0;
    unsigned array_size = 0;

    struct xkb_keymap* keymap = xkb_state_get_keymap(xkb_context->state);
    xkb_keycode_t min_key_code = xkb_keymap_min_keycode(keymap);
    xkb_keycode_t max_key_code = xkb_keymap_max_keycode(keymap);
    xkb_keycode_t key_code;

    for (key_code = min_key_code; key_code < max_key_code; key_code++) {
        xkb_layout_index_t num_layouts = xkb_keymap_num_layouts_for_key(keymap, key_code);
        xkb_layout_index_t layout;

        for (layout = 0; layout < num_layouts; layout++) {
            xkb_level_index_t num_levels = xkb_keymap_num_levels_for_key(keymap, key_code, layout);
            xkb_level_index_t level;

            for (level = 0; level < num_levels; level++) {
                const xkb_keysym_t *syms;
                int num_syms = xkb_keymap_key_get_syms_by_level(keymap, key_code, layout, level, &syms);
                int sym;

                for (sym = 0; sym < num_syms; sym++) {
                    if (syms[sym] == key) {
                        if (++array_size > array_allocated_size) {
                            array_allocated_size += 4;
                            array =
                                wpe_realloc(array, array_allocated_size * sizeof(struct wpe_input_xkb_keymap_entry));
                        }
                        struct wpe_input_xkb_keymap_entry* entry = &array[array_size - 1];

                        entry->hardware_key_code = key_code;
                        entry->layout = layout;
                        entry->level = level;
                    }
                }
            }
        }
    }

    *entries = array;
    *n_entries = array_size;
}

#endif /* defined(WPE_ENABLE_XKB) && WPE_ENABLE_XKB */
