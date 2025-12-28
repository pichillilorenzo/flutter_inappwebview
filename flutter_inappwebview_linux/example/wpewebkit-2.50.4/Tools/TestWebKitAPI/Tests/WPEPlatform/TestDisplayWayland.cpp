/*
 * Copyright (C) 2025 Igalia, S.L.
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
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. AND ITS CONTRIBUTORS ``AS IS''
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL APPLE INC. OR ITS CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "config.h"

#include "WPEWaylandPlatformTest.h"
#include <wpe/wayland/wpe-wayland.h>

namespace TestWebKitAPI {

#define skipIfNotUnderWayland() \
    { \
        static const char* display = g_getenv("WAYLAND_DISPLAY"); \
        if (!display || !*display) { \
            g_test_skip("Not running under Wayland"); \
            return; \
        } \
    }

static void testDisplayWaylandConnect(WPEWaylandPlatformTest* test, gconstpointer)
{
    skipIfNotUnderWayland();

    GUniqueOutPtr<GError> error;
    g_assert_true(wpe_display_connect(test->display(), &error.outPtr()));
    g_assert_nonnull(wpe_display_wayland_get_wl_display(WPE_DISPLAY_WAYLAND(test->display())));
    g_assert_no_error(error.get());

    // Can't connect twice.
    g_assert_false(wpe_display_connect(test->display(), &error.outPtr()));
    g_assert_error(error.get(), WPE_DISPLAY_ERROR, WPE_DISPLAY_ERROR_CONNECTION_FAILED);

    // Connect to invalid display fails.
    GRefPtr<WPEDisplay> display = adoptGRef(wpe_display_wayland_new());
    g_assert_true(WPE_IS_DISPLAY_WAYLAND(display.get()));
    g_assert_false(wpe_display_wayland_connect(WPE_DISPLAY_WAYLAND(display.get()), "invalid", &error.outPtr()));
    g_assert_error(error.get(), WPE_DISPLAY_ERROR, WPE_DISPLAY_ERROR_CONNECTION_FAILED);

    // Connect to the default display using wpe_display_wayland_connect().
    g_assert_true(wpe_display_wayland_connect(WPE_DISPLAY_WAYLAND(display.get()), nullptr, &error.outPtr()));
    g_assert_no_error(error.get());
    g_assert_nonnull(wpe_display_wayland_get_wl_display(WPE_DISPLAY_WAYLAND(display.get())));
}

void beforeAll()
{
    WPEWaylandPlatformTest::add("DisplayWayland", "connect", testDisplayWaylandConnect);
}

void afterAll()
{
}

} // namespace TestWebKitAPI
