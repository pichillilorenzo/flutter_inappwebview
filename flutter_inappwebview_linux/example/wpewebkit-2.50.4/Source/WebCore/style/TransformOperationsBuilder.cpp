/*
 * Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012 Apple Inc. All rights reserved.
 * Copyright (C) 2012 Google Inc. All rights reserved.
 * Copyright (C) 2012, 2013 Adobe Systems Incorporated. All rights reserved.
 * Copyright (C) 2024-2025 Samuel Weinig <sam@webkit.org>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer.
 * 2. Redistributions in binary form must reproduce the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer in the documentation and/or other materials
 *    provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER “AS IS” AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
 * OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
 * TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
 * THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include "config.h"
#include "TransformOperationsBuilder.h"

#include "CSSFunctionValue.h"
#include "CSSPrimitiveValueMappings.h"
#include "CSSTransformListValue.h"
#include "CSSValueList.h"
#include "CalculationValue.h"
#include "Matrix3DTransformOperation.h"
#include "MatrixTransformOperation.h"
#include "PerspectiveTransformOperation.h"
#include "RotateTransformOperation.h"
#include "ScaleTransformOperation.h"
#include "SkewTransformOperation.h"
#include "StyleBuilderChecking.h"
#include "TransformOperations.h"
#include "TranslateTransformOperation.h"

namespace WebCore {
namespace Style {

static WebCore::Length resolveAsFloatPercentOrCalculatedLength(const CSSPrimitiveValue& primitiveValue, BuilderState& builderState)
{
    // FIXME: This should use `BuilderConverter::convertLength`, but doing so breaks transforms/hittest-translated-content-off-to-infinity-and-back.html, due to it using `resolveAsLength<WebCore::Length>` rather than `resolveAsLength<double>`, the difference being the former clamps between minValueForCssLength/maxValueForCssLength.

    auto& conversionData = builderState.cssToLengthConversionData();
    if (primitiveValue.isLength())
        return WebCore::Length(primitiveValue.resolveAsLength<double>(conversionData), LengthType::Fixed);
    if (primitiveValue.isPercentage())
        return WebCore::Length(primitiveValue.resolveAsPercentage<double>(conversionData), LengthType::Percent);
    if (primitiveValue.isCalculated())
        return WebCore::Length(primitiveValue.protectedCssCalcValue()->createCalculationValue(conversionData, CSSCalcSymbolTable { }));
    builderState.setCurrentPropertyInvalidAtComputedValueTime();
    return WebCore::Length(0, LengthType::Fixed);
}

// MARK: Matrix

static RefPtr<TransformOperation> createMatrixTransformOperation(const CSSFunctionValue& value, BuilderState& builderState)
{
    // https://drafts.csswg.org/css-transforms-1/#funcdef-transform-matrix
    // matrix() = matrix( <number>#{6} )

    auto function = requiredFunctionDowncast<CSSValueMatrix, CSSPrimitiveValue, 6>(builderState, value);
    if (!function)
        return { };

    auto& conversionData = builderState.cssToLengthConversionData();

    auto zoom = conversionData.zoom();
    return MatrixTransformOperation::create(
        function->item(0).resolveAsNumber(conversionData),
        function->item(1).resolveAsNumber(conversionData),
        function->item(2).resolveAsNumber(conversionData),
        function->item(3).resolveAsNumber(conversionData),
        function->item(4).resolveAsNumber(conversionData) * zoom,
        function->item(5).resolveAsNumber(conversionData) * zoom
    );
}

static RefPtr<TransformOperation> createMatrix3dTransformOperation(const CSSFunctionValue& value, BuilderState& builderState)
{
    // https://drafts.csswg.org/css-transforms-2/#funcdef-matrix3d
    // matrix3d() = matrix3d( <number>#{16} )

    auto function = requiredFunctionDowncast<CSSValueMatrix3d, CSSPrimitiveValue, 16>(builderState, value);
    if (!function)
        return { };

    auto& conversionData = builderState.cssToLengthConversionData();

    TransformationMatrix matrix(
        function->item(0).resolveAsNumber(conversionData),
        function->item(1).resolveAsNumber(conversionData),
        function->item(2).resolveAsNumber(conversionData),
        function->item(3).resolveAsNumber(conversionData),
        function->item(4).resolveAsNumber(conversionData),
        function->item(5).resolveAsNumber(conversionData),
        function->item(6).resolveAsNumber(conversionData),
        function->item(7).resolveAsNumber(conversionData),
        function->item(8).resolveAsNumber(conversionData),
        function->item(9).resolveAsNumber(conversionData),
        function->item(10).resolveAsNumber(conversionData),
        function->item(11).resolveAsNumber(conversionData),
        function->item(12).resolveAsNumber(conversionData),
        function->item(13).resolveAsNumber(conversionData),
        function->item(14).resolveAsNumber(conversionData),
        function->item(15).resolveAsNumber(conversionData)
    );
    matrix.zoom(conversionData.zoom());

    return Matrix3DTransformOperation::create(WTFMove(matrix));
}

// MARK: Rotate

static RefPtr<TransformOperation> createRotateTransformOperation(const CSSFunctionValue& value, BuilderState& builderState)
{
    // https://drafts.csswg.org/css-transforms-1/#funcdef-transform-rotate
    // rotate() = rotate( [ <angle> | <zero> ] )

    auto function = requiredFunctionDowncast<CSSValueRotate, CSSPrimitiveValue, 1>(builderState, value);
    if (!function)
        return { };

    auto& conversionData = builderState.cssToLengthConversionData();

    double x = 0;
    double y = 0;
    double z = 1;
    double angle = function->item(0).resolveAsAngle(conversionData);

    return RotateTransformOperation::create(x, y, z, angle, TransformOperation::Type::Rotate);
}

static RefPtr<TransformOperation> createRotate3dTransformOperation(const CSSFunctionValue& value, BuilderState& builderState)
{
    // https://drafts.csswg.org/css-transforms-2/#funcdef-rotate3d
    // rotate3d() = rotate3d( <number> , <number> , <number> , [ <angle> | <zero> ] )

    auto function = requiredFunctionDowncast<CSSValueRotate3d, CSSPrimitiveValue, 4>(builderState, value);
    if (!function)
        return { };

    auto& conversionData = builderState.cssToLengthConversionData();

    double x = function->item(0).resolveAsNumber(conversionData);
    double y = function->item(1).resolveAsNumber(conversionData);
    double z = function->item(2).resolveAsNumber(conversionData);
    double angle = function->item(3).resolveAsAngle(conversionData);

    return RotateTransformOperation::create(x, y, z, angle, TransformOperation::Type::Rotate3D);
}

static RefPtr<TransformOperation> createRotateXTransformOperation(const CSSFunctionValue& value, BuilderState& builderState)
{
    // https://drafts.csswg.org/css-transforms-2/#funcdef-rotatex
    // rotateX() = rotateX( [ <angle> | <zero> ] )

    auto function = requiredFunctionDowncast<CSSValueRotateX, CSSPrimitiveValue, 1>(builderState, value);
    if (!function)
        return { };

    auto& conversionData = builderState.cssToLengthConversionData();

    double x = 1;
    double y = 0;
    double z = 0;
    double angle = function->item(0).resolveAsAngle(conversionData);

    return RotateTransformOperation::create(x, y, z, angle, TransformOperation::Type::RotateX);
}

static RefPtr<TransformOperation> createRotateYTransformOperation(const CSSFunctionValue& value, BuilderState& builderState)
{
    // https://drafts.csswg.org/css-transforms-2/#funcdef-rotatey
    // rotateY() = rotateY( [ <angle> | <zero> ] )

    auto function = requiredFunctionDowncast<CSSValueRotateY, CSSPrimitiveValue, 1>(builderState, value);
    if (!function)
        return { };

    auto& conversionData = builderState.cssToLengthConversionData();

    double x = 0;
    double y = 1;
    double z = 0;
    double angle = function->item(0).resolveAsAngle(conversionData);

    return RotateTransformOperation::create(x, y, z, angle, TransformOperation::Type::RotateY);
}

static RefPtr<TransformOperation> createRotateZTransformOperation(const CSSFunctionValue& value, BuilderState& builderState)
{
    // https://drafts.csswg.org/css-transforms-2/#funcdef-rotatez
    // rotateZ() = rotateZ( [ <angle> | <zero> ] )

    auto function = requiredFunctionDowncast<CSSValueRotateZ, CSSPrimitiveValue, 1>(builderState, value);
    if (!function)
        return { };

    auto& conversionData = builderState.cssToLengthConversionData();

    double x = 0;
    double y = 0;
    double z = 1;
    double angle = function->item(0).resolveAsAngle(conversionData);

    return RotateTransformOperation::create(x, y, z, angle, TransformOperation::Type::RotateZ);
}

// MARK: Skew

static RefPtr<TransformOperation> createSkewTransformOperation(const CSSFunctionValue& value, BuilderState& builderState)
{
    // https://drafts.csswg.org/css-transforms-1/#funcdef-transform-skew
    // skew() = skew( [ <angle> | <zero> ] , [ <angle> | <zero> ]? )

    auto function = requiredFunctionDowncast<CSSValueSkew, CSSPrimitiveValue, 1>(builderState, value);
    if (!function)
        return { };

    auto& conversionData = builderState.cssToLengthConversionData();

    double angleX = function->item(0).resolveAsAngle(conversionData);
    double angleY = function->size() > 1 ? function->item(1).resolveAsAngle(conversionData) : 0;

    return SkewTransformOperation::create(angleX, angleY, TransformOperation::Type::Skew);
}

static RefPtr<TransformOperation> createSkewXTransformOperation(const CSSFunctionValue& value, BuilderState& builderState)
{
    // https://drafts.csswg.org/css-transforms-1/#funcdef-transform-skewx
    // skewX() = skewX( [ <angle> | <zero> ] )

    auto function = requiredFunctionDowncast<CSSValueSkewX, CSSPrimitiveValue, 1>(builderState, value);
    if (!function)
        return { };

    auto& conversionData = builderState.cssToLengthConversionData();

    double angleX = function->item(0).resolveAsAngle(conversionData);
    double angleY = 0;

    return SkewTransformOperation::create(angleX, angleY, TransformOperation::Type::SkewX);
}

static RefPtr<TransformOperation> createSkewYTransformOperation(const CSSFunctionValue& value, BuilderState& builderState)
{
    // https://drafts.csswg.org/css-transforms-1/#funcdef-transform-skewy
    // skewY() = skewY( [ <angle> | <zero> ] )

    auto function = requiredFunctionDowncast<CSSValueSkewY, CSSPrimitiveValue, 1>(builderState, value);
    if (!function)
        return { };

    auto& conversionData = builderState.cssToLengthConversionData();

    double angleX = 0;
    double angleY = function->item(0).resolveAsAngle(conversionData);

    return SkewTransformOperation::create(angleX, angleY, TransformOperation::Type::SkewY);
}

// MARK: Scale

static RefPtr<TransformOperation> createScaleTransformOperation(const CSSFunctionValue& value, BuilderState& builderState)
{
    // https://drafts.csswg.org/css-transforms-2/#funcdef-scale
    // scale() = scale( [ <number> | <percentage> ]#{1,2} )

    auto function = requiredFunctionDowncast<CSSValueScale, CSSPrimitiveValue, 1>(builderState, value);
    if (!function)
        return { };

    auto& conversionData = builderState.cssToLengthConversionData();

    double sx = function->item(0).valueDividingBy100IfPercentage<double>(conversionData);
    double sy = function->size() > 1 ? function->item(1).valueDividingBy100IfPercentage<double>(conversionData) : sx;
    double sz = 1;

    return ScaleTransformOperation::create(sx, sy, sz, TransformOperation::Type::Scale);
}

static RefPtr<TransformOperation> createScale3dTransformOperation(const CSSFunctionValue& value, BuilderState& builderState)
{
    // https://drafts.csswg.org/css-transforms-2/#funcdef-scale3d
    // scale3d() = scale3d( [ <number> | <percentage> ]#{3} )

    auto function = requiredFunctionDowncast<CSSValueScale3d, CSSPrimitiveValue, 3>(builderState, value);
    if (!function)
        return { };

    auto& conversionData = builderState.cssToLengthConversionData();

    double sx = function->item(0).valueDividingBy100IfPercentage<double>(conversionData);
    double sy = function->item(1).valueDividingBy100IfPercentage<double>(conversionData);
    double sz = function->item(2).valueDividingBy100IfPercentage<double>(conversionData);

    return ScaleTransformOperation::create(sx, sy, sz, TransformOperation::Type::Scale3D);
}

static RefPtr<TransformOperation> createScaleXTransformOperation(const CSSFunctionValue& value, BuilderState& builderState)
{
    // https://drafts.csswg.org/css-transforms-2/#funcdef-scalex
    // scaleX() = scaleX( [ <number> | <percentage> ] )

    auto function = requiredFunctionDowncast<CSSValueScaleX, CSSPrimitiveValue, 1>(builderState, value);
    if (!function)
        return { };

    auto& conversionData = builderState.cssToLengthConversionData();

    double sx = function->item(0).valueDividingBy100IfPercentage<double>(conversionData);
    double sy = 1;
    double sz = 1;

    return ScaleTransformOperation::create(sx, sy, sz, TransformOperation::Type::ScaleX);
}

static RefPtr<TransformOperation> createScaleYTransformOperation(const CSSFunctionValue& value, BuilderState& builderState)
{
    // https://drafts.csswg.org/css-transforms-2/#funcdef-scaley
    // scaleY() = scaleY( [ <number> | <percentage> ] )

    auto function = requiredFunctionDowncast<CSSValueScaleY, CSSPrimitiveValue, 1>(builderState, value);
    if (!function)
        return { };

    auto& conversionData = builderState.cssToLengthConversionData();

    double sx = 1;
    double sy = function->item(0).valueDividingBy100IfPercentage<double>(conversionData);
    double sz = 1;

    return ScaleTransformOperation::create(sx, sy, sz, TransformOperation::Type::ScaleY);
}

static RefPtr<TransformOperation> createScaleZTransformOperation(const CSSFunctionValue& value, BuilderState& builderState)
{
    // https://drafts.csswg.org/css-transforms-2/#funcdef-scalez
    // scaleZ() = scaleZ( [ <number> | <percentage> ] )

    auto function = requiredFunctionDowncast<CSSValueScaleZ, CSSPrimitiveValue, 1>(builderState, value);
    if (!function)
        return { };

    auto& conversionData = builderState.cssToLengthConversionData();

    double sx = 1.0;
    double sy = 1.0;
    double sz = function->item(0).valueDividingBy100IfPercentage<double>(conversionData);

    return ScaleTransformOperation::create(sx, sy, sz, TransformOperation::Type::ScaleZ);
}

// MARK: Translate

static RefPtr<TransformOperation> createTranslateTransformOperation(const CSSFunctionValue& value, BuilderState& builderState)
{
    // https://drafts.csswg.org/css-transforms-1/#funcdef-transform-translate
    // translate() = translate( <length-percentage> , <length-percentage>? )

    auto function = requiredFunctionDowncast<CSSValueTranslate, CSSPrimitiveValue, 1>(builderState, value);
    if (!function)
        return { };

    auto tx = resolveAsFloatPercentOrCalculatedLength(function->item(0), builderState);
    auto ty = function->size() > 1 ? resolveAsFloatPercentOrCalculatedLength(function->item(1), builderState) : WebCore::Length(0, LengthType::Fixed);
    auto tz = WebCore::Length(0, LengthType::Fixed);

    return TranslateTransformOperation::create(WTFMove(tx), WTFMove(ty), WTFMove(tz), TransformOperation::Type::Translate);
}

static RefPtr<TransformOperation> createTranslate3dTransformOperation(const CSSFunctionValue& value, BuilderState& builderState)
{
    // https://drafts.csswg.org/css-transforms-2/#funcdef-translate3d
    // translate3d() = translate3d( <length-percentage> , <length-percentage> , <length> )

    auto function = requiredFunctionDowncast<CSSValueTranslate3d, CSSPrimitiveValue, 3>(builderState, value);
    if (!function)
        return { };

    auto tx = resolveAsFloatPercentOrCalculatedLength(function->item(0), builderState);
    auto ty = resolveAsFloatPercentOrCalculatedLength(function->item(1), builderState);
    auto tz = resolveAsFloatPercentOrCalculatedLength(function->item(2), builderState);

    return TranslateTransformOperation::create(WTFMove(tx), WTFMove(ty), WTFMove(tz), TransformOperation::Type::Translate3D);
}

static RefPtr<TransformOperation> createTranslateXTransformOperation(const CSSFunctionValue& value, BuilderState& builderState)
{
    // https://drafts.csswg.org/css-transforms-1/#funcdef-transform-translatex
    // translateX() = translateX( <length-percentage> )

    auto function = requiredFunctionDowncast<CSSValueTranslateX, CSSPrimitiveValue, 1>(builderState, value);
    if (!function)
        return { };

    auto tx = resolveAsFloatPercentOrCalculatedLength(function->item(0), builderState);
    auto ty = WebCore::Length(0, LengthType::Fixed);
    auto tz = WebCore::Length(0, LengthType::Fixed);

    return TranslateTransformOperation::create(WTFMove(tx), WTFMove(ty), WTFMove(tz), TransformOperation::Type::TranslateX);
}

static RefPtr<TransformOperation> createTranslateYTransformOperation(const CSSFunctionValue& value, BuilderState& builderState)
{
    // https://drafts.csswg.org/css-transforms-1/#funcdef-transform-translatey
    // translateY() = translateY( <length-percentage> )

    auto function = requiredFunctionDowncast<CSSValueTranslateY, CSSPrimitiveValue, 1>(builderState, value);
    if (!function)
        return { };

    auto tx = WebCore::Length(0, LengthType::Fixed);
    auto ty = resolveAsFloatPercentOrCalculatedLength(function->item(0), builderState);
    auto tz = WebCore::Length(0, LengthType::Fixed);

    return TranslateTransformOperation::create(WTFMove(tx), WTFMove(ty), WTFMove(tz), TransformOperation::Type::TranslateY);
}

static RefPtr<TransformOperation> createTranslateZTransformOperation(const CSSFunctionValue& value, BuilderState& builderState)
{
    // https://drafts.csswg.org/css-transforms-2/#funcdef-translatez
    // translateZ() = translateZ( <length> )

    auto function = requiredFunctionDowncast<CSSValueTranslateZ, CSSPrimitiveValue, 1>(builderState, value);
    if (!function)
        return { };

    auto tx = WebCore::Length(0, LengthType::Fixed);
    auto ty = WebCore::Length(0, LengthType::Fixed);
    auto tz = resolveAsFloatPercentOrCalculatedLength(function->item(0), builderState);

    return TranslateTransformOperation::create(WTFMove(tx), WTFMove(ty), WTFMove(tz), TransformOperation::Type::TranslateZ);
}

// MARK: Perspective

static RefPtr<TransformOperation> createPerspectiveTransformOperation(const CSSFunctionValue& value, BuilderState& builderState)
{
    // https://drafts.csswg.org/css-transforms-2/#funcdef-perspective
    // perspective() = perspective( [ <length [0,∞]> | none ] )

    auto function = requiredFunctionDowncast<CSSValuePerspective, CSSPrimitiveValue, 1>(builderState, value);
    if (!function)
        return { };

    auto& parameter = function->item(0);
    if (parameter.isValueID()) {
        ASSERT(parameter.valueID() == CSSValueNone);
        return PerspectiveTransformOperation::create(std::nullopt);
    }

    if (parameter.isLength())
        return PerspectiveTransformOperation::create(resolveAsFloatPercentOrCalculatedLength(parameter, builderState));

    // FIXME: Support for <number> parameters for `perspective` is a quirk that should go away when 3d transforms are finalized.
    return PerspectiveTransformOperation::create(WebCore::Length(clampToPositiveInteger(parameter.resolveAsNumber<double>(builderState.cssToLengthConversionData())), LengthType::Fixed));
}

// MARK: <transform-operation>

RefPtr<TransformOperation> createTransformOperation(const CSSValue& value, BuilderState& builderState)
{
    auto transform = requiredDowncast<CSSFunctionValue>(builderState, value);
    if (!transform)
        return { };

    switch (transform->name()) {
    case CSSValueMatrix:
        return createMatrixTransformOperation(*transform, builderState);
    case CSSValueMatrix3d:
        return createMatrix3dTransformOperation(*transform, builderState);
    case CSSValueRotate:
        return createRotateTransformOperation(*transform, builderState);
    case CSSValueRotate3d:
        return createRotate3dTransformOperation(*transform, builderState);
    case CSSValueRotateX:
        return createRotateXTransformOperation(*transform, builderState);
    case CSSValueRotateY:
        return createRotateYTransformOperation(*transform, builderState);
    case CSSValueRotateZ:
        return createRotateZTransformOperation(*transform, builderState);
    case CSSValueSkew:
        return createSkewTransformOperation(*transform, builderState);
    case CSSValueSkewX:
        return createSkewXTransformOperation(*transform, builderState);
    case CSSValueSkewY:
        return createSkewYTransformOperation(*transform, builderState);
    case CSSValueScale:
        return createScaleTransformOperation(*transform, builderState);
    case CSSValueScale3d:
        return createScale3dTransformOperation(*transform, builderState);
    case CSSValueScaleX:
        return createScaleXTransformOperation(*transform, builderState);
    case CSSValueScaleY:
        return createScaleYTransformOperation(*transform, builderState);
    case CSSValueScaleZ:
        return createScaleZTransformOperation(*transform, builderState);
    case CSSValueTranslate:
        return createTranslateTransformOperation(*transform, builderState);
    case CSSValueTranslate3d:
        return createTranslate3dTransformOperation(*transform, builderState);
    case CSSValueTranslateX:
        return createTranslateXTransformOperation(*transform, builderState);
    case CSSValueTranslateY:
        return createTranslateYTransformOperation(*transform, builderState);
    case CSSValueTranslateZ:
        return createTranslateZTransformOperation(*transform, builderState);
    case CSSValuePerspective:
        return createPerspectiveTransformOperation(*transform, builderState);
    default:
        break;
    }

    RELEASE_ASSERT_NOT_REACHED();
}

TransformOperations createTransformOperations(const CSSValue& value, BuilderState& builderState)
{
    if (auto* primitiveValue = dynamicDowncast<CSSPrimitiveValue>(value)) {
        ASSERT_UNUSED(primitiveValue, primitiveValue->valueID() == CSSValueNone);
        return { };
    }

    auto transformList = requiredDowncast<CSSTransformListValue>(builderState, value);
    if (!transformList)
        return { };

    Vector<Ref<TransformOperation>> operations;
    operations.reserveInitialCapacity(transformList->size());

    for (auto& transformValue : *transformList) {
        auto operation = createTransformOperation(transformValue, builderState);
        if (!operation)
            return { };
        operations.append(*operation);
    }

    return TransformOperations { WTFMove(operations) };
}

} // namespace Style
} // namespace WebCore
