/*
 * Copyright (C) 2025 Apple Inc. All rights reserved.
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
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "config.h"
#include "SerializedNode.h"

#include "Attr.h"
#include "CDATASection.h"
#include "Comment.h"
#include "DocumentInlines.h"
#include "DocumentType.h"
#include "HTMLAttachmentElement.h"
#include "HTMLScriptElement.h"
#include "HTMLTemplateElement.h"
#include "JSNode.h"
#include "ProcessingInstruction.h"
#include "QualifiedName.h"
#include "SVGScriptElement.h"
#include "SecurityOriginPolicy.h"
#include "Text.h"
#include "TextResourceDecoder.h"
#include "WebVTTElement.h"

namespace WebCore {

WTF_MAKE_STRUCT_TZONE_ALLOCATED_IMPL(SerializedNode);

static void setAttributes(Element& element, Vector<SerializedNode::Element::Attribute>&& attributes)
{
    element.parserSetAttributes(WTF::map(WTFMove(attributes), [] (auto&& attribute) {
        return Attribute(WTFMove(attribute.name).qualifiedName(), AtomString(WTFMove(attribute.value)));
    }).span());
}

RefPtr<Node> SerializedNode::deserialize(SerializedNode&& serializedNode, WebCore::Document& document)
{
    auto serializedChildren = WTF::switchOn(serializedNode.data, [&] (SerializedNode::ContainerNode& containerNode) {
        return std::exchange(containerNode.children, { });
    }, []<typename T>(const T&) requires (!std::derived_from<T, SerializedNode::ContainerNode>) {
        return Vector<SerializedNode> { };
    });

    // FIXME: Support other kinds of nodes and change RefPtr to Ref.
    RefPtr node = WTF::switchOn(WTFMove(serializedNode.data), [&] (SerializedNode::Text&& text) -> RefPtr<Node> {
        return WebCore::Text::create(document, WTFMove(text.data));
    }, [&] (SerializedNode::ProcessingInstruction&& instruction) -> RefPtr<Node> {
        return WebCore::ProcessingInstruction::create(document, WTFMove(instruction.target), WTFMove(instruction.data));
    }, [&] (SerializedNode::DocumentType&& type) -> RefPtr<Node> {
        return WebCore::DocumentType::create(document, type.name, type.publicId, type.systemId);
    }, [&] (SerializedNode::Comment&& comment) -> RefPtr<Node> {
        return WebCore::Comment::create(document, WTFMove(comment.data));
    }, [&] (SerializedNode::CDATASection&& section) -> RefPtr<Node> {
        return WebCore::CDATASection::create(document, WTFMove(section.data));
    }, [&] (SerializedNode::Attr&& attr) -> RefPtr<Node> {
        return WebCore::Attr::create(document, WTFMove(attr.name).qualifiedName(), AtomString(WTFMove(attr.value)));
    }, [&] (SerializedNode::Document&& serializedDocument) -> RefPtr<Node> {
        return WebCore::Document::createCloned(
            serializedDocument.type,
            document.settings(),
            serializedDocument.url,
            serializedDocument.baseURL,
            serializedDocument.baseURLOverride,
            serializedDocument.documentURI,
            document.compatibilityMode(),
            document,
            RefPtr { document.securityOriginPolicy() }.get(),
            serializedDocument.contentType,
            document.protectedDecoder().get()
        );
    }, [&] (SerializedNode::Element&& element) -> RefPtr<Node> {
        constexpr bool createdByParser { false };
        Ref result = document.createElement(WTFMove(element.name).qualifiedName(), createdByParser);
        setAttributes(result, WTFMove(element.attributes));
        return result;
    }, [&] (SerializedNode::HTMLTemplateElement&& element) -> RefPtr<Node> {
        Ref result = WebCore::HTMLTemplateElement::create(WTFMove(element.name).qualifiedName(), document);
        setAttributes(result, WTFMove(element.attributes));
        return result;
    }, [] (auto&&) -> RefPtr<Node> {
        return nullptr;
    });

    RefPtr containerNode = dynamicDowncast<WebCore::ContainerNode>(node);
    for (auto&& child : WTFMove(serializedChildren)) {
        if (RefPtr childNode = deserialize(WTFMove(child), document)) {
            childNode->setTreeScopeRecursively(containerNode->protectedTreeScope());
            containerNode->appendChildCommon(*childNode);
        }
    }

    return node;
}

JSC::JSValue SerializedNode::deserialize(SerializedNode&& serializedNode, JSC::JSGlobalObject* lexicalGlobalObject, JSDOMGlobalObject* domGlobalObject, WebCore::Document& document)
{
    return toJSNewlyCreated(lexicalGlobalObject, domGlobalObject, deserialize(WTFMove(serializedNode), document));
}

SerializedNode::QualifiedName::QualifiedName(const WebCore::QualifiedName& name)
    : prefix(name.prefix())
    , localName(name.localName())
    , namespaceURI(name.namespaceURI())
{
}

SerializedNode::QualifiedName::QualifiedName(String&& prefix, String&& localName, String&& namespaceURI)
    : prefix(WTFMove(prefix))
    , localName(WTFMove(localName))
    , namespaceURI(WTFMove(namespaceURI))
{
}

QualifiedName SerializedNode::QualifiedName::qualifiedName() &&
{
    return WebCore::QualifiedName(AtomString(WTFMove(prefix)), AtomString(WTFMove(localName)), AtomString(WTFMove(namespaceURI)));
}

}
