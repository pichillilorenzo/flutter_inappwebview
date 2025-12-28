/*
 * Copyright (C) 2025 Apple Inc. All rights reserved.
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
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. AND ITS CONTRIBUTORS ``AS IS''
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL APPLE INC. OR ITS CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

#pragma once

#include <wtf/JSONValues.h>
#include <wtf/RefPtr.h>

namespace WebCore {

enum class VideoProjectionMetadataKind : uint8_t {
    Unknown,
    Equirectangular,
    HalfEquirectangular,
    EquiAngularCubemap,
    Parametric,
    Pyramid,
    AppleImmersiveVideo,
};

struct VideoProjectionMetadata {
    using Kind = VideoProjectionMetadataKind;
    Kind kind;

    RefPtr<JSON::Value> parameters;

    friend bool operator==(const VideoProjectionMetadata&, const VideoProjectionMetadata&) = default;
};

WEBCORE_EXPORT String convertVideoProjectionMetadataToString(const VideoProjectionMetadata&);
WEBCORE_EXPORT String convertEnumerationToString(VideoProjectionMetadataKind);

} // namespace WebCore

namespace WTF {

template<typename> struct LogArgument;

template <>
struct LogArgument<WebCore::VideoProjectionMetadata> {
    static String toString(const WebCore::VideoProjectionMetadata& metadata)
    {
        return convertVideoProjectionMetadataToString(metadata);
    }
};

}
