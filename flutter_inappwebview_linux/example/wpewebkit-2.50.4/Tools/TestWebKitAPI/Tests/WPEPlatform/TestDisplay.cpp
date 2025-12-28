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

#include "WPEDisplayMock.h"
#include "WPEMockPlatformTest.h"

#if USE(LIBDRM)
#include <drm_fourcc.h>
#endif

namespace TestWebKitAPI {

static void testDisplayConnect(WPEMockPlatformTest* test, gconstpointer)
{
    GUniqueOutPtr<GError> error;
    g_assert_true(wpe_display_connect(test->display(), &error.outPtr()));
    g_assert_no_error(error.get());

    // Can't connect twice.
    g_assert_false(wpe_display_connect(test->display(), &error.outPtr()));
    g_assert_error(error.get(), WPE_DISPLAY_ERROR, WPE_DISPLAY_ERROR_CONNECTION_FAILED);
}

static void testDisplayPrimary(WPEMockPlatformTest* test, gconstpointer)
{
    // The first created display is always the primary.
    g_assert_true(wpe_display_get_primary() == test->display());

    GRefPtr<WPEDisplay> display2 = adoptGRef(wpeDisplayMockNew());
    test->assertObjectIsDeletedWhenTestFinishes(display2.get());
    g_assert_true(wpe_display_get_primary() == test->display());
    wpe_display_set_primary(display2.get());
    g_assert_true(wpe_display_get_primary() == display2.get());

    // If the primary display is destroyed, there's no primary unless explicitly set again.
    display2 = nullptr;
    g_assert_null(wpe_display_get_primary());

    wpe_display_set_primary(test->display());
    g_assert_true(wpe_display_get_primary() == test->display());
}

static void testDisplayKeymap(WPEMockPlatformTest* test, gconstpointer)
{
    // Default XKB keymap is returned when platform doesn't implement it.
    auto* keymap = wpe_display_get_keymap(test->display());
    g_assert_true(WPE_IS_KEYMAP_XKB(keymap));
    test->assertObjectIsDeletedWhenTestFinishes(keymap);
}

static void testDisplayDRMNodes(WPEMockPlatformTest* test, gconstpointer)
{
    g_assert_null(wpe_display_get_drm_device(test->display()));

    wpeDisplayMockUseFakeDRMNodes(WPE_DISPLAY_MOCK(test->display()), TRUE);
    auto* device = wpe_display_get_drm_device(test->display());
    g_assert_nonnull(device);
    g_assert_cmpstr(wpe_drm_device_get_primary_node(device), ==, "/dev/dri/mock0");
    g_assert_cmpstr(wpe_drm_device_get_render_node(device), ==, "/dev/dri/mockD128");
}

static void testDisplayDMABufFormats(WPEMockPlatformTest* test, gconstpointer)
{
    g_assert_null(wpe_display_get_preferred_dma_buf_formats(test->display()));

    wpeDisplayMockUseFakeDRMNodes(WPE_DISPLAY_MOCK(test->display()), TRUE);
    wpeDisplayMockUseFakeDMABufFormats(WPE_DISPLAY_MOCK(test->display()), TRUE);
    auto* formats = wpe_display_get_preferred_dma_buf_formats(test->display());
    g_assert_true(WPE_IS_BUFFER_DMA_BUF_FORMATS(formats));
    test->assertObjectIsDeletedWhenTestFinishes(formats);

#if USE(LIBDRM)
    auto* device = wpe_buffer_dma_buf_formats_get_device(formats);
    g_assert_nonnull(device);
    g_assert_cmpstr(wpe_drm_device_get_primary_node(device), ==, "/dev/dri/mock0");
    g_assert_cmpstr(wpe_drm_device_get_render_node(device), ==, "/dev/dri/mockD128");

    g_assert_cmpuint(wpe_buffer_dma_buf_formats_get_n_groups(formats), ==, 2);
    g_assert_cmpuint(wpe_buffer_dma_buf_formats_get_group_usage(formats, 0), ==, WPE_BUFFER_DMA_BUF_FORMAT_USAGE_SCANOUT);
    auto* targetDevice = wpe_buffer_dma_buf_formats_get_group_device(formats, 0);
    g_assert_nonnull(targetDevice);
    g_assert_cmpstr(wpe_drm_device_get_primary_node(targetDevice), ==, "/dev/dri/mock1");
    g_assert_null(wpe_drm_device_get_render_node(targetDevice));
    g_assert_cmpuint(wpe_buffer_dma_buf_formats_get_group_n_formats(formats, 0), ==, 1);
    g_assert_true(wpe_buffer_dma_buf_formats_get_format_fourcc(formats, 0, 0) == DRM_FORMAT_XRGB8888);
    auto* modifiers = wpe_buffer_dma_buf_formats_get_format_modifiers(formats, 0, 0);
    g_assert_cmpuint(modifiers->len, ==, 2);
    guint64* modifier = &g_array_index(modifiers, guint64, 0);
    g_assert_cmpuint(*modifier, ==, DRM_FORMAT_MOD_VIVANTE_SUPER_TILED);
    modifier = &g_array_index(modifiers, guint64, 1);
    g_assert_cmpuint(*modifier, ==, DRM_FORMAT_MOD_VIVANTE_TILED);

    g_assert_cmpuint(wpe_buffer_dma_buf_formats_get_group_usage(formats, 1), ==, WPE_BUFFER_DMA_BUF_FORMAT_USAGE_RENDERING);
    g_assert_null(wpe_buffer_dma_buf_formats_get_group_device(formats, 1));
    g_assert_cmpuint(wpe_buffer_dma_buf_formats_get_group_n_formats(formats, 1), ==, 2);
    g_assert_true(wpe_buffer_dma_buf_formats_get_format_fourcc(formats, 1, 0) == DRM_FORMAT_XRGB8888);
    modifiers = wpe_buffer_dma_buf_formats_get_format_modifiers(formats, 1, 0);
    g_assert_cmpuint(modifiers->len, ==, 1);
    modifier = &g_array_index(modifiers, guint64, 0);
    g_assert_cmpuint(*modifier, ==, DRM_FORMAT_MOD_LINEAR);
    g_assert_true(wpe_buffer_dma_buf_formats_get_format_fourcc(formats, 1, 1) == DRM_FORMAT_ARGB8888);
    modifiers = wpe_buffer_dma_buf_formats_get_format_modifiers(formats, 1, 1);
    g_assert_cmpuint(modifiers->len, ==, 1);
    modifier = &g_array_index(modifiers, guint64, 0);
    g_assert_cmpuint(*modifier, ==, DRM_FORMAT_MOD_LINEAR);
#endif
}

static void testDisplayExplicitSync(WPEMockPlatformTest* test, gconstpointer)
{
    g_assert_false(wpe_display_use_explicit_sync(test->display()));
    wpeDisplayMockSetUseExplicitSync(WPE_DISPLAY_MOCK(test->display()), TRUE);
    g_assert_true(wpe_display_use_explicit_sync(test->display()));
}

class WPEMockAvailableInputDevicesTest : public WPEMockPlatformTest {
public:
    WPE_PLATFORM_TEST_FIXTURE(WPEMockAvailableInputDevicesTest);

    WPEMockAvailableInputDevicesTest()
    {
        wpeDisplayMockSetInitialInputDevices(WPE_DISPLAY_MOCK(display()), static_cast<WPEAvailableInputDevices>(WPE_AVAILABLE_INPUT_DEVICE_MOUSE | WPE_AVAILABLE_INPUT_DEVICE_KEYBOARD));
        g_signal_connect_swapped(display(), "notify::available-input-devices", G_CALLBACK(+[](WPEMockAvailableInputDevicesTest* test) {
            test->m_propertyChanged = true;
        }), this);
    }

    ~WPEMockAvailableInputDevicesTest()
    {
        g_signal_handlers_disconnect_by_data(display(), this);
    }

    bool addDevice(WPEAvailableInputDevices device)
    {
        m_propertyChanged = false;
        wpeDisplayMockAddInputDevice(WPE_DISPLAY_MOCK(display()), device);
        return std::exchange(m_propertyChanged, false);
    }

    bool removeDevice(WPEAvailableInputDevices device)
    {
        m_propertyChanged = false;
        wpeDisplayMockRemoveInputDevice(WPE_DISPLAY_MOCK(display()), device);
        return std::exchange(m_propertyChanged, false);
    }

private:
    bool m_propertyChanged { false };
};

static void testDisplayAvailableInputDevices(WPEMockAvailableInputDevicesTest* test, gconstpointer)
{
    auto devices = wpe_display_get_available_input_devices(test->display());
    g_assert_true(devices & WPE_AVAILABLE_INPUT_DEVICE_MOUSE);
    g_assert_true(devices & WPE_AVAILABLE_INPUT_DEVICE_KEYBOARD);
    g_assert_false(devices & WPE_AVAILABLE_INPUT_DEVICE_TOUCHSCREEN);

    g_assert_true(test->addDevice(WPE_AVAILABLE_INPUT_DEVICE_TOUCHSCREEN));
    devices = wpe_display_get_available_input_devices(test->display());
    g_assert_true(devices & WPE_AVAILABLE_INPUT_DEVICE_MOUSE);
    g_assert_true(devices & WPE_AVAILABLE_INPUT_DEVICE_KEYBOARD);
    g_assert_true(devices & WPE_AVAILABLE_INPUT_DEVICE_TOUCHSCREEN);

    g_assert_false(test->addDevice(WPE_AVAILABLE_INPUT_DEVICE_MOUSE));
    g_assert_false(test->addDevice(WPE_AVAILABLE_INPUT_DEVICE_KEYBOARD));
    g_assert_false(test->addDevice(WPE_AVAILABLE_INPUT_DEVICE_TOUCHSCREEN));

    g_assert_true(test->removeDevice(WPE_AVAILABLE_INPUT_DEVICE_MOUSE));
    devices = wpe_display_get_available_input_devices(test->display());
    g_assert_false(devices & WPE_AVAILABLE_INPUT_DEVICE_MOUSE);
    g_assert_true(devices & WPE_AVAILABLE_INPUT_DEVICE_KEYBOARD);
    g_assert_true(devices & WPE_AVAILABLE_INPUT_DEVICE_TOUCHSCREEN);
    g_assert_false(test->removeDevice(WPE_AVAILABLE_INPUT_DEVICE_MOUSE));

    g_assert_true(test->removeDevice(WPE_AVAILABLE_INPUT_DEVICE_KEYBOARD));
    devices = wpe_display_get_available_input_devices(test->display());
    g_assert_false(devices & WPE_AVAILABLE_INPUT_DEVICE_MOUSE);
    g_assert_false(devices & WPE_AVAILABLE_INPUT_DEVICE_KEYBOARD);
    g_assert_true(devices & WPE_AVAILABLE_INPUT_DEVICE_TOUCHSCREEN);
    g_assert_false(test->removeDevice(WPE_AVAILABLE_INPUT_DEVICE_MOUSE));
    g_assert_false(test->removeDevice(WPE_AVAILABLE_INPUT_DEVICE_KEYBOARD));

    g_assert_true(test->removeDevice(WPE_AVAILABLE_INPUT_DEVICE_TOUCHSCREEN));
    devices = wpe_display_get_available_input_devices(test->display());
    g_assert_false(devices & WPE_AVAILABLE_INPUT_DEVICE_MOUSE);
    g_assert_false(devices & WPE_AVAILABLE_INPUT_DEVICE_KEYBOARD);
    g_assert_false(devices & WPE_AVAILABLE_INPUT_DEVICE_TOUCHSCREEN);
    g_assert_false(test->removeDevice(WPE_AVAILABLE_INPUT_DEVICE_MOUSE));
    g_assert_false(test->removeDevice(WPE_AVAILABLE_INPUT_DEVICE_KEYBOARD));
    g_assert_false(test->removeDevice(WPE_AVAILABLE_INPUT_DEVICE_TOUCHSCREEN));
}

void beforeAll()
{
    WPEMockPlatformTest::add("Display", "connect", testDisplayConnect);
    WPEMockPlatformTest::add("Display", "primary", testDisplayPrimary);
    WPEMockPlatformTest::add("Display", "keymap", testDisplayKeymap);
    WPEMockPlatformTest::add("Display", "drm-nodes", testDisplayDRMNodes);
    WPEMockPlatformTest::add("Display", "dmabuf-formats", testDisplayDMABufFormats);
    WPEMockPlatformTest::add("Display", "explicit-sync", testDisplayExplicitSync);
    WPEMockAvailableInputDevicesTest::add("Display", "available-input-devices", testDisplayAvailableInputDevices);
}

void afterAll()
{
}

} // namespace TestWebKitAPI
