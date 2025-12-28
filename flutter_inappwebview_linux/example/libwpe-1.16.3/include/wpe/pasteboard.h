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

#ifndef wpe_pasteboard_h
#define wpe_pasteboard_h

/**
 * SECTION:pasteboard
 * @short_description: Pasteboard (a.k.a. clipboard) Management
 * @title: Pasteboard
 */

#if defined(WPE_COMPILATION)
#include "export.h"
#endif

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

struct wpe_pasteboard_string {
    char* data;
    uint64_t length;
};

struct wpe_pasteboard_string_vector {
    struct wpe_pasteboard_string* strings;
    uint64_t length;
};

struct wpe_pasteboard_string_pair {
    struct wpe_pasteboard_string type;
    struct wpe_pasteboard_string string;
};

struct wpe_pasteboard_string_map {
    struct wpe_pasteboard_string_pair* pairs;
    uint64_t length;
};

/**
 * wpe_pasteboard_string_initialize:
 * @pbstring: (transfer none): A pasteboard string.
 * @contents: (transfer none): Contents to copy into the pasteboard string.
 * @length: Length of the contents, in bytes.
 *
 * Initializes a pasteboard string.
 *
 * When the string is not needed anymore, use wpe_pasteboard_string_free()
 * to free resources.
 */
WPE_EXPORT
void
wpe_pasteboard_string_initialize(struct wpe_pasteboard_string* pbstring, const char* contents, uint64_t length);

/**
 * wpe_pasteboard_string_free:
 * @pbstring: (transfer none): A pasteboard string.
 *
 * Frees any resources associated with @pbstring which may have been
 * previously allocated by wpe_pasteboard_string_initialize().
 */
WPE_EXPORT
void
wpe_pasteboard_string_free(struct wpe_pasteboard_string* pbstring);

WPE_EXPORT
void
wpe_pasteboard_string_vector_free(struct wpe_pasteboard_string_vector*);


struct wpe_pasteboard;

struct wpe_pasteboard_interface {
    void* (*initialize)(struct wpe_pasteboard*);

    void (*get_types)(void*, struct wpe_pasteboard_string_vector*);
    void (*get_string)(void*, const char*, struct wpe_pasteboard_string*);
    void (*write)(void*, struct wpe_pasteboard_string_map*);

    /*< private >*/
    void (*_wpe_reserved0)(void);
    void (*_wpe_reserved1)(void);
    void (*_wpe_reserved2)(void);
    void (*_wpe_reserved3)(void);
};

/**
 * wpe_pasteboard_get_singleton:
 *
 * Obtains the pasteboard object, creating it if neccessary.
 *
 * Returns: The pasteboard object.
 */
WPE_EXPORT
struct wpe_pasteboard*
wpe_pasteboard_get_singleton(void);

WPE_EXPORT
void
wpe_pasteboard_get_types(struct wpe_pasteboard*, struct wpe_pasteboard_string_vector*);

WPE_EXPORT
void
wpe_pasteboard_get_string(struct wpe_pasteboard*, const char*, struct wpe_pasteboard_string*);

WPE_EXPORT
void
wpe_pasteboard_write(struct wpe_pasteboard*, struct wpe_pasteboard_string_map*);

#ifdef __cplusplus
}
#endif

#endif /* wpe_pasteboard_h */
