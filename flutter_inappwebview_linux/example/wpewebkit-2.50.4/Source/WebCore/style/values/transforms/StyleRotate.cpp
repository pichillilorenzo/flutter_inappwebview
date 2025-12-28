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
#include "StyleRotate.h"

#include "StyleBuilderChecking.h"
#include "StylePrimitiveNumericTypes+Blending.h"

namespace WebCore {
namespace Style {

bool Rotate::apply(TransformationMatrix& transform, const FloatSize& size) const
{
    RefPtr protectedValue = value;
    return protectedValue && protectedValue->apply(transform, size);
}

// MARK: - Conversion

auto CSSValueConversion<Rotate>::operator()(BuilderState& state, const CSSValue& value) -> Rotate
{
    // https://drafts.csswg.org/css-transforms-2/#propdef-rotate
    // none | <angle> | [ x | y | z | <number>{3} ] && <angle>

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

    // Only an angle was specified.
    if (list->size() == 1)
        return Rotate { RotateTransformOperation::create(list->item(0).resolveAsAngle(conversionData), TransformOperation::Type::Rotate) };

    // An axis identifier and angle were specified.
    if (list->size() == 2) {
        auto axis = list->item(0).valueID();
        auto angle = list->item(1).resolveAsAngle(conversionData);

        switch (axis) {
        case CSSValueX:
            return Rotate { RotateTransformOperation::create(1, 0, 0, angle, TransformOperation::Type::RotateX) };
        case CSSValueY:
            return Rotate { RotateTransformOperation::create(0, 1, 0, angle, TransformOperation::Type::RotateY) };
        case CSSValueZ:
            return Rotate { RotateTransformOperation::create(0, 0, 1, angle, TransformOperation::Type::RotateZ) };
        default:
            break;
        }
        ASSERT_NOT_REACHED();
        return Rotate { RotateTransformOperation::create(angle, TransformOperation::Type::Rotate) };
    }

    ASSERT(list->size() == 4);

    // An axis vector and angle were specified.
    auto x = list->item(0).resolveAsNumber(conversionData);
    auto y = list->item(1).resolveAsNumber(conversionData);
    auto z = list->item(2).resolveAsNumber(conversionData);
    auto angle = list->item(3).resolveAsAngle(conversionData);

    return Rotate { RotateTransformOperation::create(x, y, z, angle, TransformOperation::Type::Rotate3D) };
}

// MARK: - Blending

auto Blending<Rotate>::blend(const Rotate& from, const Rotate& to, const BlendingContext& context) -> Rotate
{
    RefPtr fromRotate = from.value;
    RefPtr toRotate = to.value;

    if (!fromRotate && !toRotate)
        return CSS::Keyword::None { };

    auto identity = [&](const auto& other) {
        return RotateTransformOperation::create(0, other.type());
    };

    auto fromOperation = fromRotate ? Ref(*fromRotate) : identity(*toRotate);
    auto toOperation = toRotate ? Ref(*toRotate) : identity(*fromRotate);

    // Ensure the two transforms have the same type.
    if (!fromOperation->isSameType(toOperation)) {
        RefPtr<RotateTransformOperation> normalizedFrom;
        RefPtr<RotateTransformOperation> normalizedTo;
        if (fromOperation->is3DOperation() || toOperation->is3DOperation()) {
            normalizedFrom = RotateTransformOperation::create(fromOperation->x(), fromOperation->y(), fromOperation->z(), fromOperation->angle(), TransformOperation::Type::Rotate3D);
            normalizedTo = RotateTransformOperation::create(toOperation->x(), toOperation->y(), toOperation->z(), toOperation->angle(), TransformOperation::Type::Rotate3D);
        } else {
            normalizedFrom = RotateTransformOperation::create(fromOperation->angle(), TransformOperation::Type::Rotate);
            normalizedTo = RotateTransformOperation::create(toOperation->angle(), TransformOperation::Type::Rotate);
        }
        return blend(Rotate { normalizedFrom.releaseNonNull() }, Rotate { normalizedTo.releaseNonNull() }, context);
    }

    if (auto blendedOperation = toOperation->blend(fromOperation.ptr(), context); RefPtr rotate = dynamicDowncast<RotateTransformOperation>(blendedOperation))
        return Rotate { RotateTransformOperation::create(rotate->x(), rotate->y(), rotate->z(), rotate->angle(), rotate->type()) };

    return CSS::Keyword::None { };
}

// MARK: - Platform

auto ToPlatform<Rotate>::operator()(const Rotate& value) -> RefPtr<Rotate::Platform>
{
    return value.value;
}

} // namespace Style
} // namespace WebCore
