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
#include "StyleSVGPaint.h"

#include "AnimationUtilities.h"
#include "CSSURLValue.h"
#include "ColorBlending.h"
#include "RenderStyle.h"
#include "StyleBuilderChecking.h"
#include "StyleColor.h"
#include "StyleForVisitedLink.h"
#include <wtf/text/TextStream.h>

namespace WebCore {
namespace Style {

auto CSSValueConversion<SVGPaint>::operator()(BuilderState& state, const CSSValue& value, ForVisitedLink forVisitedLink) -> SVGPaint
{
    // <paint> = none | <color> | <url> [none | <color>]? 

    if (RefPtr list = dynamicDowncast<CSSValueList>(value)) {
        RefPtr firstValue = list->item(0);
        RefPtr urlValue = requiredDowncast<CSSURLValue>(state, *firstValue);
        if (!urlValue) {
            return {
                .type = SVGPaintType::None,
                .url = URL::none(),
                .color = Color::currentColor()
            };
        }

        auto url = toStyle(urlValue->url(), state);

        if (list->size() == 1) {
            return {
                .type = SVGPaintType::URI,
                .url = WTFMove(url),
            };
        }

        RefPtr secondItem = list->item(1);
        if (RefPtr primitiveValue = dynamicDowncast<const CSSPrimitiveValue>(secondItem)) {
            switch (primitiveValue->valueID()) {
            case CSSValueNone:
                return {
                    .type = SVGPaintType::URINone,
                    .url = WTFMove(url),
                };
            case CSSValueCurrentcolor: {
                state.style().setDisallowsFastPathInheritance();
                return {
                    .type = SVGPaintType::URICurrentColor,
                    .url = WTFMove(url),
                    .color = Color::currentColor(),
                };
            }
            default:
                break;
            }
        }

        return {
            .type = SVGPaintType::URIRGBColor,
            .url = WTFMove(url),
            .color = toStyleFromCSSValue<Color>(state, *list->protectedItem(1), forVisitedLink)
        };
    }


    if (RefPtr urlValue = dynamicDowncast<CSSURLValue>(value)) {
        return {
            .type = SVGPaintType::URI,
            .url = toStyle(urlValue->url(), state),
        };
    }

    if (RefPtr primitiveValue = dynamicDowncast<CSSPrimitiveValue>(value)) {
        switch (primitiveValue->valueID()) {
        case CSSValueNone:
            return {
                .type = SVGPaintType::None,
            };
        case CSSValueCurrentcolor: {
            state.style().setDisallowsFastPathInheritance();
            return {
                .type = SVGPaintType::CurrentColor,
                .color = Color::currentColor(),
            };
        }
        default:
            break;
        }
    }

    return {
        .type = SVGPaintType::RGBColor,
        .color = toStyleFromCSSValue<Color>(state, value, forVisitedLink)
    };
}

// MARK: - Blending

auto Blending<SVGPaint>::equals(const SVGPaint& a, const SVGPaint& b, const RenderStyle& aStyle, const RenderStyle& bStyle) -> bool
{
    if (a.type != b.type)
        return false;

    // We only support animations between SVGPaints that are pure Color values.
    // For everything else we must return true for this method, otherwise
    // we will try to animate between values forever.
    if (a.type == SVGPaintType::RGBColor)
        return equalsForBlending(a.color, b.color, aStyle, bStyle);

    return true;
}

auto Blending<SVGPaint>::canBlend(const SVGPaint& a, const SVGPaint& b) -> bool
{
    auto isValidPaintType = [](SVGPaintType paintType) {
        return paintType == SVGPaintType::RGBColor || paintType == SVGPaintType::CurrentColor;
    };

    if (!isValidPaintType(a.type) || !isValidPaintType(b.type))
        return false;
    if (a.color.isCurrentColor() && b.color.isCurrentColor())
        return false;
    return true;
}

auto Blending<SVGPaint>::blend(const SVGPaint& a, const SVGPaint& b, const RenderStyle& aStyle, const RenderStyle& bStyle, const BlendingContext& context) -> SVGPaint
{
    return SVGPaint {
        .type = a.type,
        .url = URL::none(),
        .color = WebCore::blend(aStyle.colorResolvingCurrentColor(a.color), bStyle.colorResolvingCurrentColor(b.color), context)
    };
}

// MARK: - Logging

TextStream& operator<<(TextStream& ts, SVGPaintType paintType)
{
    switch (paintType) {
    case SVGPaintType::RGBColor: ts << "rgb-color"_s; break;
    case SVGPaintType::None: ts << "none"_s; break;
    case SVGPaintType::CurrentColor: ts << "current-color"_s; break;
    case SVGPaintType::URINone: ts << "uri-none"_s; break;
    case SVGPaintType::URICurrentColor: ts << "uri-current-color"_s; break;
    case SVGPaintType::URIRGBColor: ts << "uri-rgb-color"_s; break;
    case SVGPaintType::URI: ts << "uri"_s; break;
    }
    return ts;
}

} // namespace Style
} // namespace WebCore
