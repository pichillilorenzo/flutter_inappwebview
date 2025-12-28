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

#ifndef wpe_view_backend_h
#define wpe_view_backend_h

/**
 * SECTION:view-backend
 * @short_description: View Backend
 * @title: View Backend
 */

#if defined(WPE_COMPILATION)
#include "export.h"
#endif

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h>
#include <stdint.h>

struct wpe_view_backend;

struct wpe_input_axis_event;
struct wpe_input_keyboard_event;
struct wpe_input_pointer_event;
struct wpe_input_pointer_lock_event;
struct wpe_input_touch_event;

struct wpe_view_backend_client;
struct wpe_view_backend_input_client;
struct wpe_view_backend_fullscreen_client;

struct wpe_view_backend_interface {
    void* (*create)(void*, struct wpe_view_backend*);
    void (*destroy)(void*);

    void (*initialize)(void*);
    int (*get_renderer_host_fd)(void*);

    /*< private >*/
    void (*_wpe_reserved0)(void);
    void (*_wpe_reserved1)(void);
    void (*_wpe_reserved2)(void);
    void (*_wpe_reserved3)(void);
};

struct wpe_view_backend_base {
    const struct wpe_view_backend_interface* interface;
    void* interface_data;
};


WPE_EXPORT
struct wpe_view_backend*
wpe_view_backend_create();

WPE_EXPORT
struct wpe_view_backend*
wpe_view_backend_create_with_backend_interface(struct wpe_view_backend_interface*, void*);

WPE_EXPORT
void
wpe_view_backend_destroy(struct wpe_view_backend*);

WPE_EXPORT
void 
wpe_view_backend_set_backend_client(struct wpe_view_backend*, const struct wpe_view_backend_client*, void*);

WPE_EXPORT
void
wpe_view_backend_set_input_client(struct wpe_view_backend*, const struct wpe_view_backend_input_client*, void*);

/**
 * wpe_view_backend_set_fullscreen_client:
 * @view_backend: (transfer none): The view backend to obtains events from.
 * @client: (transfer none) (nullable): Client with callbacks for the events.
 * @userdata: (transfer none) (nullable): User data passed to client callbacks.
 * 
 * Configure a @client with callbacks invoked for DOM fullscreen requests.
 * 
 * This function must be only used once for a given @view_backend, the client
 * cannot be changed once it has been set.
 *
 * Since: 1.12
 */
WPE_EXPORT
void
wpe_view_backend_set_fullscreen_client(struct wpe_view_backend*, const struct wpe_view_backend_fullscreen_client*, void*);

/**
 * wpe_view_backend_fullscreen_handler:
 * @userdata: (transfer none): User data passed to the embedder.
 * @enable: (transfer none): User data passed to the embedder.
 * 
 * Type of functions used by an embedder to implement fullscreening web views.
 *
 * Returns: a boolean indicating whether the operation was completed.
 * 
 * Since: 1.12
 */
typedef bool (*wpe_view_backend_fullscreen_handler)(void *userdata, bool enable);

/**
 * wpe_view_backend_set_fullscreen_handler:
 * @view_backend: (transfer none): The view backend to obtains events from.
 * @handler: (transfer none): Function used by an embedder to implement fullscreening web views.
 * @userdata: (transfer none): User data passed to the handler function.
 * 
 * Handler function set by an embedder to implement fullscreening web views.
 * 
 * This function must be only used once for a given @view_backend, the handler
 * cannot be changed once it has been set.
 *
 * Since: 1.12
 */
WPE_EXPORT
void
wpe_view_backend_set_fullscreen_handler(struct wpe_view_backend*, wpe_view_backend_fullscreen_handler handler, void* userdata);

/**
 * wpe_view_backend_pointer_lock_handler:
 * @userdata: (transfer none): User data passed to the embedder.
 * @enable: (transfer none): User data passed to the embedder.
 *
 * Type of functions used by an embedder to implement pointer lock in web views.
 *
 * Returns: a boolean indicating whether the operation was completed.
 *
 * Since: 1.14
 */
typedef bool (*wpe_view_backend_pointer_lock_handler)(void* userdata, bool enable);

/**
 * wpe_view_backend_set_pointer_lock_handler:
 * @view_backend: (transfer none): The view backend to obtains events from.
 * @handler: (transfer none): Function used by an embedder to implement pointer lock.
 * @userdata: (transfer none): User data passed to the handler function.
 *
 * Handler function set by an embedder to implement pointer lock in web views.
 *
 * This function must be only used once for a given @view_backend, the handler
 * cannot be changed once it has been set.
 *
 * Since: 1.14
 */
WPE_EXPORT
void wpe_view_backend_set_pointer_lock_handler(struct wpe_view_backend*,
                                               wpe_view_backend_pointer_lock_handler handler,
                                               void*                                 userdata);

WPE_EXPORT
void
wpe_view_backend_initialize(struct wpe_view_backend*);

WPE_EXPORT
int
wpe_view_backend_get_renderer_host_fd(struct wpe_view_backend*);

enum wpe_view_activity_state {
    wpe_view_activity_state_visible   = 1 << 0,
    wpe_view_activity_state_focused   = 1 << 1,
    wpe_view_activity_state_in_window = 1 << 2
};

struct wpe_view_backend_client {
    void (*set_size)(void*, uint32_t, uint32_t);
    void (*frame_displayed)(void*);
    void (*activity_state_changed)(void*, uint32_t);
    void* (*get_accessible)(void*);
    void (*set_device_scale_factor)(void*, float);
    void (*target_refresh_rate_changed)(void*, uint32_t);
};

WPE_EXPORT
void
wpe_view_backend_dispatch_set_size(struct wpe_view_backend*, uint32_t, uint32_t);

WPE_EXPORT
void
wpe_view_backend_dispatch_frame_displayed(struct wpe_view_backend*);

WPE_EXPORT
void
wpe_view_backend_add_activity_state(struct wpe_view_backend*, uint32_t);

WPE_EXPORT
void
wpe_view_backend_remove_activity_state(struct wpe_view_backend*, uint32_t);

WPE_EXPORT
uint32_t
wpe_view_backend_get_activity_state(struct wpe_view_backend*);

WPE_EXPORT
void*
wpe_view_backend_dispatch_get_accessible(struct wpe_view_backend* backend);

/**
 * wpe_view_backend_dispatch_set_device_scale_factor:
 * @view_backend: (transfer none): The view backend to configure.
 * @factor: Scaling factor to apply.
 *
 * Configure the device scaling factor applied to rendered content.
 *
 * Set the @factor by which sizes of content rendered to a web view will be
 * multiplied by. The typical reason to set a value other than `1.0` (the
 * default) is to produce output that will display at the intended physical
 * size in displays with a high density of pixels.
 *
 * Only values from `0.05` up to `5.0` are allowed. Setting a value outside
 * this range will be ignored, and in debug builds execution will be aborted.
 *
 * For example, a display that has a physical resolution of 3840x2160 with
 * a scaling factor of `2.0` will make web content behave as if the screen
 * had a size of 1920x1080, and content will be rendered at twice the size:
 * each “logical” pixel will occupy four “physical” pixels (a 2x2 box) on
 * the output.
 *
 * Since: 1.4
 */
WPE_EXPORT
void
wpe_view_backend_dispatch_set_device_scale_factor(struct wpe_view_backend*, float);

WPE_EXPORT
uint32_t wpe_view_backend_get_target_refresh_rate(struct wpe_view_backend*);

WPE_EXPORT
void wpe_view_backend_set_target_refresh_rate(struct wpe_view_backend*, uint32_t);

struct wpe_view_backend_input_client {
    void (*handle_keyboard_event)(void*, struct wpe_input_keyboard_event*);
    void (*handle_pointer_event)(void*, struct wpe_input_pointer_event*);
    void (*handle_axis_event)(void*, struct wpe_input_axis_event*);
    void (*handle_touch_event)(void*, struct wpe_input_touch_event*);
    void (*handle_pointer_lock_event)(void*, struct wpe_input_pointer_lock_event*);

    /*< private >*/
    void (*_wpe_reserved0)(void);
    void (*_wpe_reserved1)(void);
    void (*_wpe_reserved2)(void);
};

WPE_EXPORT
void
wpe_view_backend_dispatch_keyboard_event(struct wpe_view_backend*, struct wpe_input_keyboard_event*);

WPE_EXPORT
void
wpe_view_backend_dispatch_pointer_event(struct wpe_view_backend*, struct wpe_input_pointer_event*);

WPE_EXPORT
void
wpe_view_backend_dispatch_axis_event(struct wpe_view_backend*, struct wpe_input_axis_event*);

WPE_EXPORT
void
wpe_view_backend_dispatch_touch_event(struct wpe_view_backend*, struct wpe_input_touch_event*);

WPE_EXPORT
void wpe_view_backend_dispatch_pointer_lock_event(struct wpe_view_backend*, struct wpe_input_pointer_lock_event*);

/**
 * wpe_view_backend_fullscreen_client:
 * @did_enter_fullscreen: Invoked after fullscreen has been successfully entered.
 * @did_exit_fullscreen: Invoked after fullscreen has been exited.
 * @request_enter_fullscreen: Invoked after user has requested to enter fullscreen.
 * @request_exit_fullscreen: Invoked after user has requested to exit fullscreen.
 *
 * A view backend's fullscreen client provides a series of callback functions
 * which are invoked at different stages when a web view becomes fullscreened
 * and back.
 *
 * Since: 1.12
 */
struct wpe_view_backend_fullscreen_client {
    void (*did_enter_fullscreen)(void*);
    void (*did_exit_fullscreen)(void*);
    void (*request_enter_fullscreen)(void*);
    void (*request_exit_fullscreen)(void*);

    /*< private >*/
    void (*_wpe_reserved0)(void);
    void (*_wpe_reserved1)(void);
    void (*_wpe_reserved2)(void);
    void (*_wpe_reserved3)(void);
};

/**
 * wpe_view_backend_platform_set_fullscreen:
 * @view_backend: (transfer none): The view backend which fullscreen state will be changed.
 * @fullscreen: (transfer none): True if fullscreen.
 * 
 * Returns: a boolean indicating whether the operation was completed.
 * 
 * DOM content calls this function to request the platform to enter/exit fullscreen.
 * The platform will attempt to change it's window fullscreen state.
 *
 * Since: 1.12
 */
WPE_EXPORT
bool
wpe_view_backend_platform_set_fullscreen(struct wpe_view_backend*, bool);

/**
 * wpe_view_backend_dispatch_did_enter_fullscreen:
 * @view_backend: (transfer none): The view backend that triggered the event.
 * 
 * Dispatchs the event that indicates fullscreen has been successfully entered.
 *
 * Since: 1.12
 */
WPE_EXPORT
void
wpe_view_backend_dispatch_did_enter_fullscreen(struct wpe_view_backend*);

/**
 * wpe_view_backend_dispatch_did_exit_fullscreen:
 * @view_backend: (transfer none): The view backend that triggered the event.
 * 
 * Dispatchs the event that indicated fullscreen has been successfully entered.
 *
 * Since: 1.12
 */
WPE_EXPORT
void
wpe_view_backend_dispatch_did_exit_fullscreen(struct wpe_view_backend*);

/**
 * wpe_view_backend_dispatch_request_enter_fullscreen:
 * @view_backend: (transfer none): The view backend that triggered the event.
 * 
 * Dispatchs the event that indicates user wants to enter DOM fullscreen state.
 *
 * Since: 1.12
 */
WPE_EXPORT
void
wpe_view_backend_dispatch_request_enter_fullscreen(struct wpe_view_backend*);

/**
 * wpe_view_backend_dispatch_request_exit_fullscreen:
 * @view_backend: (transfer none): The view backend that triggered the event.
 * 
 * Dispatchs the event that indicates user wants to exit DOM fullscreen state.
 *
 * Since: 1.12
 */
WPE_EXPORT
void
wpe_view_backend_dispatch_request_exit_fullscreen(struct wpe_view_backend*);

/**
 * wpe_view_backend_request_pointer_lock:
 * @view_backend: (transfer none): The view backend that triggered the event.
 *
 * Request the platform to lock the pointer.
 *
 * Returns: a boolean indicating whether the operation was completed.
 *
 * Since: 1.14
 */
WPE_EXPORT
bool wpe_view_backend_request_pointer_lock(struct wpe_view_backend*);

/**
 * wpe_view_backend_request_pointer_unlock:
 * @view_backend: (transfer none): The view backend that triggered the event.
 *
 * Request the platform to unlock the pointer.
 *
 * Returns: a boolean indicating whether the operation was completed.
 *
 * Since: 1.14
 */
WPE_EXPORT
bool wpe_view_backend_request_pointer_unlock(struct wpe_view_backend*);

#ifdef __cplusplus
}
#endif

#endif /* wpe_view_backend_h */
