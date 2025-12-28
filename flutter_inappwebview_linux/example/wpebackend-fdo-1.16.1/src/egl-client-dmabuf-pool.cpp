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

#include "egl-client-dmabuf-pool.h"

#include "ws-client.h"

#include <array>
#include <cstdio>

namespace WS {
namespace EGLClient {

BackendDmabufPool::BackendDmabufPool(BaseBackend&)
{
}

BackendDmabufPool::~BackendDmabufPool() = default;

EGLNativeDisplayType BackendDmabufPool::nativeDisplay() const
{
    return EGL_DEFAULT_DISPLAY;
}

uint32_t BackendDmabufPool::platform() const
{
    return EGL_PLATFORM_SURFACELESS_MESA;
}


struct TargetDmabufPool::Buffer {
    struct wl_list link;
    struct wl_buffer* buffer { nullptr };
    bool locked { false };

    struct {
        uint32_t width;
        uint32_t height;
        uint32_t format;
    } meta;

    struct {
        EGLImageKHR image;
    } egl;

    struct {
        GLuint colorBuffer;
        GLuint dsBuffer;
    } gl;
};

struct BufferData {
    bool complete { false };

    uint32_t width { 0 };
    uint32_t height { 0 };
    uint32_t format { 0 };

    uint32_t numPlanes { 0 };
    std::array<int, 4> fds { -1, -1, -1, -1 };
    std::array<uint32_t, 4> strides { };
    std::array<uint32_t, 4> offsets { };
    std::array<uint64_t, 4> modifiers { };
};

TargetDmabufPool::TargetDmabufPool(BaseTarget& base, uint32_t width, uint32_t height)
    : m_base(base)
{
    wl_list_init(&m_buffer.list);

    m_renderer.width = width;
    m_renderer.height = height;
}

TargetDmabufPool::~TargetDmabufPool() = default;

EGLNativeWindowType TargetDmabufPool::nativeWindow() const
{
    return 0;
}

void TargetDmabufPool::resize(uint32_t width, uint32_t height)
{
    if (m_renderer.width == width && m_renderer.height == height)
        return;

    m_renderer.width = width;
    m_renderer.height = height;

    m_buffer.current = nullptr;

    Buffer* buffer;
    Buffer* tmp;
    wl_list_for_each_safe(buffer, tmp, &m_buffer.list, link) {
        wl_list_remove(&buffer->link);
        destroyBuffer(buffer);
    }
    wl_list_init(&m_buffer.list);
}

void TargetDmabufPool::frameWillRender()
{
    if (!m_renderer.initialized) {
        m_renderer.initialized = true;

        m_renderer.createImageKHR = reinterpret_cast<PFNEGLCREATEIMAGEKHRPROC>(
            eglGetProcAddress("eglCreateImageKHR"));
        m_renderer.destroyImageKHR = reinterpret_cast<PFNEGLDESTROYIMAGEKHRPROC>(
            eglGetProcAddress("eglDestroyImageKHR"));
        m_renderer.imageTargetRenderbufferStorageOES = reinterpret_cast<PFNGLEGLIMAGETARGETRENDERBUFFERSTORAGEOESPROC>(
            eglGetProcAddress("glEGLImageTargetRenderbufferStorageOES"));

        GLuint framebuffer { 0 };
        glGenFramebuffers(1, &framebuffer);
        m_renderer.framebuffer = framebuffer;
    }

    m_base.requestFrame();

    g_assert(!m_buffer.current);
    {
        Buffer* b;
        wl_list_for_each(b, &m_buffer.list, link) {
            if (b->locked)
                continue;

            m_buffer.current = b;
            break;
        }
    }
    if (!m_buffer.current) {
        auto* buffer = new Buffer;
        buffer->buffer = wpe_dmabuf_pool_create_buffer(m_base.wpeDmabufPool(), m_renderer.width, m_renderer.height);
        wl_buffer_add_listener(buffer->buffer, &s_bufferListener, this);

        wl_list_insert(&m_buffer.list, &buffer->link);
        m_buffer.current = buffer;

        struct wpe_dmabuf_data* dmabufData = wpe_dmabuf_pool_get_dmabuf_data(m_base.wpeDmabufPool(), buffer->buffer);
        wl_proxy_set_queue(reinterpret_cast<struct wl_proxy*>(dmabufData), m_base.eventQueue());

        BufferData bufferData;
        wpe_dmabuf_data_add_listener(dmabufData, &s_dmabufDataListener, &bufferData);
        wpe_dmabuf_data_request(dmabufData);
        wl_display_roundtrip_queue(m_base.display(), m_base.eventQueue());

        buffer->meta.width = bufferData.width;
        buffer->meta.height = bufferData.height;
        buffer->meta.format = bufferData.format;

        std::array<EGLint, 64> attributes;
        {
            attributes[0] = EGL_WIDTH; attributes[1] = bufferData.width;
            attributes[2] = EGL_HEIGHT; attributes[3] = bufferData.height;
            attributes[4] = EGL_LINUX_DRM_FOURCC_EXT; attributes[5] = bufferData.format;
            unsigned attributesCount = 6;

            if (bufferData.numPlanes >= 1) {
                uint32_t modifier_hi = bufferData.modifiers[0] >> 32;
                uint32_t modifier_lo = bufferData.modifiers[0] & 0xFFFFFFFF;
                std::array<EGLAttrib, 10> planeAttributes = {
                        EGL_DMA_BUF_PLANE0_FD_EXT, bufferData.fds[0],
                        EGL_DMA_BUF_PLANE0_PITCH_EXT, bufferData.strides[0],
                        EGL_DMA_BUF_PLANE0_OFFSET_EXT, bufferData.offsets[0],
                        EGL_DMA_BUF_PLANE0_MODIFIER_HI_EXT, modifier_hi,
                        EGL_DMA_BUF_PLANE0_MODIFIER_LO_EXT, modifier_lo,
                    };

                std::copy(planeAttributes.begin(), planeAttributes.end(),
                    std::next(attributes.begin(), attributesCount));
                attributesCount += planeAttributes.size();
            }

            if (bufferData.numPlanes >= 2) {
                uint32_t modifier_hi = bufferData.modifiers[1] >> 32;
                uint32_t modifier_lo = bufferData.modifiers[1] & 0xFFFFFFFF;
                std::array<EGLAttrib, 10> planeAttributes = {
                        EGL_DMA_BUF_PLANE1_FD_EXT, bufferData.fds[1],
                        EGL_DMA_BUF_PLANE1_PITCH_EXT, bufferData.strides[1],
                        EGL_DMA_BUF_PLANE1_OFFSET_EXT, bufferData.offsets[1],
                        EGL_DMA_BUF_PLANE1_MODIFIER_HI_EXT, modifier_hi,
                        EGL_DMA_BUF_PLANE1_MODIFIER_LO_EXT, modifier_lo,
                    };

                std::copy(planeAttributes.begin(), planeAttributes.end(),
                    std::next(attributes.begin(), attributesCount));
                attributesCount += planeAttributes.size();
            }

            if (bufferData.numPlanes >= 3) {
                uint32_t modifier_hi = bufferData.modifiers[2] >> 32;
                uint32_t modifier_lo = bufferData.modifiers[2] & 0xFFFFFFFF;
                std::array<EGLAttrib, 10> planeAttributes = {
                        EGL_DMA_BUF_PLANE2_FD_EXT, bufferData.fds[2],
                        EGL_DMA_BUF_PLANE2_PITCH_EXT, bufferData.strides[2],
                        EGL_DMA_BUF_PLANE2_OFFSET_EXT, bufferData.offsets[2],
                        EGL_DMA_BUF_PLANE2_MODIFIER_HI_EXT, modifier_hi,
                        EGL_DMA_BUF_PLANE2_MODIFIER_LO_EXT, modifier_lo,
                    };

                std::copy(planeAttributes.begin(), planeAttributes.end(),
                    std::next(attributes.begin(), attributesCount));
                attributesCount += planeAttributes.size();
            }

            if (bufferData.numPlanes >= 4) {
                uint32_t modifier_hi = bufferData.modifiers[3] >> 32;
                uint32_t modifier_lo = bufferData.modifiers[3] & 0xFFFFFFFF;
                std::array<EGLAttrib, 10> planeAttributes = {
                        EGL_DMA_BUF_PLANE3_FD_EXT, bufferData.fds[3],
                        EGL_DMA_BUF_PLANE3_PITCH_EXT, bufferData.strides[3],
                        EGL_DMA_BUF_PLANE3_OFFSET_EXT, bufferData.offsets[3],
                        EGL_DMA_BUF_PLANE3_MODIFIER_HI_EXT, modifier_hi,
                        EGL_DMA_BUF_PLANE3_MODIFIER_LO_EXT, modifier_lo,
                    };

                std::copy(planeAttributes.begin(), planeAttributes.end(),
                    std::next(attributes.begin(), attributesCount));
                attributesCount += planeAttributes.size();
            }
            attributes[attributesCount++] = EGL_NONE;
        }

        buffer->egl.image = m_renderer.createImageKHR(eglGetCurrentDisplay(),
            EGL_NO_CONTEXT, EGL_LINUX_DMA_BUF_EXT, nullptr, attributes.data());

        for (unsigned i = 0; i < bufferData.numPlanes; ++i) {
            if (bufferData.fds[i] != -1)
                close(bufferData.fds[i]);
        }

        if (buffer->egl.image == EGL_NO_IMAGE_KHR) {
            g_warning("unable to create EGLImage from the dma-buf data, error %x", eglGetError());
            return;
        }

        std::array<GLuint, 2> renderbuffers { 0, 0 };
        glGenRenderbuffers(2, renderbuffers.data());
        buffer->gl.colorBuffer = renderbuffers[0];
        buffer->gl.dsBuffer = renderbuffers[1];

        glBindRenderbuffer(GL_RENDERBUFFER, buffer->gl.colorBuffer);
        m_renderer.imageTargetRenderbufferStorageOES(GL_RENDERBUFFER, buffer->egl.image);

        glBindRenderbuffer(GL_RENDERBUFFER, buffer->gl.dsBuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8_OES, buffer->meta.width, buffer->meta.height);
    }

    glBindFramebuffer(GL_FRAMEBUFFER, m_renderer.framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
        GL_RENDERBUFFER, m_buffer.current->gl.colorBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT,
        GL_RENDERBUFFER, m_buffer.current->gl.dsBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT,
        GL_RENDERBUFFER, m_buffer.current->gl.dsBuffer);

    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
        g_warning("established framebuffer object is not framebuffer-complete");
}

void TargetDmabufPool::frameRendered()
{
    glFlush();

    wl_surface_attach(m_base.surface(), m_buffer.current->buffer, 0, 0);
    wl_surface_commit(m_base.surface());

    m_buffer.current->locked = true;
    m_buffer.current = nullptr;
}

void TargetDmabufPool::deinitialize()
{
    m_buffer.current = nullptr;

    Buffer* buffer;
    Buffer* tmp;
    wl_list_for_each_safe(buffer, tmp, &m_buffer.list, link) {
        wl_list_remove(&buffer->link);
        destroyBuffer(buffer);
    }
    wl_list_init(&m_buffer.list);

    if (m_renderer.framebuffer) {
        glDeleteFramebuffers(1, &m_renderer.framebuffer);
        m_renderer.framebuffer = 0;
    }
}

void TargetDmabufPool::destroyBuffer(Buffer* buffer)
{
    auto& b = *buffer;
    g_clear_pointer(&b.buffer, wl_buffer_destroy);
    if (b.gl.colorBuffer)
        glDeleteRenderbuffers(1, &b.gl.colorBuffer);
    if (b.gl.dsBuffer)
        glDeleteRenderbuffers(1, &b.gl.dsBuffer);
    if (b.egl.image)
        m_renderer.destroyImageKHR(eglGetCurrentDisplay(), b.egl.image);

    delete buffer;
}

const struct wpe_dmabuf_data_listener TargetDmabufPool::s_dmabufDataListener = {
    // atributes
    [](void* data, struct wpe_dmabuf_data*, uint32_t width, uint32_t height, uint32_t format, uint32_t num_planes)
    {
        auto& bufferData = *static_cast<BufferData*>(data);
        bufferData.width = width;
        bufferData.height = height;
        bufferData.format = format;
        bufferData.numPlanes = num_planes;
    },
    // plane
    [](void* data, struct wpe_dmabuf_data*, uint32_t id, int32_t fd, uint32_t stride, uint32_t offset, uint32_t modifier_hi, uint32_t modifier_lo)
    {
        auto& bufferData = *static_cast<BufferData*>(data);
        bufferData.fds[id] = fd;
        bufferData.strides[id] = stride;
        bufferData.offsets[id] = offset;
        bufferData.modifiers[id] = (uint64_t(modifier_hi) << 32) | uint64_t(modifier_lo);
    },
    // done
    [](void* data, struct wpe_dmabuf_data*)
    {
        auto& bufferData = *static_cast<BufferData*>(data);
        bufferData.complete = true;
    },
};

const struct wl_buffer_listener TargetDmabufPool::s_bufferListener = {
    // release
    [](void* data, struct wl_buffer* buffer)
    {
        auto& target = *static_cast<TargetDmabufPool*>(data);

        Buffer* b;
        wl_list_for_each(b, &target.m_buffer.list, link) {
            if (buffer == b->buffer) {
                b->locked = false;
                break;
            }
        }
    }
};

} } // namespace WS::EGLClient
