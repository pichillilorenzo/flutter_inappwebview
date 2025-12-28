/*
 * Copyright (C) 2017, 2018 Igalia S.L.
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

// Should be included early to force through the Wayland EGL platform
#include <wayland-egl.h>
#include <epoxy/egl.h>

#include <wpe/wpe-egl.h>

#include "egl-client.h"
#include "egl-client-dmabuf-pool.h"
#include "egl-client-wayland.h"
#include "interfaces.h"
#include "ws-client.h"

namespace {

class Backend final : public WS::BaseBackend {
public:
    Backend(int hostFD)
        : WS::BaseBackend(hostFD)
    {
        switch (type()) {
        case WS::ClientImplementationType::Invalid:
            g_error("Backend: invalid valid client implementation");
            break;
        case WS::ClientImplementationType::DmabufPool:
            m_impl = WS::EGLClient::BackendImpl::create<WS::EGLClient::BackendDmabufPool>(*this);
            break;
        case WS::ClientImplementationType::Wayland:
            m_impl = WS::EGLClient::BackendImpl::create<WS::EGLClient::BackendWayland>(*this);
            break;
        }
    }

    ~Backend() = default;

    using WS::BaseBackend::display;

    std::unique_ptr<WS::EGLClient::BackendImpl> m_impl;
};

class Target final : public WS::BaseTarget, public WS::BaseTarget::Impl {
public:
    Target(struct wpe_renderer_backend_egl_target* target, int hostFD)
        : WS::BaseTarget(hostFD, *this)
        , m_target(target)
    { }

    ~Target()
    {
        m_impl = nullptr;
        m_target = nullptr;
    }

    void initialize(Backend& backend, uint32_t width, uint32_t height)
    {
        WS::BaseTarget::initialize(backend);

        switch (backend.type()) {
        case WS::ClientImplementationType::Invalid:
            g_error("Target: invalid valid client implementation");
            break;
        case WS::ClientImplementationType::DmabufPool:
            m_impl = WS::EGLClient::TargetImpl::create<WS::EGLClient::TargetDmabufPool>(*this, width, height);
            break;
        case WS::ClientImplementationType::Wayland:
            m_impl = WS::EGLClient::TargetImpl::create<WS::EGLClient::TargetWayland>(*this, width, height);
            break;
        }
    }

    using WS::BaseTarget::requestFrame;

    std::unique_ptr<WS::EGLClient::TargetImpl> m_impl;

private:
    // WS::BaseTarget::Impl
    void dispatchFrameComplete() override
    {
        wpe_renderer_backend_egl_target_dispatch_frame_complete(m_target);
    }

    struct wpe_renderer_backend_egl_target* m_target { nullptr };
};

} // namespace

struct wpe_renderer_backend_egl_interface fdo_renderer_backend_egl = {
    // create
    [](int host_fd) -> void*
    {
        return new Backend(host_fd);
    },
    // destroy
    [](void* data)
    {
        auto* backend = reinterpret_cast<Backend*>(data);
        delete backend;
    },
    // get_native_display
    [](void* data) -> EGLNativeDisplayType
    {
        auto& backend = *reinterpret_cast<Backend*>(data);
        return backend.m_impl->nativeDisplay();
    },
    // get_platform
    [](void* data) -> uint32_t
    {
        auto& backend = *reinterpret_cast<Backend*>(data);
        return backend.m_impl->platform();
    },
};

struct wpe_renderer_backend_egl_target_interface fdo_renderer_backend_egl_target = {
    // create
    [](struct wpe_renderer_backend_egl_target* target, int host_fd) -> void*
    {
        return new Target(target, host_fd);
    },
    // destroy
    [](void* data)
    {
        auto* target = reinterpret_cast<Target*>(data);
        delete target;
    },
    // initialize
    [](void* data, void* backend_data, uint32_t width, uint32_t height)
    {
        auto& target = *reinterpret_cast<Target*>(data);
        auto& backend = *reinterpret_cast<Backend*>(backend_data);
        target.initialize(backend, width, height);
    },
    // get_native_window
    [](void* data) -> EGLNativeWindowType
    {
        auto& target = *reinterpret_cast<Target*>(data);
        return target.m_impl->nativeWindow();
    },
    // resize
    [](void* data, uint32_t width, uint32_t height)
    {
        auto& target = *reinterpret_cast<Target*>(data);
        target.m_impl->resize(width, height);
    },
    // frame_will_render
    [](void* data)
    {
        auto& target = *reinterpret_cast<Target*>(data);
        target.m_impl->frameWillRender();
    },
    // frame_rendered
    [](void* data)
    {
        auto& target = *reinterpret_cast<Target*>(data);
        target.m_impl->frameRendered();
    },
#if WPE_CHECK_VERSION(1,9,1)
    // deinitialize
    [](void* data)
    {
        auto& target = *reinterpret_cast<Target*>(data);
        target.m_impl->deinitialize();
    },
#endif
};

struct wpe_renderer_backend_egl_offscreen_target_interface fdo_renderer_backend_egl_offscreen_target = {
    // create
    []() -> void*
    {
        return nullptr;
    },
    // destroy
    [](void* data)
    {
    },
    // initialize
    [](void* data, void* backend_data)
    {
    },
    // get_native_window
    [](void* data) -> EGLNativeWindowType
    {
        return nullptr;
    },
};
