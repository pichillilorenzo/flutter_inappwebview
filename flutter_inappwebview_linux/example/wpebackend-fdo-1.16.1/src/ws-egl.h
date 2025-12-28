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

#pragma once

#include "ws.h"
#include <functional>

typedef void *EGLDisplay;
typedef void *EGLImageKHR;

namespace WS {

class ImplEGL final : public Instance::Impl {
public:
    ImplEGL();
    virtual ~ImplEGL();

    ImplementationType type() const override { return ImplementationType::EGL; }
    bool initialized() const override { return m_initialized; }

    void surfaceAttach(Surface&, struct wl_resource*) override;
    void surfaceCommit(Surface&) override;

    struct wpe_dmabuf_pool_entry* createDmabufPoolEntry(Surface&) override { return nullptr; }

    bool initialize(EGLDisplay);

    EGLImageKHR createImage(struct wl_resource*);
    EGLImageKHR createImage(const struct linux_dmabuf_buffer*);
    void destroyImage(EGLImageKHR);
    void queryBufferSize(struct wl_resource*, uint32_t* width, uint32_t* height);

    void importDmaBufBuffer(struct linux_dmabuf_buffer*);
    const struct linux_dmabuf_buffer* getDmaBufBuffer(struct wl_resource*) const;
    void foreachDmaBufModifier(std::function<void (int format, uint64_t modifier)>);

    struct wl_array* dmabufMainDevice() const { return const_cast<struct wl_array*>(&m_dmabuf.mainDevice); }
    int dmabufFormatTableFD() const { return m_dmabuf.formatTable.fd; }
    size_t dmabufFormatTableSize() const { return m_dmabuf.formatTable.size; }
    struct wl_array* dmabufFormatTableIndices() const { return const_cast<struct wl_array*>(&m_dmabuf.formatTable.indices); }

private:
    void initMainDevice();
    void initFormatTable();

    bool m_initialized { false };

    struct {
        EGLDisplay display;

        struct {
            bool WL_bind_wayland_display { false };
            bool KHR_image_base { false };
            bool EXT_image_dma_buf_import { false };
            bool EXT_image_dma_buf_import_modifiers { false };
        } extensions;
    } m_egl;

    struct {
        struct wl_global* global { nullptr };
        struct wl_list buffers;
        struct wl_array mainDevice;

        struct {
            size_t size { 0 };
            int fd { -1 };
            void* data { nullptr };
            struct wl_array indices;
        } formatTable;
    } m_dmabuf;
};

template<>
auto inline instanceImpl<ImplEGL>() -> ImplEGL&
{
    auto& instance = WS::Instance::singleton();
    return static_cast<ImplEGL&>(instance.impl());
}

} // namespace WS
