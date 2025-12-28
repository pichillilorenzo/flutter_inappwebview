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

#if !defined(__WPE_EGL_H_INSIDE__) && !defined(WPE_COMPILATION)
#error "Only <wpe/wpe-egl.h> can be included directly."
#endif

#ifndef wpe_renderer_backend_egl_h
#define wpe_renderer_backend_egl_h

/**
 * SECTION:egl-renderer
 * @short_description: EGL Renderer Backend
 * @title: EGL Renderer
 */

#if defined(WPE_COMPILATION)
#include "export.h"
#endif

#ifdef _WIN32
/*
 * Only the definitions for the display and window types are needed,
 * and getting an EGL implementation for Windows typically involves
 * building ANGLE, so to simplify the process of building libwpe it
 * is enough to define the types accordingly in the same way as the
 * official Khronos header:
 *       https://www.khronos.org/registry/EGL/api/EGL/eglplatform.h
 */
# ifndef WIN32_LEAN_AND_MEAN
# define WIN32_LEAN_AND_MEAN 1
# endif /* !WIN32_LEAN_AND_MEAN */
# include <windows.h>
typedef HDC  EGLNativeDisplayType;
typedef HWND EGLNativeWindowType;
#else
# include <EGL/eglplatform.h>
#endif

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

struct wpe_renderer_backend_egl;
struct wpe_renderer_backend_egl_target;
struct wpe_renderer_backend_egl_offscreen_target;

struct wpe_renderer_backend_egl_target_client;

struct wpe_renderer_backend_egl_interface {
    void* (*create)(int);
    void (*destroy)(void*);

    EGLNativeDisplayType (*get_native_display)(void*);
    uint32_t (*get_platform)(void*);

    /*< private >*/
    void (*_wpe_reserved1)(void);
    void (*_wpe_reserved2)(void);
    void (*_wpe_reserved3)(void);
};

struct wpe_renderer_backend_egl_base {
    const struct wpe_renderer_backend_egl_interface* interface;
    void* interface_data;
};

struct wpe_renderer_backend_egl_target_interface {
    void* (*create)(struct wpe_renderer_backend_egl_target*, int);
    void (*destroy)(void*);

    void (*initialize)(void*, void*, uint32_t, uint32_t);
    EGLNativeWindowType (*get_native_window)(void*);
    void (*resize)(void*, uint32_t, uint32_t);
    void (*frame_will_render)(void*);
    void (*frame_rendered)(void*);
    void (*deinitialize)(void*);

    /*< private >*/
    void (*_wpe_reserved1)(void);
    void (*_wpe_reserved2)(void);
    void (*_wpe_reserved3)(void);
};

struct wpe_renderer_backend_egl_target_base {
    const struct wpe_renderer_backend_egl_target_interface* interface;
    void* interface_data;
};

struct wpe_renderer_backend_egl_offscreen_target_interface {
    void* (*create)();
    void (*destroy)(void*);

    void (*initialize)(void*, void*);
    EGLNativeWindowType (*get_native_window)(void*);

    /*< private >*/
    void (*_wpe_reserved0)(void);
    void (*_wpe_reserved1)(void);
    void (*_wpe_reserved2)(void);
    void (*_wpe_reserved3)(void);
};

struct wpe_renderer_backend_egl_offscreen_target_base {
    const struct wpe_renderer_backend_egl_offscreen_target_interface* interface;
    void* interface_data;
};


WPE_EXPORT
struct wpe_renderer_backend_egl*
wpe_renderer_backend_egl_create(int);

WPE_EXPORT
void
wpe_renderer_backend_egl_destroy(struct wpe_renderer_backend_egl*);

WPE_EXPORT
EGLNativeDisplayType
wpe_renderer_backend_egl_get_native_display(struct wpe_renderer_backend_egl*);

WPE_EXPORT
uint32_t
wpe_renderer_backend_egl_get_platform(struct wpe_renderer_backend_egl*);

WPE_EXPORT
struct wpe_renderer_backend_egl_target*
wpe_renderer_backend_egl_target_create(int);

WPE_EXPORT
void
wpe_renderer_backend_egl_target_destroy(struct wpe_renderer_backend_egl_target*);

WPE_EXPORT
void
wpe_renderer_backend_egl_target_set_client(struct wpe_renderer_backend_egl_target*, const struct wpe_renderer_backend_egl_target_client*, void*);

WPE_EXPORT
void
wpe_renderer_backend_egl_target_initialize(struct wpe_renderer_backend_egl_target*, struct wpe_renderer_backend_egl*, uint32_t, uint32_t);

WPE_EXPORT
EGLNativeWindowType
wpe_renderer_backend_egl_target_get_native_window(struct wpe_renderer_backend_egl_target*);

WPE_EXPORT
void
wpe_renderer_backend_egl_target_resize(struct wpe_renderer_backend_egl_target*, uint32_t, uint32_t);

WPE_EXPORT
void
wpe_renderer_backend_egl_target_frame_will_render(struct wpe_renderer_backend_egl_target*);

WPE_EXPORT
void
wpe_renderer_backend_egl_target_frame_rendered(struct wpe_renderer_backend_egl_target*);

WPE_EXPORT
void
wpe_renderer_backend_egl_target_deinitialize(struct wpe_renderer_backend_egl_target*);

WPE_EXPORT
struct wpe_renderer_backend_egl_offscreen_target*
wpe_renderer_backend_egl_offscreen_target_create();

WPE_EXPORT
void
wpe_renderer_backend_egl_offscreen_target_destroy(struct wpe_renderer_backend_egl_offscreen_target*);

WPE_EXPORT
void
wpe_renderer_backend_egl_offscreen_target_initialize(struct wpe_renderer_backend_egl_offscreen_target*, struct wpe_renderer_backend_egl*);

WPE_EXPORT
EGLNativeWindowType
wpe_renderer_backend_egl_offscreen_target_get_native_window(struct wpe_renderer_backend_egl_offscreen_target*);

struct wpe_renderer_backend_egl_target_client {
    void (*frame_complete)(void*);

    /*< private >*/
    void (*_wpe_reserved0)(void);
    void (*_wpe_reserved1)(void);
    void (*_wpe_reserved2)(void);
    void (*_wpe_reserved3)(void);
};

WPE_EXPORT
void
wpe_renderer_backend_egl_target_dispatch_frame_complete(struct wpe_renderer_backend_egl_target*);

#ifdef __cplusplus
}
#endif

#endif /* wpe_renderer_backend_egl_h */
