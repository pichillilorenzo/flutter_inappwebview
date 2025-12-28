/*
 * Copyright (C) 1999 Antti Koivisto (koivisto@kde.org)
 * Copyright (C) 2004, 2005, 2006, 2007, 2008 Apple Inc. All rights reserved.
 * Copyright (C) 2025 Samuel Weinig <sam@webkit.org>
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
 *
 */

#include "config.h"
#include "StyleBoxData.h"

#include "RenderStyleConstants.h"
#include "RenderStyleDifference.h"
#include "RenderStyleInlines.h"
#include "StylePrimitiveNumericTypes+Logging.h"

namespace WebCore {

struct SameSizeAsStyleBoxData : public RefCounted<SameSizeAsStyleBoxData> {
    Length length[6];
    Style::VerticalAlign verticalAlign;
    uint8_t bitfield;
    int m_zIndex[2];
};
static_assert(sizeof(StyleBoxData) == sizeof(SameSizeAsStyleBoxData), "StyleBoxData should not grow");

DEFINE_ALLOCATOR_WITH_HEAP_IDENTIFIER(StyleBoxData);

StyleBoxData::StyleBoxData()
    : m_width(RenderStyle::initialSize())
    , m_height(RenderStyle::initialSize())
    , m_minWidth(RenderStyle::initialMinSize())
    , m_maxWidth(RenderStyle::initialMaxSize())
    , m_minHeight(RenderStyle::initialMinSize())
    , m_maxHeight(RenderStyle::initialMaxSize())
    , m_verticalAlign(RenderStyle::initialVerticalAlign())
    , m_hasAutoSpecifiedZIndex(true)
    , m_hasAutoUsedZIndex(true)
    , m_boxSizing(static_cast<unsigned>(BoxSizing::ContentBox))
    , m_boxDecorationBreak(static_cast<unsigned>(BoxDecorationBreak::Slice))
    , m_specifiedZIndex(0)
    , m_usedZIndex(0)
{
}

inline StyleBoxData::StyleBoxData(const StyleBoxData& o)
    : RefCounted<StyleBoxData>()
    , m_width(o.m_width)
    , m_height(o.m_height)
    , m_minWidth(o.m_minWidth)
    , m_maxWidth(o.m_maxWidth)
    , m_minHeight(o.m_minHeight)
    , m_maxHeight(o.m_maxHeight)
    , m_verticalAlign(o.m_verticalAlign)
    , m_hasAutoSpecifiedZIndex(o.m_hasAutoSpecifiedZIndex)
    , m_hasAutoUsedZIndex(o.m_hasAutoUsedZIndex)
    , m_boxSizing(o.m_boxSizing)
    , m_boxDecorationBreak(o.m_boxDecorationBreak)
    , m_specifiedZIndex(o.m_specifiedZIndex)
    , m_usedZIndex(o.m_usedZIndex)
{
}

Ref<StyleBoxData> StyleBoxData::copy() const
{
    return adoptRef(*new StyleBoxData(*this));
}

bool StyleBoxData::operator==(const StyleBoxData& o) const
{
    return m_width == o.m_width
        && m_height == o.m_height
        && m_minWidth == o.m_minWidth
        && m_maxWidth == o.m_maxWidth
        && m_minHeight == o.m_minHeight
        && m_maxHeight == o.m_maxHeight
        && m_verticalAlign == o.m_verticalAlign
        && m_usedZIndex == o.m_usedZIndex
        && m_hasAutoUsedZIndex == o.m_hasAutoUsedZIndex
        && m_boxSizing == o.m_boxSizing
        && m_boxDecorationBreak == o.m_boxDecorationBreak
        && m_specifiedZIndex == o.m_specifiedZIndex
        && m_hasAutoSpecifiedZIndex == o.m_hasAutoSpecifiedZIndex;
}

#if !LOG_DISABLED
void StyleBoxData::dumpDifferences(TextStream& ts, const StyleBoxData& other) const
{
    LOG_IF_DIFFERENT(m_width);
    LOG_IF_DIFFERENT(m_height);

    LOG_IF_DIFFERENT(m_minWidth);
    LOG_IF_DIFFERENT(m_maxWidth);

    LOG_IF_DIFFERENT(m_minHeight);
    LOG_IF_DIFFERENT(m_maxHeight);

    LOG_IF_DIFFERENT(m_verticalAlign);

    LOG_IF_DIFFERENT_WITH_CAST(bool, m_hasAutoSpecifiedZIndex);
    LOG_IF_DIFFERENT_WITH_CAST(bool, m_hasAutoUsedZIndex);

    LOG_IF_DIFFERENT_WITH_CAST(BoxSizing, m_boxSizing);
    LOG_IF_DIFFERENT_WITH_CAST(BoxDecorationBreak, m_boxDecorationBreak);

    LOG_IF_DIFFERENT(m_specifiedZIndex);
    LOG_IF_DIFFERENT(m_usedZIndex);
}
#endif

} // namespace WebCore
