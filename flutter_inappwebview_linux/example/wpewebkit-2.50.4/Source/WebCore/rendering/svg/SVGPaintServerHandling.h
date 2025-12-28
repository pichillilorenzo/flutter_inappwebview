/*
 * Copyright (C) 2023, 2024 Igalia S.L.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this library; see the file COPYING.LIB.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 */

#pragma once

#include "RenderSVGResourceGradient.h"
#include "RenderView.h"
#include "SVGRenderStyle.h"
#include "SVGRenderSupport.h"

namespace WebCore {

class SVGPaintServerHandling {
    WTF_MAKE_NONCOPYABLE(SVGPaintServerHandling);
public:
    SVGPaintServerHandling(GraphicsContext& context)
        : m_context(context)
    {
    }

    ~SVGPaintServerHandling() = default;

    GraphicsContext& context() const { return m_context; }

    enum class Operation : uint8_t {
        Fill,
        Stroke
    };

    template<Operation op>
    bool preparePaintOperation(const RenderLayerModelObject& renderer, const RenderStyle& style) const
    {
        auto paintServerResult = requestPaintServer<op>(renderer, style);
        if (std::holds_alternative<std::monostate>(paintServerResult))
            return false;

        if (std::holds_alternative<RenderSVGResourcePaintServer*>(paintServerResult)) {
            auto& paintServer = *std::get<RenderSVGResourcePaintServer*>(paintServerResult);
            if (op == Operation::Fill && paintServer.prepareFillOperation(m_context, renderer, style))
                return true;
            if (op == Operation::Stroke && paintServer.prepareStrokeOperation(m_context, renderer, style))
                return true;
            // Repeat the paint server request, but explicitly treating the paintServer as invalid/not-existant, to go through the fallback code path.
            paintServerResult = requestPaintServer<op, URIResolving::Disabled>(renderer, style);
            if (std::holds_alternative<std::monostate>(paintServerResult))
                return false;
        }

        ASSERT(std::holds_alternative<Color>(paintServerResult));
        const auto& color = std::get<Color>(paintServerResult);
        if (op == Operation::Fill)
            prepareFillOperation(renderer, style, color);
        else
            prepareStrokeOperation(renderer, style, color);

        return true;
    }

    enum class URIResolving : uint8_t {
        Enabled,
        Disabled
    };

    template<Operation op, URIResolving allowPaintServerURIResolving = URIResolving::Enabled>
    static SVGPaintServerOrColor requestPaintServer(const RenderLayerModelObject& targetRenderer, const RenderStyle& style)
    {
        // When rendering the mask for a RenderSVGResourceClipper, always use the initial fill paint server.
        if (targetRenderer.view().frameView().paintBehavior().contains(PaintBehavior::RenderingSVGClipOrMask))
            return op == Operation::Fill ? SVGRenderStyle::initialFill().color.resolvedColor() : SVGRenderStyle::initialStroke().color.resolvedColor();

        auto paintType = op == Operation::Fill ? style.svgStyle().fill().type : style.svgStyle().stroke().type;
        if (paintType == Style::SVGPaintType::None)
            return { };

        if (paintType >= Style::SVGPaintType::URINone) {
            if (allowPaintServerURIResolving == URIResolving::Disabled) {
                // If we found no paint server, and no fallback is desired, stop here.
                // We can only get here, if we previously requested a paint server, attempted to
                // prepare a fill or stroke operation, which failed. It can fail if, for example,
                // the paint sever is a gradient, gradientUnits are set to 'objectBoundingBox' and
                // the target is an one-dimensional object without a defined 'objectBoundingBox' (<line>).
                if (paintType == Style::SVGPaintType::URI || paintType == Style::SVGPaintType::URINone)
                    return { };
            } else {
                auto paintServerForOperation = [&]() {
                    if (op == Operation::Fill)
                        return targetRenderer.svgFillPaintServerResourceFromStyle(style);
                    return targetRenderer.svgStrokePaintServerResourceFromStyle(style);
                };

                // Try resolving URI first.
                if (auto* paintServer = paintServerForOperation())
                    return paintServer;

                // If we found no paint server, and no fallback is desired, stop here.
                if (paintType == Style::SVGPaintType::URI || paintType == Style::SVGPaintType::URINone)
                    return { };
            }
        }

        // Style::SVGPaintType::{CurrentColor, RGBColor, URICurrentColor, URIRGBColor} handling.
        auto color = resolveColorFromStyle<op>(style);
        if (inheritColorFromParentStyleIfNeeded<op>(targetRenderer, color))
            return color;
        return { };
    }

private:
    inline void prepareFillOperation(const RenderLayerModelObject& renderer, const RenderStyle& style, const Color& fillColor) const
    {
        Ref svgStyle = style.svgStyle();
        if (renderer.view().frameView().paintBehavior().contains(PaintBehavior::RenderingSVGClipOrMask)) {
            m_context.setAlpha(1);
            m_context.setFillRule(svgStyle->clipRule());
        } else {
            m_context.setAlpha(svgStyle->fillOpacity().value.value);
            m_context.setFillRule(svgStyle->fillRule());
        }

        m_context.setFillColor(style.colorByApplyingColorFilter(fillColor));
    }

    inline void prepareStrokeOperation(const RenderLayerModelObject& renderer, const RenderStyle& style, const Color& strokeColor) const
    {
        m_context.setAlpha(style.svgStyle().strokeOpacity().value.value);
        m_context.setStrokeColor(style.colorByApplyingColorFilter(strokeColor));
        SVGRenderSupport::applyStrokeStyleToContext(m_context, style, renderer);
    }

    template<Operation op>
    static inline Color resolveColorFromStyle(const RenderStyle& style)
    {
        Ref svgStyle = style.svgStyle();
        if (op == Operation::Fill)
            return resolveColorFromStyle(style, svgStyle->fill(), svgStyle->visitedLinkFill());
        return resolveColorFromStyle(style, svgStyle->stroke(), svgStyle->visitedLinkStroke());
    }

    static inline Color resolveColorFromStyle(const RenderStyle& style, const Style::SVGPaint& paint, const Style::SVGPaint& visitedLinkPaint)
    {
        // All paint types except None / URI / URINone handle solid colors.
        ASSERT(paint.type != Style::SVGPaintType::None);
        ASSERT(paint.type != Style::SVGPaintType::URI);
        ASSERT(paint.type != Style::SVGPaintType::URINone);

        auto color = style.colorResolvingCurrentColor(paint.color);
        if (style.insideLink() == InsideLink::InsideVisited) {
            // FIXME: This code doesn't support the uri component of the visited link paint, https://bugs.webkit.org/show_bug.cgi?id=70006
            if (visitedLinkPaint.type == Style::SVGPaintType::RGBColor) {
                const auto& visitedColor = style.colorResolvingCurrentColor(visitedLinkPaint.color);
                if (visitedColor.isValid())
                    color = visitedColor.colorWithAlpha(color.alphaAsFloat());
            }
        }

        return color;
    }

    template<Operation op>
    static inline bool inheritColorFromParentStyleIfNeeded(const RenderLayerModelObject& renderer, Color& color)
    {
        if (color.isValid())
            return true;
        if (!renderer.parent())
            return false;
        Ref parentSVGStyle = renderer.parent()->style().svgStyle();
        color = renderer.style().colorResolvingCurrentColor(op == Operation::Fill ? parentSVGStyle->fill().color : parentSVGStyle->stroke().color);
        return true;
    }

private:
    GraphicsContext& m_context;
};

} // namespace WebCore
