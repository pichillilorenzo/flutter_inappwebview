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

#pragma once

#include "egl-client.h"

struct wl_egl_window;

namespace WS {
namespace EGLClient {

class BackendWayland final : public BackendImpl {
public:
    BackendWayland(BaseBackend&);
    virtual ~BackendWayland();

    EGLNativeDisplayType nativeDisplay() const override;
    uint32_t platform() const override;

private:
    BaseBackend& m_base;
};

class TargetWayland final : public TargetImpl {
public:
    TargetWayland(BaseTarget&, uint32_t width, uint32_t height);
    virtual ~TargetWayland();

    EGLNativeWindowType nativeWindow() const override;

    void resize(uint32_t width, uint32_t height) override;

    void frameWillRender() override;
    void frameRendered() override;

    void deinitialize() override;

private:
    BaseTarget& m_base;

    struct {
        struct wl_egl_window* window;
    } m_egl;
};

} } // namespace WS::EGLClient
