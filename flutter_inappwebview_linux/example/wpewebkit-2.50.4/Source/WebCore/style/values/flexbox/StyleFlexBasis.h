/*
 * Copyright (C) 2025 Samuel Weinig <sam@webkit.org>
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
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#pragma once

#include "StyleLengthWrapper.h"

namespace WebCore {
namespace Style {

struct PreferredSize;

// <'flex-basis'> = content | <‘width’>
// https://drafts.csswg.org/css-flexbox/#propdef-flex-basis
struct FlexBasis : LengthWrapperBase<LengthPercentage<CSS::Nonnegative>, CSS::Keyword::Content, CSS::Keyword::Auto, CSS::Keyword::MinContent, CSS::Keyword::MaxContent, CSS::Keyword::FitContent, CSS::Keyword::WebkitFillAvailable, CSS::Keyword::Intrinsic, CSS::Keyword::MinIntrinsic> {
    using Base::Base;

    // `FlexBasis` is a superset of `PreferredSize` and therefore this conversion can fail when type is `content`.
    std::optional<PreferredSize> tryPreferredSize() const;
};

} // namespace Style
} // namespace WebCore

DEFINE_VARIANT_LIKE_CONFORMANCE(WebCore::Style::FlexBasis)
