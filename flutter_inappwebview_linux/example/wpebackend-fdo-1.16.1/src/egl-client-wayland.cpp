/*
 * Copyright (C) 2020 Igalia S.L.
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

#include <wayland-egl.h>

#include "egl-client-wayland.h"

#include "ws-client.h"

namespace WS {
namespace EGLClient {

BackendWayland::BackendWayland(BaseBackend& base)
    : m_base(base)
{
}

BackendWayland::~BackendWayland() = default;

EGLNativeDisplayType BackendWayland::nativeDisplay() const
{
    return m_base.display();
}

uint32_t BackendWayland::platform() const
{
    return 0;
}


TargetWayland::TargetWayland(BaseTarget& base, uint32_t width, uint32_t height)
    : m_base(base)
{
    m_egl.window = wl_egl_window_create(base.surface(), width, height);
}

TargetWayland::~TargetWayland()
{
    g_clear_pointer(&m_egl.window, wl_egl_window_destroy);
}

EGLNativeWindowType TargetWayland::nativeWindow() const
{
    return (EGLNativeWindowType) m_egl.window;
}

void TargetWayland::resize(uint32_t width, uint32_t height)
{
    wl_egl_window_resize(m_egl.window, width, height, 0, 0);
}

void TargetWayland::frameWillRender()
{
    m_base.requestFrame();
}

void TargetWayland::frameRendered()
{
}

void TargetWayland::deinitialize()
{
}

} } // namespace WS::EGLClient
