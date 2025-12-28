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

#include <epoxy/egl.h>
#include <memory>

namespace WS {

class BaseBackend;
class BaseTarget;

namespace EGLClient {

class BackendImpl {
public:
    template<typename T>
    static std::unique_ptr<BackendImpl> create(BaseBackend& base)
    {
        return std::unique_ptr<BackendImpl>(new T(base));
    }

    virtual ~BackendImpl() = default;

    virtual EGLNativeDisplayType nativeDisplay() const = 0;
    virtual uint32_t platform() const = 0;
};

class TargetImpl {
public:
    template<typename T>
    static std::unique_ptr<TargetImpl> create(BaseTarget& base, uint32_t width, uint32_t height)
    {
        return std::unique_ptr<TargetImpl>(new T(base, width, height));
    }

    virtual ~TargetImpl() = default;

    virtual EGLNativeWindowType nativeWindow() const = 0;

    virtual void resize(uint32_t width, uint32_t height) = 0;

    virtual void frameWillRender() = 0;
    virtual void frameRendered() = 0;

    virtual void deinitialize() = 0;
};

} } // namespace WS::EGLClient
