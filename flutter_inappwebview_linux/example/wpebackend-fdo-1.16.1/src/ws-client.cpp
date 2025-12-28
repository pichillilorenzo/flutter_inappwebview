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

#include "ws-client.h"

#include "ipc-messages.h"
#include <cstring>

namespace WS {

struct TargetSource {
    static GSourceFuncs s_sourceFuncs;

    GSource source;
    GPollFD pfd;
    struct wl_display* display;
    struct wl_event_queue* queue;
    bool isReading;
};

GSourceFuncs TargetSource::s_sourceFuncs = {
    // prepare
    [](GSource* base, gint* timeout) -> gboolean
    {
        auto& source = *reinterpret_cast<TargetSource*>(base);

        *timeout = -1;

        if (source.isReading)
            return FALSE;

        // If there are pending dispatches on this queue we return TRUE to proceed to dispatching ASAP.
        if (wl_display_prepare_read_queue(source.display, source.queue) != 0)
            return TRUE;

        source.isReading = true;

        // We take up this opportunity to flush the display object, but
        // otherwise we're not able to determine whether there are any
        // pending dispatches (that would allow us skip the polling)
        // without scheduling a read on the wl_display object.
        wl_display_flush(source.display);
        return FALSE;
    },
    // check
    [](GSource* base) -> gboolean
    {
        auto& source = *reinterpret_cast<TargetSource*>(base);

        // Only perform the read if input was made available during polling.
        // Error during read is noted and will be handled in the following
        // dispatch callback. If no input is available, the read is canceled.
        // revents value is zeroed out in any case.
        if (source.isReading) {
            source.isReading = false;

            if (source.pfd.revents & G_IO_IN) {
                if (wl_display_read_events(source.display) == 0)
                    return TRUE;
            } else
                wl_display_cancel_read(source.display);
        }

        return source.pfd.revents;
    },
    // dispatch
    [](GSource* base, GSourceFunc, gpointer) -> gboolean
    {
        auto& source = *reinterpret_cast<TargetSource*>(base);

        // Remove the source if any error was registered.
        if (source.pfd.revents & (G_IO_ERR | G_IO_HUP))
            return FALSE;

        // Dispatch any pending events. The source is removed in case of
        // an error occurring during this step.
        if (wl_display_dispatch_queue_pending(source.display, source.queue) < 0)
            return FALSE;

        source.pfd.revents = 0;
        return TRUE;
    },
    // finalize
    [](GSource *base)
    {
        auto& source = *reinterpret_cast<TargetSource*>(base);

        if (source.isReading) {
            wl_display_cancel_read(source.display);
            source.isReading = false;
        }
    },
    nullptr, // closure_callback
    nullptr, // closure_marshall
};


BaseBackend::BaseBackend(int hostFD)
{
    m_wl.display = wl_display_connect_to_fd(hostFD);

    struct wl_registry* registry = wl_display_get_registry(m_wl.display);
    wl_registry_add_listener(registry, &s_registryListener, this);
    wl_display_roundtrip(m_wl.display);
    wl_registry_destroy(registry);

    if (!m_wl.wpeBridge)
        g_error("Failed to bind wpe_bridge");

    wpe_bridge_add_listener(m_wl.wpeBridge, &s_bridgeListener, this);
    wpe_bridge_initialize(m_wl.wpeBridge);
    wl_display_roundtrip(m_wl.display);
}

BaseBackend::~BaseBackend()
{
    g_clear_pointer(&m_wl.wpeBridge, wpe_bridge_destroy);
    g_clear_pointer(&m_wl.display, wl_display_disconnect);
}

const struct wl_registry_listener BaseBackend::s_registryListener = {
    // global
    [](void* data, struct wl_registry* registry, uint32_t name, const char* interface, uint32_t)
    {
        auto& backend = *reinterpret_cast<BaseBackend*>(data);

        if (!std::strcmp(interface, "wpe_bridge"))
            backend.m_wl.wpeBridge = static_cast<struct wpe_bridge*>(wl_registry_bind(registry, name, &wpe_bridge_interface, 1));
    },
    // global_remove
    [](void*, struct wl_registry*, uint32_t) { },
};

const struct wpe_bridge_listener BaseBackend::s_bridgeListener = {
    // implementation_info
    [](void* data, struct wpe_bridge*, uint32_t implementationType)
    {
        auto& backend = *reinterpret_cast<BaseBackend*>(data);
        switch (implementationType) {
        case WPE_BRIDGE_CLIENT_IMPLEMENTATION_TYPE_WAYLAND:
            backend.m_type = ClientImplementationType::Wayland;
            break;
        case WPE_BRIDGE_CLIENT_IMPLEMENTATION_TYPE_DMABUF_POOL:
            backend.m_type = ClientImplementationType::DmabufPool;
            break;
        default:
            break;
        }
    },
    // connected
    [](void* data, struct wpe_bridge*, uint32_t) { },
};


BaseTarget::BaseTarget(int hostFD, Impl& impl)
    : m_impl(impl)
{
    m_glib.socket = FdoIPC::Connection::create(hostFD);
}

BaseTarget::~BaseTarget()
{
    if (m_wl.wpeBridgeId && m_glib.socket)
        m_glib.socket->send(FdoIPC::Messages::UnregisterSurface, m_wl.wpeBridgeId);

    g_clear_pointer(&m_wl.frameCallback, wl_callback_destroy);
    g_clear_pointer(&m_wl.surface, wl_surface_destroy);
    g_clear_pointer(&m_wl.wpeDmabufPool, wpe_dmabuf_pool_destroy);

    g_clear_pointer(&m_wl.wpeDmabufPoolManager, wpe_dmabuf_pool_manager_destroy);
    g_clear_pointer(&m_wl.wpeBridge, wpe_bridge_destroy);
    g_clear_pointer(&m_wl.compositor, wl_compositor_destroy);
    g_clear_pointer(&m_wl.eventQueue, wl_event_queue_destroy);

    if (m_glib.wlSource) {
        g_source_destroy(m_glib.wlSource);
        g_source_unref(m_glib.wlSource);
    }
}

void BaseTarget::initialize(BaseBackend& backend)
{
    m_backend = &backend;
    struct wl_display* display = backend.display();

    m_wl.eventQueue = wl_display_create_queue(display);

    struct wl_registry* registry = wl_display_get_registry(display);
    wl_proxy_set_queue(reinterpret_cast<struct wl_proxy*>(registry), m_wl.eventQueue);
    wl_registry_add_listener(registry, &s_registryListener, this);
    wl_display_roundtrip_queue(display, m_wl.eventQueue);
    wl_registry_destroy(registry);

    if (!m_wl.compositor)
        g_error("Failed to bind wl_compositor");
    if (!m_wl.wpeBridge)
        g_error("Failed to bind wpe_bridge");

    m_wl.surface = wl_compositor_create_surface(m_wl.compositor);
    wl_proxy_set_queue(reinterpret_cast<struct wl_proxy*>(m_wl.surface), m_wl.eventQueue);

    m_wl.wpeDmabufPool = wpe_dmabuf_pool_manager_create_pool(m_wl.wpeDmabufPoolManager, m_wl.surface);
    wl_proxy_set_queue(reinterpret_cast<struct wl_proxy*>(m_wl.wpeDmabufPool), m_wl.eventQueue);

    m_glib.wlSource = ws_polling_source_new("WPEBackend-fdo::wayland", display, m_wl.eventQueue);
    g_source_attach(m_glib.wlSource, g_main_context_get_thread_default());

    wpe_bridge_add_listener(m_wl.wpeBridge, &s_bridgeListener, this);
    wpe_bridge_connect(m_wl.wpeBridge, m_wl.surface);
    wl_display_roundtrip_queue(display, m_wl.eventQueue);
}

void BaseTarget::requestFrame()
{
    if (m_wl.frameCallback)
        g_error("BaseTarget::requestFrame(): A frame callback was already installed.");

    m_wl.frameCallback = wl_surface_frame(m_wl.surface);
    wl_callback_add_listener(m_wl.frameCallback, &s_callbackListener, this);
}

void BaseTarget::frameComplete()
{
    g_clear_pointer(&m_wl.frameCallback, wl_callback_destroy);
    m_impl.dispatchFrameComplete();
}

void BaseTarget::bridgeConnected(uint32_t bridgeID)
{
    m_wl.wpeBridgeId = bridgeID;
    if (m_glib.socket)
        m_glib.socket->send(FdoIPC::Messages::RegisterSurface, bridgeID);
}

const struct wl_registry_listener BaseTarget::s_registryListener = {
    // global
    [](void* data, struct wl_registry* registry, uint32_t name, const char* interface, uint32_t)
    {
        auto& target = *reinterpret_cast<BaseTarget*>(data);

        if (!std::strcmp(interface, "wl_compositor"))
            target.m_wl.compositor = static_cast<struct wl_compositor*>(wl_registry_bind(registry, name, &wl_compositor_interface, 1));
        if (!std::strcmp(interface, "wpe_bridge"))
            target.m_wl.wpeBridge = static_cast<struct wpe_bridge*>(wl_registry_bind(registry, name, &wpe_bridge_interface, 1));
        if (!std::strcmp(interface, "wpe_dmabuf_pool_manager"))
            target.m_wl.wpeDmabufPoolManager = static_cast<struct wpe_dmabuf_pool_manager*>(wl_registry_bind(registry, name, &wpe_dmabuf_pool_manager_interface, 1));
    },
    // global_remove
    [](void*, struct wl_registry*, uint32_t) { },
};

const struct wl_callback_listener BaseTarget::s_callbackListener = {
    // done
    [](void* data, struct wl_callback*, uint32_t time)
    {
        static_cast<BaseTarget*>(data)->frameComplete();
    },
};

const struct wpe_bridge_listener BaseTarget::s_bridgeListener = {
    // implementation_info
    [](void*, struct wpe_bridge*, uint32_t) { },
    // connected
    [](void* data, struct wpe_bridge*, uint32_t id)
    {
        static_cast<BaseTarget*>(data)->bridgeConnected(id);
    },
};


GSource* ws_polling_source_new(const char* name, struct wl_display* display, struct wl_event_queue* eventQueue)
{
    GSource* wlSource = g_source_new(&TargetSource::s_sourceFuncs, sizeof(TargetSource));
    auto& source = *reinterpret_cast<TargetSource*>(wlSource);
    source.pfd.fd = wl_display_get_fd(display);
    source.pfd.events = G_IO_IN | G_IO_ERR | G_IO_HUP;
    source.pfd.revents = 0;
    source.display = display;
    source.queue = eventQueue;
    source.isReading = false;

    g_source_add_poll(wlSource, &source.pfd);
    g_source_set_name(wlSource, name);
    g_source_set_can_recurse(wlSource, TRUE);
    return wlSource;
}

} // namespace WS
