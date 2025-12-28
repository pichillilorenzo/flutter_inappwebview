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

#include "../../include/wpe/extensions/audio.h"

#include "../ws-client.h"
#include "wpe-audio-client-protocol.h"
#include <wpe/wpe-egl.h>
#include <cstring>

namespace Impl {

class AudioThread {
public:
    static AudioThread& singleton();
    static void initialize(struct wl_display*);

    struct wl_event_queue* eventQueue() const { return m_wl.eventQueue; }

private:
    static AudioThread* s_thread;
    static gpointer s_threadEntrypoint(gpointer);

    AudioThread(struct wl_display*);

    struct ThreadSpawn {
        GMutex mutex;
        GCond cond;
        AudioThread* thread;
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

AudioThread* AudioThread::s_thread = nullptr;

AudioThread& AudioThread::singleton()
{
    return *s_thread;
}

void AudioThread::initialize(struct wl_display* display)
{
    if (s_thread) {
        if (s_thread->m_wl.display != display)
            g_error("AudioThread: tried to reinitialize with a different wl_display object");
    }

    if (!s_thread)
        s_thread = new AudioThread(display);
}

AudioThread::AudioThread(struct wl_display* display)
{
    m_wl.display = display;
    m_wl.eventQueue = wl_display_create_queue(m_wl.display);

    {
        ThreadSpawn threadSpawn;
        threadSpawn.thread = this;

        g_mutex_init(&threadSpawn.mutex);
        g_cond_init(&threadSpawn.cond);

        g_mutex_lock(&threadSpawn.mutex);

        m_glib.thread = g_thread_new("WPEBackend-fdo::audio-thread", s_threadEntrypoint, &threadSpawn);
        g_cond_wait(&threadSpawn.cond, &threadSpawn.mutex);

        g_mutex_unlock(&threadSpawn.mutex);

        g_mutex_clear(&threadSpawn.mutex);
        g_cond_clear(&threadSpawn.cond);
    }
}

gpointer AudioThread::s_threadEntrypoint(gpointer data)
{
    auto& threadSpawn = *reinterpret_cast<ThreadSpawn*>(data);
    g_mutex_lock(&threadSpawn.mutex);

    auto& thread = *threadSpawn.thread;

    GMainContext* context = g_main_context_new();
    GMainLoop* loop = g_main_loop_new(context, FALSE);

    g_main_context_push_thread_default(context);

    thread.m_glib.wlSource = WS::ws_polling_source_new("WPEBackend-fdo::audio", thread.m_wl.display, thread.m_wl.eventQueue);
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

class Audio {
public:
    Audio(WS::BaseBackend& backend)
    {
        struct wl_display* display = backend.display();
        AudioThread::initialize(display);

        struct wl_event_queue* eventQueue = wl_display_create_queue(display);

        struct wl_registry* registry = wl_display_get_registry(display);
        wl_proxy_set_queue(reinterpret_cast<struct wl_proxy*>(registry), eventQueue);
        wl_registry_add_listener(registry, &s_registryListener, this);
        wl_display_roundtrip_queue(display, eventQueue);
        wl_registry_destroy(registry);

        wl_event_queue_destroy(eventQueue);
    }

    ~Audio()
    {
        if (m_wl.audio)
            wpe_audio_destroy(m_wl.audio);
    }

    void start(uint32_t id, int32_t channels, const char* layout, int32_t sampleRate)
    {
        if (m_wl.audio)
            wpe_audio_stream_started(m_wl.audio, id, channels, layout, sampleRate);
    }

    void packet(uint32_t id, int32_t fd, uint32_t frames, wpe_audio_packet_export_release_notify_t notify, void* notify_data)
    {
        if (!m_wl.audio)
            return;

        auto* update = wpe_audio_stream_packet(m_wl.audio, id, fd, frames);

        wl_proxy_set_queue(reinterpret_cast<struct wl_proxy*>(update), AudioThread::singleton().eventQueue());
        wpe_audio_packet_export_add_listener(update, &s_audioPacketExportListener, new ListenerData { notify, notify_data });
    }

    void stop(uint32_t id)
    {
        if (m_wl.audio)
            wpe_audio_stream_stopped(m_wl.audio, id);
    }

    void pause(uint32_t id)
    {
        if (m_wl.audio)
            wpe_audio_stream_paused(m_wl.audio, id);
    }

    void resume(uint32_t id)
    {
        if (m_wl.audio)
            wpe_audio_stream_resumed(m_wl.audio, id);
    }

    bool has_receiver()
    {
        return m_wl.audio;
    }

private:
    static const struct wl_registry_listener s_registryListener;
    static const struct wpe_audio_packet_export_listener s_audioPacketExportListener;

    struct ListenerData {
        wpe_audio_packet_export_release_notify_t notify;
        void* notify_data;
    };

    struct {
        struct wpe_audio* audio { nullptr };
    } m_wl;
};

const struct wpe_audio_packet_export_listener Audio::s_audioPacketExportListener = {
    // release
    [](void* data, struct wpe_audio_packet_export* update) {
        auto* listenerData = static_cast<ListenerData*>(data);
        if (listenerData->notify)
            listenerData->notify(listenerData->notify_data);
        delete listenerData;
        wpe_audio_packet_export_destroy(update);
    },
};

const struct wl_registry_listener Audio::s_registryListener = {
    // global
    [](void* data, struct wl_registry* registry, uint32_t name, const char* interface, uint32_t)
    {
        auto& impl = *reinterpret_cast<Audio*>(data);
        if (!std::strcmp(interface, "wpe_audio"))
            impl.m_wl.audio = static_cast<struct wpe_audio*>(wl_registry_bind(registry, name, &wpe_audio_interface, 1));
    },
    // global_remove
    [](void*, struct wl_registry*, uint32_t) { },
};

}

extern "C" {

__attribute__((visibility("default")))
struct wpe_audio_source*
wpe_audio_source_create(struct wpe_renderer_backend_egl* backend)
{
    auto* base = reinterpret_cast<struct wpe_renderer_backend_egl_base*>(backend);
    auto* impl = new Impl::Audio(*static_cast<WS::BaseBackend*>(base->interface_data));
    return reinterpret_cast<struct wpe_audio_source*>(impl);
}

__attribute__((visibility("default")))
bool
wpe_audio_source_has_receiver(struct wpe_audio_source* audio_source)
{
    auto& impl = *reinterpret_cast<Impl::Audio*>(audio_source);
    return impl.has_receiver();
}

__attribute__((visibility("default")))
void
wpe_audio_source_destroy(struct wpe_audio_source* audio_source)
{
    delete reinterpret_cast<Impl::Audio*>(audio_source);
}

__attribute__((visibility("default")))
void
wpe_audio_source_start(struct wpe_audio_source* audio_source, uint32_t id, int32_t channels, const char* layout, int32_t sampleRate)
{
    auto& impl = *reinterpret_cast<Impl::Audio*>(audio_source);
    impl.start(id, channels, layout, sampleRate);
}

__attribute__((visibility("default")))
void
wpe_audio_source_packet(struct wpe_audio_source* audio_source, uint32_t id, int32_t fd, uint32_t frames, wpe_audio_packet_export_release_notify_t notify, void* notifyData)
{
    auto& impl = *reinterpret_cast<Impl::Audio*>(audio_source);
    impl.packet(id, fd, frames, notify, notifyData);
}

__attribute__((visibility("default")))
void
wpe_audio_source_stop(struct wpe_audio_source* audio_source, uint32_t id)
{
    auto& impl = *reinterpret_cast<Impl::Audio*>(audio_source);
    impl.stop(id);
}

__attribute__((visibility("default")))
void
wpe_audio_source_pause(struct wpe_audio_source* audio_source, uint32_t id)
{
    auto& impl = *reinterpret_cast<Impl::Audio*>(audio_source);
    impl.pause(id);
}

__attribute__((visibility("default")))
void
wpe_audio_source_resume(struct wpe_audio_source* audio_source, uint32_t id)
{
    auto& impl = *reinterpret_cast<Impl::Audio*>(audio_source);
    impl.resume(id);
}

}
