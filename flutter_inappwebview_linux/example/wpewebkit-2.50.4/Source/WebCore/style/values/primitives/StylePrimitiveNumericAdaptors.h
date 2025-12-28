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

#include "Length.h"
#include "StylePrimitiveNumericTypes.h"

namespace WebCore {
namespace Style {

// Adaptor for a platform `WebCore::Length` acting as a `<length>`.
template<CSS::Range R = CSS::All> struct LengthAdaptor {
    WebCore::Length value;

    template<typename F> decltype(auto) switchOn(F&& functor) const
    {
        using Representation = Length<R>;

        ASSERT(value.isFixed());
        return functor(Representation { value.value() });
    }

    bool operator==(const LengthAdaptor<R>&) const = default;
};

// Adaptor for a platform `WebCore::Length` acting as a `<length-percentage>`.
template<CSS::Range R = CSS::All> struct LengthPercentageAdaptor {
    WebCore::Length value;

    template<typename F> decltype(auto) switchOn(F&& functor) const
    {
        using Representation = LengthPercentage<R>;

        switch (value.type()) {
        case WebCore::LengthType::Fixed:      return functor(typename Representation::Dimension { value.value() });
        case WebCore::LengthType::Percent:    return functor(typename Representation::Percentage { value.value() });
        case WebCore::LengthType::Calculated: return functor(typename Representation::Calc { value.calculationValue() });
        default:
            break;
        }
        RELEASE_ASSERT_NOT_REACHED();
    }

    bool operator==(const LengthPercentageAdaptor<R>&) const = default;
};

// Adaptor for a platform `WebCore::Length` acting as a `<length-percentage> | auto`.
template<CSS::Range R = CSS::All> struct LengthPercentageOrAutoAdaptor {
    WebCore::Length value;

    template<typename F> decltype(auto) switchOn(F&& functor) const
    {
        using Representation = LengthPercentage<R>;

        switch (value.type()) {
        case WebCore::LengthType::Fixed:      return functor(typename Representation::Dimension { value.value() });
        case WebCore::LengthType::Percent:    return functor(typename Representation::Percentage { value.value() });
        case WebCore::LengthType::Calculated: return functor(typename Representation::Calc { value.calculationValue() });
        case WebCore::LengthType::Auto:       return functor(CSS::Keyword::Auto { });
        default:
            break;
        }
        RELEASE_ASSERT_NOT_REACHED();
    }

    bool operator==(const LengthPercentageOrAutoAdaptor<R>&) const = default;
};

} // namespace Style
} // namespace WebCore

template<auto R> inline constexpr auto WebCore::TreatAsVariantLike<WebCore::Style::LengthAdaptor<R>> = true;
template<auto R> inline constexpr auto WebCore::TreatAsVariantLike<WebCore::Style::LengthPercentageAdaptor<R>> = true;
template<auto R> inline constexpr auto WebCore::TreatAsVariantLike<WebCore::Style::LengthPercentageOrAutoAdaptor<R>> = true;
