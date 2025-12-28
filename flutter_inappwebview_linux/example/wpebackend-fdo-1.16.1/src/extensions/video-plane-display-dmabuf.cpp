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

#include "../../include/wpe/extensions/video-plane-display-dmabuf.h"

#include "../ws-client.h"
#include "wpe-video-plane-display-dmabuf-client-protocol.h"
#include <wpe/wpe-egl.h>
#include <cstring>

namespace Impl {

class DmaBufThread {
public:
    static DmaBufThread& singleton();
    static void initialize(struct wl_display*);

    struct wl_event_queue* eventQueue() const { return m_wl.eventQueue; }

private:
    static DmaBufThread* s_thread;
    static gpointer s_threadEntrypoint(gpointer);

    explicit DmaBufThread(struct wl_display*);

    struct ThreadSpawn {
        GMutex mutex;
        GCond cond;
        DmaBufThread* thread;
    };

    struct {
        struct wl_display* display;
        struct wl_event_queue* eventQueue;
    } m_wl;

    struct {
        GThread* thread;
        GSource* wlSource;
    } m_glib;
};

DmaBufThread* DmaBufThread::s_thread = nullptr;

DmaBufThread& DmaBufThread::singleton()
{
    return *s_thread;
}

void DmaBufThread::initialize(struct wl_display* display)
{
    if (s_thread) {
        if (s_thread->m_wl.display != display)
            g_error("DmaBufThread: tried to reinitialize with a different wl_display object");
    }

    if (!s_thread)
        s_thread = new DmaBufThread(display);
}

DmaBufThread::DmaBufThread(struct wl_display* display)
{
    m_wl.display = display;
    m_wl.eventQueue = wl_display_create_queue(m_wl.display);

    {
        ThreadSpawn threadSpawn;
        threadSpawn.thread = this;

        g_mutex_init(&threadSpawn.mutex);
        g_cond_init(&threadSpawn.cond);

        g_mutex_lock(&threadSpawn.mutex);

        m_glib.thread = g_thread_new("WPEBackend-fdo::video-plane-display-thread", s_threadEntrypoint, &threadSpawn);
        g_cond_wait(&threadSpawn.cond, &threadSpawn.mutex);

        g_mutex_unlock(&threadSpawn.mutex);

        g_mutex_clear(&threadSpawn.mutex);
        g_cond_clear(&threadSpawn.cond);
    }
}

gpointer DmaBufThread::s_threadEntrypoint(gpointer data)
{
    auto& threadSpawn = *reinterpret_cast<ThreadSpawn*>(data);
    g_mutex_lock(&threadSpawn.mutex);

    auto& thread = *threadSpawn.thread;

    GMainContext* context = g_main_context_new();
    GMainLoop* loop = g_main_loop_new(context, FALSE);

    g_main_context_push_thread_default(context);

    thread.m_glib.wlSource = WS::ws_polling_source_new("WPEBackend-fdo::video-plane-display", thread.m_wl.display, thread.m_wl.eventQueue);
    // The source is attached in the idle callback.

    {
        GSource* source = g_idle_source_new();
        g_source_set_callback(source,
            [](gpointer data) -> gboolean {
                auto& threadSpawn = *reinterpret_cast<ThreadSpawn*>(data);

                auto& thread = *threadSpawn.thread;
                g_source_attach(thread.m_glib.wlSource, g_main_context_get_thread_default());

                g_cond_signal(&threadSpawn.cond);
                g_mutex_unlock(&threadSpawn.mutex);
                return FALSE;
            }, &threadSpawn, nullptr);
        g_source_attach(source, context);
        g_source_unref(source);
    }

    g_main_loop_run(loop);

    g_main_loop_unref(loop);
    g_main_context_pop_thread_default(context);
    g_main_context_unref(context);
    return nullptr;
}

class DmaBuf {
public:
    DmaBuf(WS::BaseBackend& backend)
    {
        struct wl_display* display = backend.display();
        DmaBufThread::initialize(display);

        struct wl_event_queue* eventQueue = wl_display_create_queue(display);

        struct wl_registry* registry = wl_display_get_registry(display);
        wl_proxy_set_queue(reinterpret_cast<struct wl_proxy*>(registry), eventQueue);
        wl_registry_add_listener(registry, &s_registryListener, this);
        wl_display_roundtrip_queue(display, eventQueue);
        wl_registry_destroy(registry);

        wl_event_queue_destroy(eventQueue);
    }

    ~DmaBuf()
    {
        if (m_wl.videoPlaneDisplayDmaBuf)
            wpe_video_plane_display_dmabuf_destroy(m_wl.videoPlaneDisplayDmaBuf);
    }

    void update(uint32_t id, int fd, int32_t x, int32_t y, int32_t width, int32_t height, uint32_t stride,
        wpe_video_plane_display_dmabuf_source_update_release_notify_t notify, void* notify_data)
    {
        if (!m_wl.videoPlaneDisplayDmaBuf) {
            notify(notify_data);
            return;
        }

        auto* update = wpe_video_plane_display_dmabuf_create_update(m_wl.videoPlaneDisplayDmaBuf, id, fd, x, y, width, height, stride);

        wl_proxy_set_queue(reinterpret_cast<struct wl_proxy*>(update), DmaBufThread::singleton().eventQueue());
        wpe_video_plane_display_dmabuf_update_add_listener(update, &s_videoPlaneDisplayUpdateListener, new ListenerData { notify, notify_data });
    }

    void end_of_stream(uint32_t id)
    {
        if (m_wl.videoPlaneDisplayDmaBuf)
            wpe_video_plane_display_dmabuf_end_of_stream(m_wl.videoPlaneDisplayDmaBuf, id);
    }

private:
    static const struct wl_registry_listener s_registryListener;
    static const struct wpe_video_plane_display_dmabuf_update_listener s_videoPlaneDisplayUpdateListener;

    struct ListenerData {
        wpe_video_plane_display_dmabuf_source_update_release_notify_t notify;
        void* notify_data;
    };

    struct {
        struct wpe_video_plane_display_dmabuf* videoPlaneDisplayDmaBuf { nullptr };
    } m_wl;
};

const struct wl_registry_listener DmaBuf::s_registryListener = {
    // global
    [](void* data, struct wl_registry* registry, uint32_t name, const char* interface, uint32_t)
    {
        auto& impl = *reinterpret_cast<DmaBuf*>(data);
        if (!std::strcmp(interface, "wpe_video_plane_display_dmabuf"))
            impl.m_wl.videoPlaneDisplayDmaBuf = static_cast<struct wpe_video_plane_display_dmabuf*>(wl_registry_bind(registry, name, &wpe_video_plane_display_dmabuf_interface, 1));
    },
    // global_remove
    [](void*, struct wl_registry*, uint32_t) { },
};

const struct wpe_video_plane_display_dmabuf_update_listener DmaBuf::s_videoPlaneDisplayUpdateListener = {
    // release
    [](void* data, struct wpe_video_plane_display_dmabuf_update* update)
    {
        auto* listenerData = static_cast<ListenerData*>(data);
        if (listenerData->notify)
            listenerData->notify(listenerData->notify_data);
        delete listenerData;

        wpe_video_plane_display_dmabuf_update_destroy(update);
    },
};

}

extern "C" {

__attribute__((visibility("default")))
struct wpe_video_plane_display_dmabuf_source*
wpe_video_plane_display_dmabuf_source_create(struct wpe_renderer_backend_egl* backend)
{
    auto* base = reinterpret_cast<struct wpe_renderer_backend_egl_base*>(backend);
    auto* impl = new Impl::DmaBuf(*static_cast<WS::BaseBackend*>(base->interface_data));
    return reinterpret_cast<struct wpe_video_plane_display_dmabuf_source*>(impl);
}

__attribute__((visibility("default")))
void
wpe_video_plane_display_dmabuf_source_destroy(struct wpe_video_plane_display_dmabuf_source* source)
{
    delete reinterpret_cast<Impl::DmaBuf*>(source);
}

__attribute__((visibility("default")))
void
wpe_video_plane_display_dmabuf_source_update(struct wpe_video_plane_display_dmabuf_source* dmabuf_source, int fd, int32_t x, int32_t y, int32_t width, int32_t height, uint32_t stride,
    wpe_video_plane_display_dmabuf_source_update_release_notify_t notify, void* notify_data)
{
    auto& impl = *reinterpret_cast<Impl::DmaBuf*>(dmabuf_source);
    uint32_t id = reinterpret_cast<uintptr_t>(dmabuf_source);
    impl.update(id, fd, x, y, width, height, stride, notify, notify_data);
}

__attribute__((visibility("default")))
void
wpe_video_plane_display_dmabuf_source_end_of_stream(struct wpe_video_plane_display_dmabuf_source* dmabuf_source)
{
    auto& impl = *reinterpret_cast<Impl::DmaBuf*>(dmabuf_source);
    uint32_t id = reinterpret_cast<uintptr_t>(dmabuf_source);
    impl.end_of_stream(id);
}

}
