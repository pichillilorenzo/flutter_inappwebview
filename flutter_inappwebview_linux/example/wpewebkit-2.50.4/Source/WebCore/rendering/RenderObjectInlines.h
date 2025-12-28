/**
 * Copyright (C) 2023 Apple Inc. All rights reserved.
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

#include "DocumentInlines.h"
#include "FloatQuad.h"
#include "FrameDestructionObserverInlines.h"
#include "LocalFrameInlines.h"
#include "RenderElement.h"
#include "RenderIFrame.h"
#include "RenderObject.h"
#include "RenderReplaced.h"
#include "RenderStyleInlines.h"
#include "RenderView.h"

namespace WebCore {

inline Node& RenderObject::nodeForNonAnonymous() const { ASSERT(!isAnonymous()); return m_node.get(); }
inline bool RenderObject::hasTransformOrPerspective() const { return hasTransformRelatedProperty() && (isTransformed() || style().hasPerspective()); }
inline bool RenderObject::isAtomicInlineLevelBox() const { return style().isDisplayInlineType() && !(style().display() == DisplayType::Inline && !isBlockLevelReplacedOrAtomicInline()); }
inline bool RenderObject::isTransformed() const { return hasTransformRelatedProperty() && (style().affectsTransform() || hasSVGTransform()); }
inline Document& RenderObject::document() const { return m_node.get().document(); }
inline Ref<Document> RenderObject::protectedDocument() const { return document(); }
inline const LocalFrameViewLayoutContext& RenderObject::layoutContext() const { return view().frameView().layoutContext(); }
inline bool RenderObject::isBody() const { return node() && node()->hasTagName(HTMLNames::bodyTag); }
inline bool RenderObject::isHR() const { return node() && node()->hasTagName(HTMLNames::hrTag); }
inline bool RenderObject::isPseudoElement() const { return node() && node()->isPseudoElement(); }
inline Node* RenderObject::nonPseudoNode() const { return isPseudoElement() ? nullptr : node(); }
inline TreeScope& RenderObject::treeScopeForSVGReferences() const { return Ref { m_node.get() }->treeScopeForSVGReferences(); }
inline WritingMode RenderObject::writingMode() const { return style().writingMode(); }

inline Node* RenderObject::node() const
{
    if (isAnonymous())
        return nullptr;
    return m_node.ptr();
}

inline RefPtr<Node> RenderObject::protectedNode() const
{
    return node();
}

inline const RenderStyle& RenderObject::style() const
{
    if (isRenderText())
        return m_parent->style();
    return downcast<RenderElement>(*this).style();
}

inline CheckedRef<const RenderStyle> RenderObject::checkedStyle() const
{
    return style();
}

inline const RenderStyle& RenderObject::firstLineStyle() const
{
    if (isRenderText())
        return checkedParent()->firstLineStyle();
    return downcast<RenderElement>(*this).firstLineStyle();
}

inline Ref<TreeScope> RenderObject::protectedTreeScopeForSVGReferences() const
{
    return treeScopeForSVGReferences();
}

inline bool RenderObject::isDocumentElementRenderer() const
{
    return document().documentElement() == m_node.ptr();
}

inline RenderView& RenderObject::view() const
{
    return *document().renderView();
}

inline LocalFrame& RenderObject::frame() const
{
    return *document().frame();
}

inline Ref<LocalFrame> RenderObject::protectedFrame() const
{
    return frame();
}

inline Page& RenderObject::page() const
{
    // The render tree will always be torn down before Frame is disconnected from Page,
    // so it's safe to assume Frame::page() is non-null as long as there are live RenderObjects.
    ASSERT(frame().page());
    return *frame().page();
}

inline Ref<Page> RenderObject::protectedPage() const
{
    return page();
}

inline Settings& RenderObject::settings() const
{
    return page().settings();
}

inline bool RenderObject::renderTreeBeingDestroyed() const
{
    return document().renderTreeBeingDestroyed();
}

inline FloatQuad RenderObject::localToAbsoluteQuad(const FloatQuad& quad, OptionSet<MapCoordinatesMode> mode, bool* wasFixed) const
{
    return localToContainerQuad(quad, nullptr, mode, wasFixed);
}

inline void RenderObject::setNeedsLayout(MarkingBehavior markParents)
{
    ASSERT(!isSetNeedsLayoutForbidden());
    if (selfNeedsLayout())
        return;
    m_stateBitfields.setFlag(StateFlag::NeedsLayout);
    if (markParents == MarkContainingBlockChain)
        scheduleLayout(CheckedPtr { markContainingBlocksForLayout() }.get());
    if (hasLayer())
        setLayerNeedsFullRepaint();
}

inline void RenderObject::setNeedsLayoutAndPreferredWidthsUpdate()
{
    setNeedsLayout();
    setNeedsPreferredWidthsUpdate();
}

inline bool RenderObject::isNonReplacedAtomicInlineLevelBox() const
{
    // FIXME: Check if iframe should really behave like non-replaced here.
    return (is<RenderIFrame>(*this) && isInline()) || (!is<RenderReplaced>(*this) && isAtomicInlineLevelBox());
}

} // namespace WebCore
