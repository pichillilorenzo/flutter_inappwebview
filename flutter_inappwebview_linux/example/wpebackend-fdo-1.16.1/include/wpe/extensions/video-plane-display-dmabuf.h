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

#ifndef __video_plane_display_dmabuf_h__
#define __video_plane_display_dmabuf_h__

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * SECTION:video-plane-display-dmabuf
 * @title: DMABuf Video plane display
 * @short_description: Client-side video rendering support
 *
 * Usually WebKit takes care of video rendering by blending video frames in the
 * RenderTree. In some situations (such as DRM-protected media content) the
 * browser might need to handle video rendering itself, instead of letting
 * WebKit do it. By doing this, the browser can guarantee that video frames
 * wouldn't reach the user-space and would remain in the GPU as long as
 * possible.
 *
 * To support this scenario, the browser (Cog for instance) should register a
 * single #wpe_video_plane_display_dmabuf_receiver and implement the
 * `handle_dmabuf` and `end_of_stream` callbacks. On the other end, WebKit
 * should be compiled with the `-DUSE_WPE_VIDEO_PLANE_DISPLAY_DMABUF=ON` CMake
 * option so that video frames are sent to the browser as DMABufs using the
 * video-plane-display-dmabuf Wayland protocol. The browser will then be in
 * charge of positioning and rendering the video frames. WebKit will simply
 * render a transparent video rectangle placeholder in the RendeTree.
 */

struct wpe_renderer_backend_egl;
struct wpe_video_plane_display_dmabuf_source;

struct wpe_video_plane_display_dmabuf_source*
wpe_video_plane_display_dmabuf_source_create(struct wpe_renderer_backend_egl*);

void
wpe_video_plane_display_dmabuf_source_destroy(struct wpe_video_plane_display_dmabuf_source*);

typedef void (*wpe_video_plane_display_dmabuf_source_update_release_notify_t)(void *data);

void
wpe_video_plane_display_dmabuf_source_update(struct wpe_video_plane_display_dmabuf_source*, int fd, int32_t x, int32_t y, int32_t width, int32_t height, uint32_t stride,
    wpe_video_plane_display_dmabuf_source_update_release_notify_t notify, void* notify_data);

void
wpe_video_plane_display_dmabuf_source_end_of_stream(struct wpe_video_plane_display_dmabuf_source*);


struct wpe_video_plane_display_dmabuf_export;

struct wpe_video_plane_display_dmabuf_receiver {
    void (*handle_dmabuf)(void* data, struct wpe_video_plane_display_dmabuf_export*, uint32_t id, int fd, int32_t x, int32_t y, int32_t width, int32_t height, uint32_t stride);
    void (*end_of_stream)(void* data, uint32_t id);
    void (*_wpe_reserved0)(void);
    void (*_wpe_reserved1)(void);
    void (*_wpe_reserved2)(void);
    void (*_wpe_reserved3)(void);
};

void
wpe_video_plane_display_dmabuf_register_receiver(const struct wpe_video_plane_display_dmabuf_receiver*, void* data);

void
wpe_video_plane_display_dmabuf_export_release(struct wpe_video_plane_display_dmabuf_export*);

#ifdef __cplusplus
}
#endif

#endif // __video_plane_display_dmabuf_h__
