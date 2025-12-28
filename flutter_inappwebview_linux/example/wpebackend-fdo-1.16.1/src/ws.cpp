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

#include "ws.h"

#include "dmabuf-pool-entry-private.h"
#include "wpe-audio-server-protocol.h"
#include "wpe-bridge-server-protocol.h"
#include "wpe-dmabuf-pool-server-protocol.h"
#include "wpe-video-plane-display-dmabuf-server-protocol.h"
#include <algorithm>
#include <cassert>
#include <sys/socket.h>
#include <unistd.h>

struct wpe_video_plane_display_dmabuf_export {
    struct wl_resource* updateResource;
};
struct wpe_audio_packet_export {
    struct wl_resource* exportResource;
};

namespace WS {

struct ServerSource {
    static GSourceFuncs s_sourceFuncs;

    GSource source;
    GPollFD pfd;
    struct wl_display* display;
};

GSourceFuncs ServerSource::s_sourceFuncs = {
    // prepare
    [](GSource* base, gint* timeout) -> gboolean
    {
        auto& source = *reinterpret_cast<ServerSource*>(base);
        *timeout = -1;
        wl_display_flush_clients(source.display);
        return FALSE;
    },
    // check
    [](GSource* base) -> gboolean
    {
        auto& source = *reinterpret_cast<ServerSource*>(base);
        return !!source.pfd.revents;
    },
    // dispatch
    [](GSource* base, GSourceFunc, gpointer) -> gboolean
    {
        auto& source = *reinterpret_cast<ServerSource*>(base);

        if (source.pfd.revents & G_IO_IN) {
            struct wl_event_loop* eventLoop = wl_display_get_event_loop(source.display);
            wl_event_loop_dispatch(eventLoop, 0);
            wl_display_flush_clients(source.display);
        }

        if (source.pfd.revents & (G_IO_ERR | G_IO_HUP))
            return FALSE;

        source.pfd.revents = 0;
        return TRUE;
    },
    nullptr, // finalize
    nullptr, // closure_callback
    nullptr, // closure_marshall
};

static const struct wl_surface_interface s_surfaceInterface = {
    // destroy
    [](struct wl_client*, struct wl_resource*) { },
    // attach
    [](struct wl_client*, struct wl_resource* surfaceResource, struct wl_resource* bufferResource, int32_t, int32_t)
    {
        auto& surface = *static_cast<Surface*>(wl_resource_get_user_data(surfaceResource));
        Instance::singleton().impl().surfaceAttach(surface, bufferResource);
    },
    // damage
    [](struct wl_client*, struct wl_resource*, int32_t, int32_t, int32_t, int32_t) { },
    // frame
    [](struct wl_client* client, struct wl_resource* surfaceResource, uint32_t callback)
    {
        auto& surface = *static_cast<Surface*>(wl_resource_get_user_data(surfaceResource));
        if (!surface.apiClient)
            return;

        struct wl_resource* callbackResource = wl_resource_create(client, &wl_callback_interface, 1, callback);
        if (!callbackResource) {
            wl_resource_post_no_memory(surfaceResource);
            return;
        }

        wl_resource_set_implementation(callbackResource, nullptr, nullptr,
            [](struct wl_resource* resource) {
                wl_list_remove(wl_resource_get_link(resource));
            });
        surface.addFrameCallback(callbackResource);
    },
    // set_opaque_region
    [](struct wl_client*, struct wl_resource*, struct wl_resource*) { },
    // set_input_region
    [](struct wl_client*, struct wl_resource*, struct wl_resource*) { },
    // commit
    [](struct wl_client*, struct wl_resource* surfaceResource)
    {
        auto& surface = *static_cast<Surface*>(wl_resource_get_user_data(surfaceResource));
        surface.commit();
        WS::Instance::singleton().impl().surfaceCommit(surface);
    },
    // set_buffer_transform
    [](struct wl_client*, struct wl_resource*, int32_t) { },
    // set_buffer_scale
    [](struct wl_client*, struct wl_resource*, int32_t) { },
#if (WAYLAND_VERSION_MAJOR > 1) || (WAYLAND_VERSION_MAJOR == 1 && WAYLAND_VERSION_MINOR >= 10)
    // damage_buffer
    [](struct wl_client*, struct wl_resource*, int32_t, int32_t, int32_t, int32_t) { },
#endif
};

static const struct wl_compositor_interface s_compositorInterface = {
    // create_surface
    [](struct wl_client* client, struct wl_resource* resource, uint32_t id)
    {
        struct wl_resource* surfaceResource = wl_resource_create(client, &wl_surface_interface,
            wl_resource_get_version(resource), id);
        if (!surfaceResource) {
            wl_resource_post_no_memory(resource);
            return;
        }

        auto* surface = new Surface {surfaceResource};
        wl_resource_set_implementation(surfaceResource, &s_surfaceInterface, surface,
            [](struct wl_resource* resource)
            {
                auto* surface = static_cast<Surface*>(wl_resource_get_user_data(resource));
                WS::Instance::singleton().unregisterSurface(surface);
                delete surface;
            });
    },
    // create_region
    [](struct wl_client*, struct wl_resource*, uint32_t) { },
};

static const struct wpe_bridge_interface s_wpeBridgeInterface = {
    // initialize
    [](struct wl_client*, struct wl_resource* resource)
    {
        uint32_t implementationType = WPE_BRIDGE_CLIENT_IMPLEMENTATION_TYPE_WAYLAND;
        switch (Instance::singleton().impl().type()) {
        case ImplementationType::DmabufPool:
            implementationType = WPE_BRIDGE_CLIENT_IMPLEMENTATION_TYPE_DMABUF_POOL;
            break;
        case ImplementationType::EGL:
        case ImplementationType::EGLStream:
        case ImplementationType::SHM:
            implementationType = WPE_BRIDGE_CLIENT_IMPLEMENTATION_TYPE_WAYLAND;
            break;
        default:
            break;
        }

        wpe_bridge_send_implementation_info(resource, implementationType);
    },
    // connect
    [](struct wl_client*, struct wl_resource* resource, struct wl_resource* surfaceResource)
    {
        auto* surface = static_cast<Surface*>(wl_resource_get_user_data(surfaceResource));
        if (!surface)
            return;

        static uint32_t bridgeID = 0;
        ++bridgeID;
        wpe_bridge_send_connected(resource, bridgeID);
        Instance::singleton().registerSurface(bridgeID, surface);
    },
};

static const struct wl_buffer_interface s_wpeDmabufPoolEntryBufferInterface = {
    // destroy
    [](struct wl_client*, struct wl_resource* resource)
    {
        wl_resource_destroy(resource);
    },
};

static const struct wpe_dmabuf_data_interface s_wpeDmabufDataInterface = {
    // request
    [](struct wl_client*, struct wl_resource* dmabufDataResource)
    {
        auto* entry = static_cast<struct wpe_dmabuf_pool_entry*>(wl_resource_get_user_data(dmabufDataResource));

        wpe_dmabuf_data_send_attributes(dmabufDataResource, entry->width, entry->height,
            entry->format, entry->num_planes);
        for (unsigned i = 0; i < entry->num_planes; ++i) {
            uint32_t modifier_hi = entry->modifiers[i] >> 32;
            uint32_t modifier_lo = entry->modifiers[i] & 0xFFFFFFFF;
            wpe_dmabuf_data_send_plane(dmabufDataResource, i, entry->fds[i],
                entry->strides[i], entry->offsets[i], modifier_hi, modifier_lo);
        }
        wpe_dmabuf_data_send_complete(dmabufDataResource);
    },
};

static const struct wpe_dmabuf_pool_interface s_wpeDmabufPoolInterface = {
    // create_buffer
    [](struct wl_client* client, struct wl_resource* resource, uint32_t id, uint32_t width, uint32_t height)
    {
        auto& surface = *static_cast<Surface*>(wl_resource_get_user_data(resource));
        auto entry = WS::Instance::singleton().impl().createDmabufPoolEntry(surface);
        if (!entry) {
            // FIXME: more of an error
            wl_resource_post_no_memory(resource);
            return;
        }

        struct wl_resource* bufferResource = wl_resource_create(client, &wl_buffer_interface,
            wl_resource_get_version(resource), id);
        if (!bufferResource) {
            wl_resource_post_no_memory(resource);
            return;
        }

        entry->bufferResource = bufferResource;
        wl_resource_set_implementation(bufferResource, &s_wpeDmabufPoolEntryBufferInterface, entry,
            [](struct wl_resource* resource)
            {
                auto* entry = static_cast<struct wpe_dmabuf_pool_entry*>(wl_resource_get_user_data(resource));
                entry->bufferResource = nullptr;
            });
    },
    // get_dmabuf_data
    [](struct wl_client* client, struct wl_resource* resource, uint32_t id, struct wl_resource* bufferResource)
    {
        auto* entry = static_cast<struct wpe_dmabuf_pool_entry*>(wl_resource_get_user_data(bufferResource));
        if (!entry)
            return;

        struct wl_resource* dmabufDataResource = wl_resource_create(client, &wpe_dmabuf_data_interface,
            wl_resource_get_version(resource), id);
        if (!dmabufDataResource) {
            wl_resource_post_no_memory(resource);
            return;
        }

        wl_resource_set_implementation(dmabufDataResource, &s_wpeDmabufDataInterface, entry, nullptr);
    },
};

static const struct wpe_dmabuf_pool_manager_interface s_wpeDmabufPoolManagerInterface = {
    // create_pool
    [](struct wl_client* client, struct wl_resource* resource, uint32_t id, struct wl_resource* surfaceResource)
    {
        struct wl_resource* poolResource = wl_resource_create(client, &wpe_dmabuf_pool_interface,
            wl_resource_get_version(resource), id);
        if (!poolResource) {
            wl_resource_post_no_memory(resource);
            return;
        }

        auto* surface = static_cast<Surface*>(wl_resource_get_user_data(surfaceResource));
        wl_resource_set_implementation(poolResource, &s_wpeDmabufPoolInterface, surface, nullptr);
    },
};

struct DmaBufUpdate {
    uint32_t id { 0 };
    struct wl_client* client;
};

struct AudioPacketUpdate {
    uint32_t id { 0 };
    struct wl_client* client;
};


static const struct wpe_video_plane_display_dmabuf_update_interface s_videoPlaneDisplayUpdateInterface = {
    // destroy
    [](struct wl_client*, struct wl_resource* resource)
    {
        wl_resource_destroy(resource);
    },
};

static const struct wpe_video_plane_display_dmabuf_interface s_wpeDmaBufInterface = {
    // create_update
    [](struct wl_client* client, struct wl_resource* resource, uint32_t id, uint32_t video_id, int32_t fd, int32_t x, int32_t y, int32_t width, int32_t height, uint32_t stride)
    {
        struct wl_resource* updateResource = wl_resource_create(client, &wpe_video_plane_display_dmabuf_update_interface,
            wl_resource_get_version(resource), id);
        if (!updateResource) {
            wl_resource_post_no_memory(resource);
            return;
        }

        auto* update = new DmaBufUpdate;
        update->id = id;
        update->client = client;
        wl_resource_set_implementation(updateResource, &s_videoPlaneDisplayUpdateInterface, update,
            [](struct wl_resource* resource)
            {
                auto* update = static_cast<DmaBufUpdate*>(wl_resource_get_user_data(resource));
                delete update;
            });

        auto* dmabuf_export = new struct wpe_video_plane_display_dmabuf_export;
        dmabuf_export->updateResource = updateResource;
        Instance::singleton().handleVideoPlaneDisplayDmaBuf(dmabuf_export, video_id, fd, x, y, width, height, stride);
    },
    // end_of_stream
    [](struct wl_client* client, struct wl_resource* resource, uint32_t video_id)
    {
        Instance::singleton().handleVideoPlaneDisplayDmaBufEndOfStream(video_id);
    },
};

  static const struct wpe_audio_packet_export_interface s_audioPacketExportInterface = {
    // destroy
    [](struct wl_client*, struct wl_resource* resource)
    {
        wl_resource_destroy(resource);
    },
};

static const struct wpe_audio_interface s_wpeAudioInterface = {
    // stream_started
    [](struct wl_client*, struct wl_resource*, uint32_t id, int32_t channels, const char* layout, int32_t sampleRate)
    {
        Instance::singleton().handleAudioStart(id, channels, layout, sampleRate);
    },
    // stream_packet
    [](struct wl_client* client, struct wl_resource* resource, uint32_t id, uint32_t audio_stream_id, int32_t fd, uint32_t frames)
    {
        struct wl_resource* exportResource = wl_resource_create(client, &wpe_audio_packet_export_interface,
            wl_resource_get_version(resource), id);
        if (!exportResource) {
          wl_resource_post_no_memory(resource);
          return;
        }

        auto* update = new AudioPacketUpdate;
        update->id = id;
        update->client = client;
        wl_resource_set_implementation(exportResource, &s_audioPacketExportInterface, update,
            [](struct wl_resource* resource)
            {
                auto* update = static_cast<AudioPacketUpdate*>(wl_resource_get_user_data(resource));
                delete update;
            });

        auto* audio_packet_export = new struct wpe_audio_packet_export;
        audio_packet_export->exportResource = exportResource;
        Instance::singleton().handleAudioPacket(audio_packet_export, audio_stream_id, fd, frames);
    },
    // stream_stopped
    [](struct wl_client*, struct wl_resource*, uint32_t id)
    {
        Instance::singleton().handleAudioStop(id);
    },
    // stream_paused
    [](struct wl_client*, struct wl_resource*, uint32_t id)
    {
        Instance::singleton().handleAudioPause(id);
    },
    // stream_resumed
    [](struct wl_client*, struct wl_resource*, uint32_t id)
    {
        Instance::singleton().handleAudioResume(id);
    }
};

static Instance* s_singleton;

void Instance::construct(std::unique_ptr<Impl>&& impl)
{
    s_singleton = new Instance(std::move(impl));
}

bool Instance::isConstructed()
{
    return !!s_singleton;
}

Instance& Instance::singleton()
{
    assert(isConstructed());
    return *s_singleton;
}

Instance::Instance(std::unique_ptr<Impl>&& impl)
    : m_impl(std::move(impl))
    , m_display(wl_display_create())
    , m_source(g_source_new(&ServerSource::s_sourceFuncs, sizeof(ServerSource)))
{
    m_impl->setInstance(*this);

    m_compositor = wl_global_create(m_display, &wl_compositor_interface, 3, this,
        [](struct wl_client* client, void*, uint32_t version, uint32_t id)
        {
            struct wl_resource* resource = wl_resource_create(client, &wl_compositor_interface, version, id);
            if (!resource) {
                wl_client_post_no_memory(client);
                return;
            }

            wl_resource_set_implementation(resource, &s_compositorInterface, nullptr, nullptr);
        });
    m_wpeBridge = wl_global_create(m_display, &wpe_bridge_interface, 1, this,
        [](struct wl_client* client, void*, uint32_t version, uint32_t id)
        {
            struct wl_resource* resource = wl_resource_create(client, &wpe_bridge_interface, version, id);
            if (!resource) {
                wl_client_post_no_memory(client);
                return;
            }

            wl_resource_set_implementation(resource, &s_wpeBridgeInterface, nullptr, nullptr);
        });
    m_wpeDmabufPoolManager = wl_global_create(m_display, &wpe_dmabuf_pool_manager_interface, 1, this,
        [](struct wl_client* client, void*, uint32_t version, uint32_t id)
        {
            struct wl_resource* resource = wl_resource_create(client, &wpe_dmabuf_pool_manager_interface, version, id);
            if (!resource) {
                wl_client_post_no_memory(client);
                return;
            }

            wl_resource_set_implementation(resource, &s_wpeDmabufPoolManagerInterface, nullptr, nullptr);
        });

    auto& source = *reinterpret_cast<ServerSource*>(m_source);

    struct wl_event_loop* eventLoop = wl_display_get_event_loop(m_display);
    source.pfd.fd = wl_event_loop_get_fd(eventLoop);
    source.pfd.events = G_IO_IN | G_IO_ERR | G_IO_HUP;
    source.pfd.revents = 0;
    source.display = m_display;

    g_source_add_poll(m_source, &source.pfd);
    g_source_set_name(m_source, "WPEBackend-fdo::Host");
    g_source_set_can_recurse(m_source, TRUE);
    g_source_attach(m_source, g_main_context_get_thread_default());
}

Instance::~Instance()
{
    if (m_source) {
        g_source_destroy(m_source);
        g_source_unref(m_source);
    }

    m_impl = nullptr;

    if (m_compositor)
        wl_global_destroy(m_compositor);

    if (m_wpeBridge)
        wl_global_destroy(m_wpeBridge);

    if (m_wpeDmabufPoolManager)
        wl_global_destroy(m_wpeDmabufPoolManager);

    if (m_videoPlaneDisplayDmaBuf.object)
        wl_global_destroy(m_videoPlaneDisplayDmaBuf.object);

    if (m_audio.object)
        wl_global_destroy(m_audio.object);

    if (m_display)
        wl_display_destroy(m_display);
}

int Instance::createClient()
{
    if (!m_impl->initialized())
        return -1;

    int pair[2];
    if (socketpair(AF_UNIX, SOCK_STREAM | SOCK_CLOEXEC, 0, pair) < 0)
        return -1;

    int clientFd = dup(pair[1]);
    close(pair[1]);

    wl_client_create(m_display, pair[0]);
    return clientFd;
}

void Instance::registerSurface(uint32_t id, Surface* surface)
{
    m_viewBackendMap.insert({ id, surface });
}

void Instance::initializeVideoPlaneDisplayDmaBuf(VideoPlaneDisplayDmaBufCallback updateCallback, VideoPlaneDisplayDmaBufEndOfStreamCallback endOfStreamCallback)
{
    if (m_videoPlaneDisplayDmaBuf.object)
        return;

    m_videoPlaneDisplayDmaBuf.object = wl_global_create(m_display, &wpe_video_plane_display_dmabuf_interface, 1, this,
        [](struct wl_client* client, void*, uint32_t version, uint32_t id)
        {
            struct wl_resource* resource = wl_resource_create(client, &wpe_video_plane_display_dmabuf_interface, version, id);
            if (!resource) {
                wl_client_post_no_memory(client);
                return;
            }

            wl_resource_set_implementation(resource, &s_wpeDmaBufInterface, nullptr, nullptr);
        });
    m_videoPlaneDisplayDmaBuf.updateCallback = updateCallback;
    m_videoPlaneDisplayDmaBuf.endOfStreamCallback = endOfStreamCallback;
}

void Instance::handleVideoPlaneDisplayDmaBuf(struct wpe_video_plane_display_dmabuf_export* dmabuf_export, uint32_t id, int fd, int32_t x, int32_t y, int32_t width, int32_t height, uint32_t stride)
{
    if (!m_videoPlaneDisplayDmaBuf.updateCallback) {
        if (fd >= 0)
            close(fd);
        return;
    }

    m_videoPlaneDisplayDmaBuf.updateCallback(dmabuf_export, id, fd, x, y, width, height, stride);
}

void Instance::handleVideoPlaneDisplayDmaBufEndOfStream(uint32_t id)
{
    if (!m_videoPlaneDisplayDmaBuf.endOfStreamCallback)
        return;

    m_videoPlaneDisplayDmaBuf.endOfStreamCallback(id);
}

void Instance::releaseVideoPlaneDisplayDmaBufExport(struct wpe_video_plane_display_dmabuf_export* dmabuf_export)
{
    wpe_video_plane_display_dmabuf_update_send_release(dmabuf_export->updateResource);
}


void Instance::initializeAudio(AudioStartCallback startCallback, AudioPacketCallback packetCallback, AudioStopCallback stopCallback, AudioPauseCallback pauseCallback, AudioResumeCallback resumeCallback)
{
    if (m_audio.object)
        return;

    m_audio.object = wl_global_create(m_display, &wpe_audio_interface, 1, this,
        [](struct wl_client* client, void*, uint32_t version, uint32_t id)
        {
            struct wl_resource* resource = wl_resource_create(client, &wpe_audio_interface, version, id);
            if (!resource) {
                wl_client_post_no_memory(client);
                return;
            }
            wl_resource_set_implementation(resource, &s_wpeAudioInterface, nullptr, nullptr);
    });
    m_audio.startCallback = startCallback;
    m_audio.packetCallback = packetCallback;
    m_audio.stopCallback = stopCallback;
    m_audio.pauseCallback = pauseCallback;
    m_audio.resumeCallback = resumeCallback;
}

void Instance::handleAudioStart(uint32_t id, int32_t channels, const char* layout, int32_t sampleRate)
{
    if (!m_audio.startCallback)
        return;

    m_audio.startCallback(id, channels, layout, sampleRate);
}

void Instance::handleAudioPacket(struct wpe_audio_packet_export* packet_export, uint32_t id, int32_t fd, uint32_t frames)
{
    if (!m_audio.packetCallback) {
        close(fd);
        return;
    }

    m_audio.packetCallback(packet_export, id, fd, frames);
}

void Instance::handleAudioStop(uint32_t id)
{
    if (!m_audio.stopCallback)
        return;

    m_audio.stopCallback(id);
}

void Instance::handleAudioPause(uint32_t id)
{
    if (!m_audio.pauseCallback)
        return;

    m_audio.pauseCallback(id);
}

void Instance::handleAudioResume(uint32_t id)
{
  if (!m_audio.resumeCallback)
    return;

  m_audio.resumeCallback(id);
}

void Instance::releaseAudioPacketExport(struct wpe_audio_packet_export* packet_export)
{
    wpe_audio_packet_export_send_release(packet_export->exportResource);
}

void Instance::registerViewBackend(uint32_t bridgeId, APIClient& apiClient)
{
    auto it = m_viewBackendMap.find(bridgeId);
    if (it == m_viewBackendMap.end())
        g_error("Instance::registerViewBackend(): " "Cannot find surface with bridgeId %" PRIu32 " in view backend map.", bridgeId);

    it->second->apiClient = &apiClient;
}

void Instance::unregisterViewBackend(uint32_t bridgeId)
{
    auto it = m_viewBackendMap.find(bridgeId);
    if (it != m_viewBackendMap.end()) {
        it->second->apiClient = nullptr;
        m_viewBackendMap.erase(it);
    }
}

void Instance::unregisterSurface(Surface* surface)
{
    auto it = std::find_if(m_viewBackendMap.begin(), m_viewBackendMap.end(),
        [surface](const std::pair<uint32_t, Surface*>& value) -> bool {
            return value.second == surface;
        });
    if (it != m_viewBackendMap.end()) {
        const uint32_t bridgeId = it->first;
        m_viewBackendMap.erase(it);
        if (surface->apiClient)
            surface->apiClient->bridgeConnectionLost(bridgeId);
    }
}

bool Instance::dispatchFrameCallbacks(uint32_t bridgeId)
{
    auto it = m_viewBackendMap.find(bridgeId);
    if (it == m_viewBackendMap.end()) {
        g_warning("Instance::dispatchFrameCallbacks(): "
                  "Cannot find surface with bridgeId %" PRIu32 " in view "
                  "backend map. Probably the associated surface is gone "
                  "due to a premature exit in the client side", bridgeId);
        return false;
    }

    return it->second->dispatchFrameCallbacks();
}

} // namespace WS
