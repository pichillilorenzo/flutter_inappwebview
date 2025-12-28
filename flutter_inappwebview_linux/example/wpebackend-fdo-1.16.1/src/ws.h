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

#pragma once

#include "ws-types.h"
#include <functional>
#include <glib.h>
#include <memory>
#include <unordered_map>
#include <wayland-server.h>

struct linux_dmabuf_buffer;
struct wpe_dmabuf_pool_entry;
struct wpe_video_plane_display_dmabuf_export;
struct wpe_audio_packet_export;

namespace WS {

struct APIClient {
    virtual ~APIClient() = default;

    virtual void exportBufferResource(struct wl_resource*) = 0;
    virtual void exportLinuxDmabuf(const struct linux_dmabuf_buffer *dmabuf_buffer) = 0;
    virtual void exportShmBuffer(struct wl_resource*, struct wl_shm_buffer*) = 0;
    virtual void exportEGLStreamProducer(struct wl_resource*) = 0;

    virtual struct wpe_dmabuf_pool_entry* createDmabufPoolEntry() = 0;
    virtual void commitDmabufPoolEntry(struct wpe_dmabuf_pool_entry*) = 0;

    // Invoked when the association with the surface associated with a given
    // wpe_bridge identifier is no longer valid, typically due to the nested
    // compositor client being disconnected before having the chance to read
    // and process a FdoIPC::UnregisterSurface message.
    virtual void bridgeConnectionLost(uint32_t bridgeId) = 0;
};

struct Surface {
    explicit Surface(struct wl_resource* surfaceResource):
        resource {surfaceResource}
    {
        wl_list_init(&m_pendingFrameCallbacks);
        wl_list_init(&m_currentFrameCallbacks);
    }

    ~Surface()
    {
        struct wl_resource* resource;
        struct wl_resource* tmp;
        wl_resource_for_each_safe(resource, tmp, &m_pendingFrameCallbacks)
            wl_resource_destroy(resource);
        wl_resource_for_each_safe(resource, tmp, &m_currentFrameCallbacks)
            wl_resource_destroy(resource);
    }

    struct wl_resource* resource;

    APIClient* apiClient { nullptr };

    struct wl_resource* bufferResource { nullptr };
    const struct linux_dmabuf_buffer* dmabufBuffer { nullptr };
    struct wl_shm_buffer* shmBuffer { nullptr };

    void commit()
    {
        wl_list_insert_list(&m_currentFrameCallbacks, &m_pendingFrameCallbacks);
        wl_list_init(&m_pendingFrameCallbacks);
    }

    void addFrameCallback(struct wl_resource* resource)
    {
        wl_list_insert(m_pendingFrameCallbacks.prev, wl_resource_get_link(resource));
    }

    bool dispatchFrameCallbacks()
    {
        struct wl_resource* resource;
        struct wl_resource* tmp;
        struct wl_client* client { nullptr };

        wl_resource_for_each_safe(resource, tmp, &m_currentFrameCallbacks) {
            g_assert(!client || client == wl_resource_get_client(resource));
            client = wl_resource_get_client(resource);
            wl_callback_send_done(resource, 0);
            wl_resource_destroy(resource);
        }

        if (!client)
            return false;

        wl_client_flush(client);
        return true;
    }

private:
    struct wl_list m_pendingFrameCallbacks;
    struct wl_list m_currentFrameCallbacks;
};

class Instance {
public:
    class Impl {
    public:
        Impl() = default;
        virtual ~Impl() = default;

        void setInstance(Instance& instance) { m_instance = &instance; }
        struct wl_display* display() { return m_instance->m_display; }

        virtual ImplementationType type() const = 0;
        virtual bool initialized() const = 0;

        virtual void surfaceAttach(Surface&, struct wl_resource*) = 0;
        virtual void surfaceCommit(Surface&) = 0;

        virtual struct wpe_dmabuf_pool_entry* createDmabufPoolEntry(Surface&) = 0;

    private:
        Instance* m_instance { nullptr };
    };

    static bool isConstructed();
    static void construct(std::unique_ptr<Impl>&&);
    static Instance& singleton();
    ~Instance();

    Impl& impl() { return *m_impl; }

    int createClient();

    void registerSurface(uint32_t, Surface*);
    void unregisterSurface(Surface*);
    void registerViewBackend(uint32_t, APIClient&);
    void unregisterViewBackend(uint32_t);
    bool dispatchFrameCallbacks(uint32_t);

    using VideoPlaneDisplayDmaBufCallback = std::function<void(struct wpe_video_plane_display_dmabuf_export*, uint32_t, int, int32_t, int32_t, int32_t, int32_t, uint32_t)>;
    using VideoPlaneDisplayDmaBufEndOfStreamCallback = std::function<void(uint32_t)>;
    void initializeVideoPlaneDisplayDmaBuf(VideoPlaneDisplayDmaBufCallback, VideoPlaneDisplayDmaBufEndOfStreamCallback);
    void handleVideoPlaneDisplayDmaBuf(struct wpe_video_plane_display_dmabuf_export*, uint32_t id, int fd, int32_t x, int32_t y, int32_t width, int32_t height, uint32_t stride);
    void handleVideoPlaneDisplayDmaBufEndOfStream(uint32_t id);
    void releaseVideoPlaneDisplayDmaBufExport(struct wpe_video_plane_display_dmabuf_export*);

    using AudioStartCallback = std::function<void(uint32_t, int32_t, const char*, int32_t)>;
    using AudioPacketCallback = std::function<void(struct wpe_audio_packet_export*, uint32_t, int32_t, uint32_t)>;
    using AudioStopCallback = std::function<void(uint32_t)>;
    using AudioPauseCallback = std::function<void(uint32_t)>;
    using AudioResumeCallback = std::function<void(uint32_t)>;
    void initializeAudio(AudioStartCallback, AudioPacketCallback, AudioStopCallback, AudioPauseCallback, AudioResumeCallback);
    void handleAudioStart(uint32_t id, int32_t channels, const char* layout, int32_t sampleRate);
    void handleAudioPacket(struct wpe_audio_packet_export*, uint32_t id, int32_t fd, uint32_t frames);
    void handleAudioStop(uint32_t id);
    void handleAudioPause(uint32_t id);
    void handleAudioResume(uint32_t id);
    void releaseAudioPacketExport(struct wpe_audio_packet_export*);

private:
    friend class Impl;

    Instance(std::unique_ptr<Impl>&&);

    std::unique_ptr<Impl> m_impl;

    struct wl_display* m_display { nullptr };
    struct wl_global* m_compositor { nullptr };
    struct wl_global* m_wpeBridge { nullptr };
    struct wl_global* m_wpeDmabufPoolManager { nullptr };
    GSource* m_source { nullptr };

    // (bridgeId -> Surface)
    std::unordered_map<uint32_t, Surface*> m_viewBackendMap;

    struct {
        struct wl_global* object { nullptr };
        VideoPlaneDisplayDmaBufCallback updateCallback;
        VideoPlaneDisplayDmaBufEndOfStreamCallback endOfStreamCallback;
    } m_videoPlaneDisplayDmaBuf;

    struct {
        struct wl_global* object { nullptr };
        AudioStartCallback startCallback;
        AudioPacketCallback packetCallback;
        AudioStopCallback stopCallback;
        AudioPauseCallback pauseCallback;
        AudioResumeCallback resumeCallback;
    } m_audio;
};

template<typename T>
auto instanceImpl() -> T& = delete;

} // namespace WS
