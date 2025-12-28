/*
 * Copyright (C) 2019 Igalia S.L.
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

#include "wpe-bridge-client-protocol.h"
#include "wpe-dmabuf-pool-client-protocol.h"
#include "ipc.h"
#include "ws-types.h"
#include <glib.h>
#include <wayland-client.h>

namespace WS {

class BaseBackend {
protected:
    BaseBackend(int hostFD);
    ~BaseBackend();

public:
    struct wl_display* display() const { return m_wl.display; }

    ClientImplementationType type() const { return m_type; }

private:
    static const struct wl_registry_listener s_registryListener;
    static const struct wpe_bridge_listener s_bridgeListener;

    struct {
        struct wl_display* display;
        struct wpe_bridge* wpeBridge { nullptr };
    } m_wl;

    ClientImplementationType m_type { ClientImplementationType::Invalid };
};

class BaseTarget {
public:
    class Impl {
    public:
        virtual ~Impl() = default;
        virtual void dispatchFrameComplete() = 0;
    };

    struct wl_display* display() const { return m_backend->display(); }
    struct wl_event_queue* eventQueue() const { return m_wl.eventQueue; }
    struct wl_surface* surface() const { return m_wl.surface; }
    struct wpe_dmabuf_pool* wpeDmabufPool() const { return m_wl.wpeDmabufPool; }

    void requestFrame();

protected:
    BaseTarget(int hostFD, Impl&);
    ~BaseTarget();

    void initialize(BaseBackend&);

private:
    void frameComplete();
    void bridgeConnected(uint32_t bridgeID);

    static const struct wl_registry_listener s_registryListener;
    static const struct wl_callback_listener s_callbackListener;
    static const struct wpe_bridge_listener s_bridgeListener;

    Impl& m_impl;
    BaseBackend* m_backend { nullptr };

    struct {
        std::unique_ptr<FdoIPC::Connection> socket;
        GSource* wlSource { nullptr };
    } m_glib;

    struct {
        struct wl_event_queue* eventQueue { nullptr };
        struct wl_compositor* compositor { nullptr };
        struct wpe_bridge* wpeBridge { nullptr };
        struct wpe_dmabuf_pool_manager* wpeDmabufPoolManager { nullptr };

        uint32_t wpeBridgeId { 0 };
        struct wl_surface* surface { nullptr };
        struct wpe_dmabuf_pool* wpeDmabufPool { nullptr };
        struct wl_callback* frameCallback { nullptr };
    } m_wl;
};

GSource* ws_polling_source_new(const char* name, struct wl_display*, struct wl_event_queue*);

} // namespace WS
