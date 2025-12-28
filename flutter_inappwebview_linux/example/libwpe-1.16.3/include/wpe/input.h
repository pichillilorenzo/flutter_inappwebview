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

#ifndef wpe_input_h
#define wpe_input_h

/**
 * SECTION:input
 * @short_description: Input Handling
 * @title: Input
 */

#if defined(WPE_COMPILATION)
#include "export.h"
#endif

#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

enum wpe_input_modifier {
    wpe_input_keyboard_modifier_control = 1 << 0,
    wpe_input_keyboard_modifier_shift   = 1 << 1,
    wpe_input_keyboard_modifier_alt     = 1 << 2,
    wpe_input_keyboard_modifier_meta    = 1 << 3,

    wpe_input_pointer_modifier_button1  = 1 << 20,
    wpe_input_pointer_modifier_button2  = 1 << 21,
    wpe_input_pointer_modifier_button3  = 1 << 22,
    wpe_input_pointer_modifier_button4  = 1 << 23,
    wpe_input_pointer_modifier_button5  = 1 << 24,
};

struct wpe_input_keyboard_event {
    uint32_t time;
    uint32_t key_code;
    uint32_t hardware_key_code;
    bool pressed;
    uint32_t modifiers;
};


enum wpe_input_pointer_event_type {
    wpe_input_pointer_event_type_null,
    wpe_input_pointer_event_type_motion,
    wpe_input_pointer_event_type_button,
};

struct wpe_input_pointer_event {
    enum wpe_input_pointer_event_type type;
    uint32_t time;
    int x;
    int y;
    uint32_t button;
    uint32_t state;
    uint32_t modifiers;
};

struct wpe_input_pointer_lock_event {
    struct wpe_input_pointer_event base;
    double                         x_delta;
    double                         y_delta;
};

enum wpe_input_axis_event_type {
    wpe_input_axis_event_type_null,
    wpe_input_axis_event_type_motion,
    wpe_input_axis_event_type_motion_smooth,

    wpe_input_axis_event_type_mask_2d = 1 << 16,
};

struct wpe_input_axis_event {
    enum wpe_input_axis_event_type type;
    uint32_t time;
    int x;
    int y;
    uint32_t axis;
    int32_t value;
    uint32_t modifiers;
};

struct wpe_input_axis_2d_event {
    struct wpe_input_axis_event base;

    double x_axis;
    double y_axis;
};


enum wpe_input_touch_event_type {
    wpe_input_touch_event_type_null,
    wpe_input_touch_event_type_down,
    wpe_input_touch_event_type_motion,
    wpe_input_touch_event_type_up,
};

struct wpe_input_touch_event_raw {
    enum wpe_input_touch_event_type type;
    uint32_t time;
    int id;
    int32_t x;
    int32_t y;
};

struct wpe_input_touch_event {
    const struct wpe_input_touch_event_raw* touchpoints;
    uint64_t touchpoints_length;
    enum wpe_input_touch_event_type type;
    int32_t id;
    uint32_t time;
    uint32_t modifiers;
};


WPE_EXPORT
uint32_t
wpe_key_code_to_unicode (uint32_t);

WPE_EXPORT
uint32_t
wpe_unicode_to_key_code (uint32_t);

#ifdef __cplusplus
}
#endif

#endif /* wpe_input_h */
