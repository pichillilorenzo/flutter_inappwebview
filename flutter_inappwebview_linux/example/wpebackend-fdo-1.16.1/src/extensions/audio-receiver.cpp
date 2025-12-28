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

#include "../ws.h"
#include <unistd.h>

static struct {
    const struct wpe_audio_receiver* receiver;
    void* data;
} s_registered_receiver;

static void dispatchReceiverStart(uint32_t id, int32_t channels, const char* layout, int32_t sampleRate)
{
    if (s_registered_receiver.receiver)
        s_registered_receiver.receiver->handle_start(s_registered_receiver.data, id, channels, layout, sampleRate);
}

static void dispatchReceiverPacket(struct wpe_audio_packet_export* packet_export, uint32_t id, int32_t fd, uint32_t frames)
{
    if (s_registered_receiver.receiver)
        s_registered_receiver.receiver->handle_packet(s_registered_receiver.data, packet_export, id, fd, frames);
    else
        wpe_audio_packet_export_release (packet_export);

    close(fd);
}

static void dispatchReceiverStop(uint32_t id)
{
    if (s_registered_receiver.receiver)
        s_registered_receiver.receiver->handle_stop(s_registered_receiver.data, id);
}

static void dispatchReceiverPause(uint32_t id)
{
  if (s_registered_receiver.receiver)
      s_registered_receiver.receiver->handle_pause(s_registered_receiver.data, id);
}


static void dispatchReceiverResume(uint32_t id)
{
  if (s_registered_receiver.receiver)
      s_registered_receiver.receiver->handle_resume(s_registered_receiver.data, id);
}

extern "C" {

__attribute__((visibility("default")))
void
wpe_audio_register_receiver(const struct wpe_audio_receiver* receiver, void* data)
{
    s_registered_receiver.receiver = receiver;
    s_registered_receiver.data = data;

    WS::Instance::singleton().initializeAudio(&dispatchReceiverStart, &dispatchReceiverPacket, &dispatchReceiverStop, &dispatchReceiverPause, &dispatchReceiverResume);
}

__attribute__((visibility("default")))
void
wpe_audio_packet_export_release(struct wpe_audio_packet_export* packet_export)
{
    WS::Instance::singleton().releaseAudioPacketExport(packet_export);
}

}
