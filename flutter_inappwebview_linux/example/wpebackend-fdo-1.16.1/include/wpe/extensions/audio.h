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

#ifndef __audio_h__
#define __audio_h__

#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * SECTION:audio
 * @title: Audio rendering
 * @short_description: Client-side audio rendering support
 *
 * Usually WebKit takes care of audio rendering by connecting to the default
 * audio system daemon such as PulseAudio or directly to ALSA. In some
 * situations the UI process might want to handle PCM samples itself.
 *
 * To support this scenario, the UI process (created by GStreamer's wpesrc
 * element for instance) should register a #wpe_audio_receiver, implement its
 * callbacks and set the WebView audio-rendering-policy to
 * WEBKIT_AUDIO_RENDERING_POLICY_EXTERNAL.
 */


struct wpe_renderer_backend_egl;
struct wpe_audio_source;
struct wpe_audio_packet_export;

struct wpe_audio_source*
wpe_audio_source_create(struct wpe_renderer_backend_egl*);

bool
wpe_audio_source_has_receiver(struct wpe_audio_source*);

void
wpe_audio_source_destroy(struct wpe_audio_source*);

void
wpe_audio_source_start(struct wpe_audio_source* audio_source, uint32_t id, int32_t channels, const char* layout, int32_t sampleRate);

typedef void (*wpe_audio_packet_export_release_notify_t)(void*);

void
wpe_audio_source_packet(struct wpe_audio_source* audio_source, uint32_t id, int32_t fd, uint32_t frames, wpe_audio_packet_export_release_notify_t notify, void* notifyData);

void
wpe_audio_source_stop(struct wpe_audio_source* audio_source, uint32_t id);

void
wpe_audio_source_pause(struct wpe_audio_source* audio_source, uint32_t id);

void
wpe_audio_source_resume(struct wpe_audio_source* audio_source, uint32_t id);

struct wpe_audio_receiver {
  void (*handle_start)(void* data, uint32_t id, int32_t channels, const char* layout, int32_t sampleRate);
  void (*handle_packet)(void* data, struct wpe_audio_packet_export*, uint32_t id, int32_t fd, uint32_t frames);
  void (*handle_stop)(void* data, uint32_t id);
  void (*handle_pause)(void* data, uint32_t id);
  void (*handle_resume)(void* data, uint32_t id);
};

void wpe_audio_register_receiver(const struct wpe_audio_receiver*, void* data);

void wpe_audio_packet_export_release(struct wpe_audio_packet_export*);

#ifdef __cplusplus
}
#endif

#endif // __audio_h__
