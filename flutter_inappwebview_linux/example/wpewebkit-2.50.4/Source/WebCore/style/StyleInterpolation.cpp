/*
 * Copyright (C) 2007-2023 Apple Inc. All rights reserved.
 * Copyright (C) 2012, 2013 Adobe Systems Incorporated. All rights reserved.
 * Copyright (C) 2025 Sam Weinig. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1.  Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer. 
 * 2.  Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution. 
 * 3.  Neither the name of Apple Inc. ("Apple") nor the names of
 *     its contributors may be used to endorse or promote products derived
 *     from this software without specific prior written permission. 
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE AND ITS CONTRIBUTORS "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL APPLE OR ITS CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "config.h"
#include "StyleInterpolation.h"

#include "CSSRegisteredCustomProperty.h"
#include "StyleCustomProperty.h"
#include "StyleCustomPropertyRegistry.h"
#include "StyleInterpolationClient.h"
#include "StyleInterpolationFunctions.h"
#include "StyleInterpolationWrapperBase.h"
#include "StyleInterpolationWrapperMap.h"
#include <wtf/ZippedRange.h>

namespace WebCore::Style::Interpolation {

DEFINE_ALLOCATOR_WITH_HEAP_IDENTIFIER(Animation);
// MARK: - Standard property interpolation support

static void interpolateStandardProperty(CSSPropertyID property, RenderStyle& destination, const RenderStyle& from, const RenderStyle& to, double progress, CompositeOperation compositeOperation, IterationCompositeOperation iterationCompositeOperation, double currentIteration, const Client& client)
{
    ASSERT(property != CSSPropertyInvalid && property != CSSPropertyCustom);

    auto* wrapper = WrapperMap::singleton().wrapper(property);
    if (!wrapper)
        return;

    auto isDiscrete = !wrapper->canInterpolate(from, to, compositeOperation);
    Context context { property, progress, isDiscrete, compositeOperation, iterationCompositeOperation, currentIteration, from.color(), to.color(), client };
    if (!CSSProperty::animationUsesNonNormalizedDiscreteInterpolation(property))
        context.normalizeProgress();
    wrapper->interpolate(destination, from, to, context);
#if !LOG_DISABLED
    wrapper->log(from, to, destination, progress);
#endif
}

// MARK: - Custom property interpolation support

static CustomProperty::Numeric blendFunc(const CustomProperty::Numeric& from, const CustomProperty::Numeric& to, const Context& context)
{
    ASSERT(from.unitType == to.unitType);
    return { blendFunc(from.value, to.value, context), from.unitType };
}

static std::optional<CustomProperty::Value> interpolateSyntaxValues(const RenderStyle& fromStyle, const RenderStyle& toStyle, const CustomProperty::Value& from, const CustomProperty::Value& to, const Context& context)
{
    if (std::holds_alternative<WebCore::Length>(from) && std::holds_alternative<WebCore::Length>(to))
        return blendFunc(std::get<WebCore::Length>(from), std::get<WebCore::Length>(to), context);

    if (std::holds_alternative<Style::Color>(from) && std::holds_alternative<Style::Color>(to)) {
        auto& fromStyleColor = std::get<Style::Color>(from);
        auto& toStyleColor = std::get<Style::Color>(to);
        if (!fromStyleColor.isCurrentColor() || !toStyleColor.isCurrentColor())
            return blendFunc(fromStyle.colorResolvingCurrentColor(fromStyleColor), toStyle.colorResolvingCurrentColor(toStyleColor), context);
    }

    if (std::holds_alternative<CustomProperty::Numeric>(from) && std::holds_alternative<CustomProperty::Numeric>(to)) {
        auto& fromNumeric = std::get<CustomProperty::Numeric>(from);
        auto& toNumeric = std::get<CustomProperty::Numeric>(to);
        if (fromNumeric.unitType == toNumeric.unitType)
            return blendFunc(fromNumeric, toNumeric, context);
    }

    if (std::holds_alternative<CustomProperty::Transform>(from) && std::holds_alternative<CustomProperty::Transform>(to)) {
        auto& fromTransformOperation = std::get<CustomProperty::Transform>(from).operation;
        auto& toTransformOperation = std::get<CustomProperty::Transform>(to).operation;
        return CustomProperty::Transform { blendFunc(fromTransformOperation, toTransformOperation, context) };
    }

    return std::nullopt;
}

static std::optional<CustomProperty::Value> firstValueInSyntaxValueLists(const CustomProperty::ValueList& a, const CustomProperty::ValueList& b)
{
    if (!a.values.isEmpty())
        return a.values[0];
    if (!b.values.isEmpty())
        return b.values[0];
    return std::nullopt;
}

static std::optional<CustomProperty::ValueList> interpolateSyntaxValueLists(const RenderStyle& fromStyle, const RenderStyle& toStyle, const CustomProperty::ValueList& from, const CustomProperty::ValueList& to, const Context& context)
{
    // We should only attempt to interpolate lists containing the same types. Since we know all items in a
    // list are of the same type, it is sufficient to check the first value from each list.
    if (from.values.size() && to.values.size() && from.values.first().index() != to.values.first().index())
        return std::nullopt;

    // https://drafts.css-houdini.org/css-properties-values-api-1/#animation-behavior-of-custom-properties
    auto firstValue = firstValueInSyntaxValueLists(from, to);

    if (!firstValue)
        return std::nullopt;

    // <transform-function> lists are special in that they don't require matching numbers of items.
    if (std::holds_alternative<CustomProperty::Transform>(*firstValue)) {
        auto transformOperationsFromSyntaxValueList = [](const CustomProperty::ValueList& list) {
            return TransformOperations {
                list.values.map([](auto& syntaxValue) {
                    ASSERT(std::holds_alternative<CustomProperty::Transform>(syntaxValue));
                    return std::get<CustomProperty::Transform>(syntaxValue).operation.copyRef();
                })
            };
        };

        auto fromTransformOperations = transformOperationsFromSyntaxValueList(from);
        auto toTransformOperations = transformOperationsFromSyntaxValueList(to);
        auto interpolatedTransformOperations = blendFunc(fromTransformOperations, toTransformOperations, context);

        auto interpolatedSyntaxValues = WTF::map(interpolatedTransformOperations, [](auto& transformOperation) -> CustomProperty::Value {
            return CustomProperty::Transform { transformOperation.copyRef() };
        });

        return CustomProperty::ValueList { WTFMove(interpolatedSyntaxValues), from.separator };
    }

    // Other lists must have matching sizes.
    if (from.values.size() != to.values.size())
        return std::nullopt;

    Vector<CustomProperty::Value> interpolatedSyntaxValues;
    interpolatedSyntaxValues.reserveInitialCapacity(from.values.size());
    for (auto [fromValue, toValue] : zippedRange(from.values, to.values)) {
        auto interpolatedSyntaxValue = interpolateSyntaxValues(fromStyle, toStyle, fromValue, toValue, context);
        if (!interpolatedSyntaxValue)
            return std::nullopt;
        interpolatedSyntaxValues.append(*interpolatedSyntaxValue);
    }

    return CustomProperty::ValueList { interpolatedSyntaxValues, from.separator };
}

static Ref<const CustomProperty> interpolatedCustomProperty(const RenderStyle& fromStyle, const RenderStyle& toStyle, const CustomProperty& from, const CustomProperty& to, const Context& context)
{
    if (std::holds_alternative<CustomProperty::Value>(from.value()) && std::holds_alternative<CustomProperty::Value>(to.value())) {
        auto& fromSyntaxValue = std::get<CustomProperty::Value>(from.value());
        auto& toSyntaxValue = std::get<CustomProperty::Value>(to.value());
        if (auto interpolatedSyntaxValue = interpolateSyntaxValues(fromStyle, toStyle, fromSyntaxValue, toSyntaxValue, context))
            return CustomProperty::createForValue(from.name(), WTFMove(*interpolatedSyntaxValue));
    }

    if (std::holds_alternative<CustomProperty::ValueList>(from.value()) && std::holds_alternative<CustomProperty::ValueList>(to.value())) {
        auto& fromSyntaxValueList = std::get<CustomProperty::ValueList>(from.value());
        auto& toSyntaxValueList = std::get<CustomProperty::ValueList>(to.value());
        if (auto interpolatedSyntaxValueList = interpolateSyntaxValueLists(fromStyle, toStyle, fromSyntaxValueList, toSyntaxValueList, context))
            return CustomProperty::createForValueList(from.name(), WTFMove(*interpolatedSyntaxValueList));
    }

    // Use a discrete interpolation for all other cases.
    return context.progress < 0.5 ? from : to;
}

static std::pair<const CustomProperty*, const CustomProperty*> customPropertyValuesForInterpolation(const AtomString& customProperty, const RenderStyle& fromStyle, const RenderStyle& toStyle)
{
    return { fromStyle.customPropertyValue(customProperty), toStyle.customPropertyValue(customProperty) };
}

static void interpolateCustomProperty(const AtomString& customProperty, RenderStyle& destination, const RenderStyle& from, const RenderStyle& to, double progress, CompositeOperation compositeOperation, IterationCompositeOperation iterationCompositeOperation, double currentIteration, const Client& client)
{
    Context context { customProperty, progress, false, compositeOperation, iterationCompositeOperation, currentIteration, from.color(), to.color(), client };

    auto [fromValue, toValue] = customPropertyValuesForInterpolation(customProperty, from, to);
    if (!fromValue || !toValue)
        return;

    bool isInherited = client.document()->customPropertyRegistry().isInherited(customProperty);
    destination.setCustomPropertyValue(interpolatedCustomProperty(from, to, *fromValue, *toValue, context), isInherited);
}

static bool syntaxValuesRequireInterpolationForAccumulativeIteration(const CustomProperty::Value& a, const CustomProperty::Value& b, bool isList)
{
    return WTF::switchOn(a,
        [b, isList](const WebCore::Length& aLength) {
            ASSERT(std::holds_alternative<WebCore::Length>(b));
            return !isList && lengthsRequireInterpolationForAccumulativeIteration(aLength, std::get<WebCore::Length>(b));
        },
        [](const RefPtr<TransformOperation>&) {
            return true;
        },
        [](const Style::Color&) {
            return true;
        },
        [](auto&) {
            return false;
        }
    );
}

static bool typeOfSyntaxValueCanBeInterpolated(const CustomProperty::Value& syntaxValue)
{
    return WTF::switchOn(syntaxValue,
        [](const WebCore::Length&) {
            return true;
        },
        [](const Color&) {
            return true;
        },
        [](CustomProperty::Numeric) {
            return true;
        },
        [](const CustomProperty::Transform&) {
            return true;
        },
        [](RefPtr<StyleImage>) {
            return false;
        },
        [](auto&) {
            return false;
        }
    );
}

// MARK: - Exposed functions

bool isAdditiveOrCumulative(const AnimatableCSSProperty& property)
{
    return WTF::switchOn(property,
        [](CSSPropertyID propertyId) {
            return !CSSProperty::animationUsesNonAdditiveOrCumulativeInterpolation(propertyId);
        },
        [](const AtomString&) {
            return true;
        }
    );
}

bool isAccelerated(const AnimatableCSSProperty& property, const Settings& settings)
{
    return WTF::switchOn(property,
        [&](CSSPropertyID propertyId) {
            return CSSProperty::animationIsAccelerated(propertyId, settings);
        },
        [](const AtomString&) {
            return false;
        }
    );
}

bool canInterpolate(const AnimatableCSSProperty& property)
{
    return WTF::switchOn(property,
        [](CSSPropertyID propertyId) {
            return propertyId == CSSPropertyCustom || !!WrapperMap::singleton().wrapper(propertyId);
        },
        [](const AtomString&) {
            // FIXME: This should only be true for properties that are registered custom properties.
            return true;
        }
    );
}

bool equals(const AnimatableCSSProperty& property, const RenderStyle& a, const RenderStyle& b, const Document&)
{
    return WTF::switchOn(property,
        [&](CSSPropertyID propertyId) {
            if (auto* wrapper = WrapperMap::singleton().wrapper(propertyId))
                return wrapper->equals(a, b);
            return true;
        },
        [&](const AtomString& customProperty) {
            auto [aCustomPropertyValue, bCustomPropertyValue] = customPropertyValuesForInterpolation(customProperty, a, b);
            if (aCustomPropertyValue && bCustomPropertyValue)
                return *aCustomPropertyValue == *bCustomPropertyValue;
            return !aCustomPropertyValue && !bCustomPropertyValue;
        }
    );
}

bool canInterpolate(const AnimatableCSSProperty& property, const RenderStyle& a, const RenderStyle& b, const Document&)
{
    return WTF::switchOn(property,
        [&](CSSPropertyID propertyId) {
            if (auto* wrapper = WrapperMap::singleton().wrapper(propertyId))
                return wrapper->canInterpolate(a, b, CompositeOperation::Replace);
            return true;
        },
        [&](const AtomString& customProperty) {
            auto [aCustomPropertyValue, bCustomPropertyValue] = customPropertyValuesForInterpolation(customProperty, a, b);
            if (!aCustomPropertyValue || !bCustomPropertyValue || aCustomPropertyValue == bCustomPropertyValue)
                return false;
            auto& aVariantValue = aCustomPropertyValue->value();
            auto& bVariantValue = bCustomPropertyValue->value();
            if (aVariantValue.index() != bVariantValue.index())
                return false;
            return WTF::switchOn(aVariantValue,
                [bVariantValue](const CustomProperty::ValueList& aValueList) {
                    auto bValueList = std::get<CustomProperty::ValueList>(bVariantValue);
                    if (aValueList == bValueList)
                        return false;
                    if (auto firstValue = firstValueInSyntaxValueLists(aValueList, bValueList)) {
                        // List sizes must match except for transform lists.
                        if (!std::holds_alternative<CustomProperty::Transform>(*firstValue)
                            && aValueList.values.size() != bValueList.values.size()) {
                            return false;
                        }
                        return typeOfSyntaxValueCanBeInterpolated(*firstValue);
                    }
                    return false;
                },
                [bVariantValue](const CustomProperty::Value& aSyntaxValue) {
                    auto bSyntaxValue = std::get<CustomProperty::Value>(bVariantValue);
                    return aSyntaxValue != bSyntaxValue && typeOfSyntaxValueCanBeInterpolated(aSyntaxValue);
                },
                [](auto&) {
                    return false;
                }
            );
        }
    );
}

void interpolate(const AnimatableCSSProperty& property, RenderStyle& destination, const RenderStyle& from, const RenderStyle& to, double progress, CompositeOperation compositeOperation, IterationCompositeOperation iterationCompositeOperation, double currentIteration, const Client& client)
{
    WTF::switchOn(property,
        [&](CSSPropertyID propertyId) {
            interpolateStandardProperty(propertyId, destination, from, to, progress, compositeOperation, iterationCompositeOperation, currentIteration, client);
        },
        [&](const AtomString& customProperty) {
            interpolateCustomProperty(customProperty, destination, from, to, progress, compositeOperation, iterationCompositeOperation, currentIteration, client);
        }
    );
}

void interpolate(const AnimatableCSSProperty& property, RenderStyle& destination, const RenderStyle& from, const RenderStyle& to, double progress, CompositeOperation compositeOperation, const Client& client)
{
    return interpolate(property, destination, from, to, progress, compositeOperation, IterationCompositeOperation::Replace, 0, client);
}

bool requiresInterpolationForAccumulativeIteration(const AnimatableCSSProperty& property, const RenderStyle& a, const RenderStyle& b, const Client&)
{
    return WTF::switchOn(property,
        [&](CSSPropertyID propertyId) {
            if (auto* wrapper = WrapperMap::singleton().wrapper(propertyId))
                return wrapper->requiresInterpolationForAccumulativeIteration(a, b);
            return false;
        },
        [&](const AtomString& customProperty) {
            auto [from, to] = customPropertyValuesForInterpolation(customProperty, a, b);
            if (!from || !to)
                return false;

            if (std::holds_alternative<CustomProperty::ValueList>(from->value()) && std::holds_alternative<CustomProperty::ValueList>(to->value())) {
                auto& fromSyntaxValues = std::get<CustomProperty::ValueList>(from->value()).values;
                auto& toSyntaxValues = std::get<CustomProperty::ValueList>(to->value()).values;
                if (fromSyntaxValues.size() != toSyntaxValues.size())
                    return false;
                for (auto [fromSyntaxValue, toSyntaxValue] : zippedRange(fromSyntaxValues, toSyntaxValues)) {
                    if (!syntaxValuesRequireInterpolationForAccumulativeIteration(fromSyntaxValue, toSyntaxValue, true))
                        return false;
                }
                return true;
            }

            if (std::holds_alternative<CustomProperty::Value>(from->value()) && std::holds_alternative<CustomProperty::Value>(to->value())) {
                auto& fromSyntaxValue = std::get<CustomProperty::Value>(from->value());
                auto& toSyntaxValue = std::get<CustomProperty::Value>(to->value());
                return syntaxValuesRequireInterpolationForAccumulativeIteration(fromSyntaxValue, toSyntaxValue, false);
            }

            return false;
        }
    );
}

} // namespace WebCore::Style::Interpolation
