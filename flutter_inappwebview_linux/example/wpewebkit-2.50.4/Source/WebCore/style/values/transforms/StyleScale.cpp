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

#include "config.h"
#include "StyleScale.h"

#include "StyleBuilderChecking.h"
#include "StylePrimitiveNumericTypes+Blending.h"

namespace WebCore {
namespace Style {

bool Scale::apply(TransformationMatrix& transform, const FloatSize& size) const
{
    RefPtr protectedValue = value;
    return protectedValue && protectedValue->apply(transform, size);
}

// MARK: - Conversion

auto CSSValueConversion<Scale>::operator()(BuilderState& state, const CSSValue& value) -> Scale
{
    // https://drafts.csswg.org/css-transforms-2/#propdef-scale
    // none | [ <number> | <percentage> ]{1,3}

    auto conversionData = state.useSVGZoomRulesForLength()
        ? state.cssToLengthConversionData().copyWithAdjustedZoom(1.0f)
        : state.cssToLengthConversionData();

    if (RefPtr primitiveValue = dynamicDowncast<CSSPrimitiveValue>(value)) {
        ASSERT_UNUSED(primitiveValue, primitiveValue->valueID() == CSSValueNone);
        return CSS::Keyword::None { };
    }

    auto list = requiredListDowncast<CSSValueList, CSSPrimitiveValue>(state, value);
    if (!list)
        return CSS::Keyword::None { };

    auto sx = list->item(0).valueDividingBy100IfPercentage<double>(conversionData);
    auto sy = list->size() > 1 ? list->item(1).valueDividingBy100IfPercentage<double>(conversionData) : sx;
    auto sz = list->size() > 2 ? list->item(2).valueDividingBy100IfPercentage<double>(conversionData) : 1;

    return Scale { ScaleTransformOperation::create(sx, sy, sz, TransformOperation::Type::Scale) };
}

// MARK: - Blending

auto Blending<Scale>::blend(const Scale& from, const Scale& to, const BlendingContext& context) -> Scale
{
    RefPtr fromScale = from.value;
    RefPtr toScale = to.value;

    if (!fromScale && !toScale)
        return CSS::Keyword::None { };

    auto identity = [&](const auto& other) {
        return ScaleTransformOperation::create(1, 1, 1, other.type());
    };

    auto fromOperation = fromScale ? Ref(*fromScale) : identity(*toScale);
    auto toOperation = toScale ? Ref(*toScale) : identity(*fromScale);

    // Ensure the two transforms have the same type.
    if (!fromOperation->isSameType(toOperation)) {
        RefPtr<ScaleTransformOperation> normalizedFrom;
        RefPtr<ScaleTransformOperation> normalizedTo;
        if (fromOperation->is3DOperation() || toOperation->is3DOperation()) {
            normalizedFrom = ScaleTransformOperation::create(fromOperation->x(), fromOperation->y(), fromOperation->z(), TransformOperation::Type::Scale3D);
            normalizedTo = ScaleTransformOperation::create(toOperation->x(), toOperation->y(), toOperation->z(), TransformOperation::Type::Scale3D);
        } else {
            normalizedFrom = ScaleTransformOperation::create(fromOperation->x(), fromOperation->y(), TransformOperation::Type::Scale);
            normalizedTo = ScaleTransformOperation::create(toOperation->x(), toOperation->y(), TransformOperation::Type::Scale);
        }
        return blend(Scale { normalizedFrom.releaseNonNull() }, Scale { normalizedTo.releaseNonNull() }, context);
    }

    if (auto blendedOperation = toOperation->blend(fromOperation.ptr(), context); RefPtr scale = dynamicDowncast<ScaleTransformOperation>(blendedOperation))
        return Scale { ScaleTransformOperation::create(scale->x(), scale->y(), scale->z(), scale->type()) };

    return CSS::Keyword::None { };
}

// MARK: - Platform

auto ToPlatform<Scale>::operator()(const Scale& value) -> RefPtr<Scale::Platform>
{
    return value.value;
}

} // namespace Style
} // namespace WebCore
