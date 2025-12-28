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

#include "ScaleTransformOperation.h"
#include "StylePrimitiveNumericTypes.h"
#include "StyleTransformOperationWrapper.h"
#include <wtf/PointerComparison.h>

namespace WebCore {
namespace Style {

// <'scale'> = none | [ <number> | <percentage> ]{1,3}
// https://drafts.csswg.org/css-transforms-2/#propdef-scale
struct Scale {
    using Platform = ScaleTransformOperation;
    struct Operation : TransformOperationWrapper<Platform> {
        using TransformOperationWrapper<Platform>::TransformOperationWrapper;

        template<typename... F> decltype(auto) switchOn(F&&...) const;
    };

    Scale(CSS::Keyword::None) : value { nullptr } { }
    Scale(Operation&& value) : value { WTFMove(value.value) } { }

    bool affectedByTransformOrigin() const { return value && !value->isIdentity(); }
    bool isRepresentableIn2D() const { return !value || value->isRepresentableIn2D(); }
    bool is3DOperation() const { return value && value->is3DOperation(); }

    bool apply(TransformationMatrix&, const FloatSize&) const;

    bool isNone() const { return !value; }
    bool isOperation() const { return !!value; }

    template<typename> bool holdsAlternative() const;
    template<typename... F> decltype(auto) switchOn(F&&...) const;

    bool operator==(const Scale& other) const
    {
        return arePointingToEqualData(value, other.value);
    }

private:
    friend struct Blending<Scale>;
    friend struct ToPlatform<Scale>;

    RefPtr<Platform> value;
};

// MARK: Scale Operation

template<typename... F> decltype(auto) Scale::Operation::switchOn(F&&... f) const
{
    auto visitor = WTF::makeVisitor(std::forward<F>(f)...);

    Ref protectedValue = value;
    if (protectedValue->z() != 1)
        return visitor(SpaceSeparatedTuple { Number<> { protectedValue->x() }, Number<> { protectedValue->y() }, Number<> { protectedValue->z() } });
    if (protectedValue->x() != protectedValue->y())
        return visitor(SpaceSeparatedTuple { Number<> { protectedValue->x() }, Number<> { protectedValue->y() } });
    return visitor(Number<> { protectedValue->x() });
}

// MARK: Scale

template<typename T> bool Scale::holdsAlternative() const
{
         if constexpr (std::same_as<T, CSS::Keyword::None>) return isNone();
    else if constexpr (std::same_as<T, Operation>)          return isOperation();
}

template<typename... F> decltype(auto) Scale::switchOn(F&&... f) const
{
    auto visitor = WTF::makeVisitor(std::forward<F>(f)...);

    if (!value)
        return visitor(CSS::Keyword::None { });
    return visitor(Operation { *value });
}

// MARK: - Conversion

template<> struct CSSValueConversion<Scale> { auto operator()(BuilderState&, const CSSValue&) -> Scale; };

// MARK: - Blending

template<> struct Blending<Scale> {
    auto blend(const Scale&, const Scale&, const BlendingContext&) -> Scale;
};

// MARK: - Platform

template<> struct ToPlatform<Scale> { auto operator()(const Scale&) -> RefPtr<Scale::Platform>; };

} // namespace Style
} // namespace WebCore

DEFINE_VARIANT_LIKE_CONFORMANCE(WebCore::Style::Scale::Operation)
DEFINE_VARIANT_LIKE_CONFORMANCE(WebCore::Style::Scale)
