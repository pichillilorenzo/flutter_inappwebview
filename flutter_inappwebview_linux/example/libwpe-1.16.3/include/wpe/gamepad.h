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

#if !defined(__WPE_H_INSIDE__) && !defined(WPE_COMPILATION)
#error "Only <wpe/wpe.h> can be included directly."
#endif

#ifndef wpe_gamepad_h
#define wpe_gamepad_h

/**
 * SECTION:gamepad
 * @short_description: Gamepad
 * @title: Gamepad
 */

#if defined(WPE_COMPILATION)
#include <wpe/export.h>
#endif

#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * wpe_gamepad_axis:
 * @WPE_GAMEPAD_AXIS_LEFT_STICK_X: Horizontal axis for left stick (negative left/positive right).
 * @WPE_GAMEPAD_AXIS_LEFT_STICK_Y: Vertical axis for left stick (negative up/positive down).
 * @WPE_GAMEPAD_AXIS_RIGHT_STICK_X: Horizontal axis for right stick (negative left/positive right).
 * @WPE_GAMEPAD_AXIS_RIGHT_STICK_Y: Vertical axis for right stick (negative up/positive down).
 * @WPE_GAMEPAD_AXIS_COUNT: max number of axis.
 *
 * Standard mapping.
 * Refer https://www.w3.org/TR/gamepad/#gamepadbutton-interface
 */
enum wpe_gamepad_axis {
    WPE_GAMEPAD_AXIS_LEFT_STICK_X,
    WPE_GAMEPAD_AXIS_LEFT_STICK_Y,
    WPE_GAMEPAD_AXIS_RIGHT_STICK_X,
    WPE_GAMEPAD_AXIS_RIGHT_STICK_Y,
    WPE_GAMEPAD_AXIS_COUNT,
};

/**
 * wpe_gamepad_button:
 * @WPE_GAMEPAD_BUTTON_BOTTOM: Bottom button in right cluster.
 * @WPE_GAMEPAD_BUTTON_RIGHT: Right button in right cluster.
 * @WPE_GAMEPAD_BUTTON_LEFT: Left button in right cluster.
 * @WPE_GAMEPAD_BUTTON_TOP: Top button in right cluster.
 * @WPE_GAMEPAD_BUTTON_LEFT_SHOULDER: Top left front button.
 * @WPE_GAMEPAD_BUTTON_RIGHT_SHOULDER: Top right front button.
 * @WPE_GAMEPAD_BUTTON_LEFT_TRIGGER: Bottom left front button.
 * @WPE_GAMEPAD_BUTTON_RIGHT_TRIGGER: Bottom right front button.
 * @WPE_GAMEPAD_BUTTON_SELECT: Left button in center cluster.
 * @WPE_GAMEPAD_BUTTON_START: Right button in center cluster.
 * @WPE_GAMEPAD_BUTTON_LEFT_STICK: Left stick pressed button.
 * @WPE_GAMEPAD_BUTTON_RIGHT_STICK: Right stick pressed button.
 * @WPE_GAMEPAD_BUTTON_D_PAD_TOP: Top button in left cluster.
 * @WPE_GAMEPAD_BUTTON_D_PAD_BOTOM: Bottom button in left cluster
 * @WPE_GAMEPAD_BUTTON_D_PAD_LEFT: Left button in left cluster.
 * @WPE_GAMEPAD_BUTTON_D_PAD_RIGHT: Right button in left cluster.
 * @WPE_GAMEPAD_BUTTON_CENTER: Center button in center cluster.
 * @WPE_GAMEPAD_BUTTON_COUNT: Max number of buttons.
 *
 * Standard mapping.
 * Refer https://www.w3.org/TR/gamepad/#gamepadbutton-interface
 */
enum wpe_gamepad_button {
    WPE_GAMEPAD_BUTTON_BOTTOM,
    WPE_GAMEPAD_BUTTON_RIGHT,
    WPE_GAMEPAD_BUTTON_LEFT,
    WPE_GAMEPAD_BUTTON_TOP,
    WPE_GAMEPAD_BUTTON_LEFT_SHOULDER,
    WPE_GAMEPAD_BUTTON_RIGHT_SHOULDER,
    WPE_GAMEPAD_BUTTON_LEFT_TRIGGER,
    WPE_GAMEPAD_BUTTON_RIGHT_TRIGGER,
    WPE_GAMEPAD_BUTTON_SELECT,
    WPE_GAMEPAD_BUTTON_START,
    WPE_GAMEPAD_BUTTON_LEFT_STICK,
    WPE_GAMEPAD_BUTTON_RIGHT_STICK,
    WPE_GAMEPAD_BUTTON_D_PAD_TOP,
    WPE_GAMEPAD_BUTTON_D_PAD_BOTTOM,
    WPE_GAMEPAD_BUTTON_D_PAD_LEFT,
    WPE_GAMEPAD_BUTTON_D_PAD_RIGHT,
    WPE_GAMEPAD_BUTTON_CENTER,
    WPE_GAMEPAD_BUTTON_COUNT,
};

struct wpe_gamepad;
struct wpe_gamepad_provider;

/**
 * wpe_gamepad_provider_client_interface:
 * @connected: Callback to inform WPEWebKit that a new gamepad device is plugged.
 * @disconnected: Callback to inform WPEWebKit that a new gamepad device is gone.
 *
 * This interface is defines gamepad provider callbacks to notify WPEWebKit of devices.
 *
 * Since: 1.14
 */
struct wpe_gamepad_provider_client_interface {
    void (*connected)(void*, uintptr_t);
    void (*disconnected)(void*, uintptr_t);

    /*< private >*/
    void (*_wpe_reserved1)(void);
    void (*_wpe_reserved2)(void);
    void (*_wpe_reserved3)(void);
};

/**
 * wpe_gamepad_client_interface:
 * @button_changed: Callback to inform WPEWebkit a change in the status of a button.
 * @axis_changed: Callback to inform WPEWebkit a change in the status of an axis.
 *
 * This interface is defines gamepad callbacks to notify WPEWebKit of events.
 *
 * Since: 1.14
 */
struct wpe_gamepad_client_interface {
    void (*button_changed)(void*, enum wpe_gamepad_button, bool);
    void (*axis_changed)(void*, enum wpe_gamepad_axis, double);
    void (*analog_button_changed)(void*, enum wpe_gamepad_button, double);

    /*< private >*/
    void (*_wpe_reserved1)(void);
    void (*_wpe_reserved2)(void);
};

/**
 * wpe_gamepad_provider_interface:
 * @create: create an internal representation of a gamepad provider.
 * @destroy: destroy instance gamepad provider.
 * @start: gamepad device should start monitoring for gamepad devices.
 * @stop: gamepad device should stop monitoring for gamepad devices.
 * @get_view_backend: request the view backend where gamepad device is attached.
 *
 * Methods called by WebKit requesting gamepad provider operations to implementator.
 *
 * Since: 1.14
 */
struct wpe_gamepad_provider_interface {
    void* (*create)(struct wpe_gamepad_provider*);
    void (*destroy)(void*);
    void (*start)(void*);
    void (*stop)(void*);
    struct wpe_view_backend* (*get_view_backend)(void*, void*);

    /*< private >*/
    void (*_wpe_reserved1)(void);
    void (*_wpe_reserved2)(void);
    void (*_wpe_reserved3)(void);
};

/**
 * wpe_gamepad_provider_interface:
 * @create: creates a gamepad device.
 * @destroy: destroy a gamepad device.
 * @get_id: Gets the gamepad's id string.
 *
 * Methods called by WebKit requesting gamepad device operations to implementator.
 *
 * Since: 1.14
 */
struct wpe_gamepad_interface {
    void* (*create)(struct wpe_gamepad*, struct wpe_gamepad_provider*, uintptr_t);
    void (*destroy)(void*);
    const char* (*get_id)(void*);

    /*< private >*/
    void (*_wpe_reserved1)(void);
    void (*_wpe_reserved2)(void);
    void (*_wpe_reserved3)(void);
};

/**
 * wpe_gamepad_provider_create:
 *
 * This method is called by WPEWebKit.
 *
 * Returns: an opaque object representing the gamepad provider in libwpe.
 *
 * Since: 1.14
 */
WPE_EXPORT
struct wpe_gamepad_provider* wpe_gamepad_provider_create(void);

/**
 * wpe_gamepad_provider_destroy:
 * @provider: opaque libwpe's representation of gamepad provider.
 *
 * Frees the internal resources used by @provider.
 *
 * This method is called by WPEWebKit.
 *
 * Since: 1.14
 */
WPE_EXPORT
void wpe_gamepad_provider_destroy(struct wpe_gamepad_provider*);

/**
 * wpe_gamepad_provider_set_client:
 * @provider: opaque libwpe's representation of gamepad provider.
 * @client_interface: WPEWebKit callbacks for gamepad devices appearance.
 * @client_data: WPEWebkit closure data.
 *
 * Sets WPEWebKit callbacks in @provider.
 *
 * Since: 1.14
 */
WPE_EXPORT
void wpe_gamepad_provider_set_client(struct wpe_gamepad_provider*,
                                     const struct wpe_gamepad_provider_client_interface*,
                                     void*);

/**
 * wpe_gamepad_provider_start:
 * @provider: opaque libwpe's representation of gamepad provider.
 *
 * Called by WPEWebkit to start @provider monitoring for gamepad
 * devices.
 *
 * Since: 1.14
 */
WPE_EXPORT
void wpe_gamepad_provider_start(struct wpe_gamepad_provider*);

/**
 * wpe_gamepad_provider_stop:
 * @provider: opaque libwpe's representation of gamepad provider.
 *
 * Called by WPEWebkit to stop @provider monitoring for gamepad
 * devices.
 *
 * Since: 1.14
 */
WPE_EXPORT
void wpe_gamepad_provider_stop(struct wpe_gamepad_provider*);

/**
 * wpe_gamepad_provider_get_backend:
 * @provider: opaque libwpe's representation of gamepad provider.
 *
 * Called by application (gamepad implementator) to access it's internal object.

 * Returns: the pointer to the implementator's object.
 *
 * Since: 1.14
 */
WPE_EXPORT
void* wpe_gamepad_provider_get_backend(struct wpe_gamepad_provider*);

/**
 * wpe_gampepad_provider_get_view_backend:
 * @provider: opaque libwpe's representation of gamepad provider.
 * @gamepad: opaque libwep's representation of gampead
 *
 * Ask @provider for the view to where @gamepad is attached.
 *
 * Since: 1.14
 */
WPE_EXPORT
struct wpe_view_backend* wpe_gamepad_provider_get_view_backend(struct wpe_gamepad_provider*, struct wpe_gamepad*);

/**
 * wpe_gamepad_provider_dispatch_gamepad_connected:
 * @provider: opaque libwpe's representation of gamepad provider.
 * @gamepad_id: application's gamepad device identifier.
 *
 * Method called by application (gamepad implementator) to inform
 * WPEWebKit that a new gamepad device is plugged.
 *
 * Since: 1.14
 */
WPE_EXPORT
void wpe_gamepad_provider_dispatch_gamepad_connected(struct wpe_gamepad_provider*, uintptr_t);

/**
 * wpe_gamepad_provider_dispatch_gamepad_disconnected:
 * @provider: opaque libwpe's representation of gamepad provider.
 * @gamepad_id: application's gamepad device identifier.
 *
 * Method called by application (gamepad implementator) to inform
 * WPEWebKit that a plugged gamepad device has been unplugged.
 *
 * Since: 1.14
 */
WPE_EXPORT
void wpe_gamepad_provider_dispatch_gamepad_disconnected(struct wpe_gamepad_provider*, uintptr_t);

/**
 * wpe_gamepad_create:
 * @provider:  provider of the gamepad to create.
 * @gamepad_id: opaque application's representation of gamepad provider.
 *
 * Method called by WPEWebKit to create an internal representation of a gamepad device.
 *
 * Returns: opaque libwpe's representation of a gamepad device.
 *
 * Since: 1.14
 */
WPE_EXPORT
struct wpe_gamepad* wpe_gamepad_create(struct wpe_gamepad_provider*, uintptr_t);

/**
 * wpe_gamepad_destroy:
 * @gamepad: opaque libwpe's representation of gamepad.
 *
 * Called by WPEWebkit to free the internal resources used by @gamepad
 * object.
 *
 * Since: 1.14
 */
WPE_EXPORT
void wpe_gamepad_destroy(struct wpe_gamepad*);

/**
 * wpe_gamepad_provider_set_client:
 * @gamepad: opaque libwpe's representation of gamepad.
 * @client_interface: WPEWebKit callbacks for gamepad devices events.
 * @client_data: WPEWebkit closure data.
 *
 * Sets WPEWebKit's callbacks for events in @gamepad.
 *
 * Since: 1.14
 */
WPE_EXPORT
void wpe_gamepad_set_client(struct wpe_gamepad*, const struct wpe_gamepad_client_interface*, void*);

/**
 * wpe_gamepad_get_id:
 * @gamepad: opaque libwpe's representation of gamepad.
 *
 * Gets the identification string for the @gamepad.
 *
 * Since: 1.14
 */
WPE_EXPORT
const char* wpe_gamepad_get_id(struct wpe_gamepad*);

/**
 * wpe_gamepad_dispatch_analog_button_changed:
 * @gamepad: opaque gamepad object.
 * @button: the analog button that changed its value.
 * @value: the new analog @button value.
 *
 * Method called by application (gamepad implementator). It reports to
 * WPEWebkit a change in the value  of analog @button.
 *
 * Since: 1.16
 */
WPE_EXPORT
void wpe_gamepad_dispatch_analog_button_changed(struct wpe_gamepad*, enum wpe_gamepad_button, double);

/**
 * wpe_gamepad_dispatch_button_changed:
 * @gamepad: opaque gamepad object.
 * @button: the standard button that changed its state.
 * @pressed: the new state: %TRUE pressed, otherwise released.
 *
 * Method called by application (gamepad implementator). It reports to
 * WPEWebkit a change in the status of @button.
 *
 * Since: 1.14
 */
WPE_EXPORT
void wpe_gamepad_dispatch_button_changed(struct wpe_gamepad*, enum wpe_gamepad_button, bool);

/**
 * wpe_gamepad_dispatch_axis_changed:
 * @gamepad: opaque gamepad object.
 * @axis: the standard axis that changed its state.
 * @value: the value of @axis
 *
 * Method called by application (gamepad implementator). It reports to
 * WPEWebkit a change in the position of @axis.
 *
 * Since: 1.14
 */
WPE_EXPORT
void wpe_gamepad_dispatch_axis_changed(struct wpe_gamepad*, enum wpe_gamepad_axis, double);

/**
 * wpe_gamepad_set_handler:
 * @provider_iface: (transfer none): Application callbacks for gamepad provider.
 * @gamepad_iface: (transfer none): Applications callbacks for gamepad device.
 *
 * Method called by the application (gamepad implementator) to
 * register, in libwpe, the callbacks for gamepad devices and gamepad
 * provider.
 *
 * Note that the last registered handlers will be used.
 *
 * Since: 1.14
 */
WPE_EXPORT
void wpe_gamepad_set_handler(const struct wpe_gamepad_provider_interface*, const struct wpe_gamepad_interface*);

#ifdef __cplusplus
}
#endif

#endif /* wpe_gamepad_h */
