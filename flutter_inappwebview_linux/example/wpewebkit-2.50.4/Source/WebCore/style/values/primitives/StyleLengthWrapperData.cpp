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
#include "StyleLengthWrapperData.h"

#include "AnimationUtilities.h"
#include "CalculationCategory.h"
#include "CalculationTree.h"
#include "CalculationValue.h"
#include "CalculationValueMap.h"
#include <wtf/ASCIICType.h>
#include <wtf/StdLibExtras.h>
#include <wtf/text/StringToIntegerConversion.h>
#include <wtf/text/StringView.h>
#include <wtf/text/TextStream.h>

namespace WebCore {
namespace Style {

LengthWrapperData::LengthWrapperData(Ref<CalculationValue>&& value)
    : m_type(LengthWrapperDataType::Calculated)
{
    m_calculationValueHandle = CalculationValueMap::calculationValues().insert(WTFMove(value));
}

CalculationValue& LengthWrapperData::calculationValue() const
{
    ASSERT(m_type == LengthWrapperDataType::Calculated);
    return CalculationValueMap::calculationValues().get(m_calculationValueHandle);
}

Ref<CalculationValue> LengthWrapperData::protectedCalculationValue() const
{
    return calculationValue();
}

void LengthWrapperData::ref() const
{
    ASSERT(m_type == LengthWrapperDataType::Calculated);
    CalculationValueMap::calculationValues().ref(m_calculationValueHandle);
}

void LengthWrapperData::deref() const
{
    ASSERT(m_type == LengthWrapperDataType::Calculated);
    CalculationValueMap::calculationValues().deref(m_calculationValueHandle);
}

LengthWrapperData::LengthWrapperData(const WebCore::Length& length)
{
    switch (length.type()) {
    case WebCore::LengthType::Fixed:
        m_type = LengthWrapperDataType::Fixed;
        m_isFloat = length.isFloat();
        if (m_isFloat)
            m_floatValue = length.value();
        else
            m_intValue = length.intValue();
        return;
    case WebCore::LengthType::Percent:
        m_type = LengthWrapperDataType::Percent;
        m_isFloat = length.isFloat();
        if (m_isFloat)
            m_floatValue = length.value();
        else
            m_intValue = length.intValue();
        return;
    case WebCore::LengthType::Relative:
        m_type = LengthWrapperDataType::Relative;
        m_isFloat = length.isFloat();
        if (m_isFloat)
            m_floatValue = length.value();
        else
            m_intValue = length.intValue();
        return;
    case WebCore::LengthType::Calculated:
        m_type = LengthWrapperDataType::Calculated;
        m_calculationValueHandle = CalculationValueMap::calculationValues().insert(length.protectedCalculationValue());
        return;
    case WebCore::LengthType::Auto:
        m_type = LengthWrapperDataType::Auto;
        return;
    case WebCore::LengthType::Content:
        m_type = LengthWrapperDataType::Content;
        return;
    case WebCore::LengthType::FillAvailable:
        m_type = LengthWrapperDataType::FillAvailable;
        return;
    case WebCore::LengthType::FitContent:
        m_type = LengthWrapperDataType::FitContent;
        return;
    case WebCore::LengthType::Intrinsic:
        m_type = LengthWrapperDataType::Intrinsic;
        return;
    case WebCore::LengthType::MinIntrinsic:
        m_type = LengthWrapperDataType::MinIntrinsic;
        return;
    case WebCore::LengthType::MinContent:
        m_type = LengthWrapperDataType::MinContent;
        return;
    case WebCore::LengthType::MaxContent:
        m_type = LengthWrapperDataType::MaxContent;
        return;
    case WebCore::LengthType::Normal:
        m_type = LengthWrapperDataType::Normal;
        return;
    case WebCore::LengthType::Undefined:
        m_type = LengthWrapperDataType::Undefined;
        return;
    }
    RELEASE_ASSERT_NOT_REACHED();
}

LengthWrapperData::LengthWrapperData(WebCore::Length&& length)
{
    switch (length.type()) {
    case WebCore::LengthType::Fixed:
        m_type = LengthWrapperDataType::Fixed;
        m_isFloat = length.isFloat();
        if (m_isFloat)
            m_floatValue = length.value();
        else
            m_intValue = length.intValue();
        return;
    case WebCore::LengthType::Percent:
        m_type = LengthWrapperDataType::Percent;
        m_isFloat = length.isFloat();
        if (m_isFloat)
            m_floatValue = length.value();
        else
            m_intValue = length.intValue();
        return;
    case WebCore::LengthType::Relative:
        m_type = LengthWrapperDataType::Relative;
        m_isFloat = length.isFloat();
        if (m_isFloat)
            m_floatValue = length.value();
        else
            m_intValue = length.intValue();
        return;
    case WebCore::LengthType::Calculated:
        m_type = LengthWrapperDataType::Calculated;
        m_calculationValueHandle = CalculationValueMap::calculationValues().insert(length.protectedCalculationValue());
        return;
    case WebCore::LengthType::Auto:
        m_type = LengthWrapperDataType::Auto;
        return;
    case WebCore::LengthType::Content:
        m_type = LengthWrapperDataType::Content;
        return;
    case WebCore::LengthType::FillAvailable:
        m_type = LengthWrapperDataType::FillAvailable;
        return;
    case WebCore::LengthType::FitContent:
        m_type = LengthWrapperDataType::FitContent;
        return;
    case WebCore::LengthType::Intrinsic:
        m_type = LengthWrapperDataType::Intrinsic;
        return;
    case WebCore::LengthType::MinIntrinsic:
        m_type = LengthWrapperDataType::MinIntrinsic;
        return;
    case WebCore::LengthType::MinContent:
        m_type = LengthWrapperDataType::MinContent;
        return;
    case WebCore::LengthType::MaxContent:
        m_type = LengthWrapperDataType::MaxContent;
        return;
    case WebCore::LengthType::Normal:
        m_type = LengthWrapperDataType::Normal;
        return;
    case WebCore::LengthType::Undefined:
        m_type = LengthWrapperDataType::Undefined;
        return;
    }
    RELEASE_ASSERT_NOT_REACHED();
}

WebCore::Length LengthWrapperData::toPlatform() const
{
    switch (type()) {
    case LengthWrapperDataType::Fixed:
        return m_isFloat
            ? WebCore::Length(m_floatValue, WebCore::LengthType::Fixed, m_hasQuirk)
            : WebCore::Length(m_intValue, WebCore::LengthType::Fixed, m_hasQuirk);
    case LengthWrapperDataType::Percent:
        return m_isFloat
            ? WebCore::Length(m_floatValue, WebCore::LengthType::Percent)
            : WebCore::Length(m_intValue, WebCore::LengthType::Percent);
    case LengthWrapperDataType::Relative:
        return m_isFloat
            ? WebCore::Length(m_floatValue, WebCore::LengthType::Relative)
            : WebCore::Length(m_intValue, WebCore::LengthType::Relative);
    case LengthWrapperDataType::Calculated:
        return WebCore::Length(protectedCalculationValue());
    case LengthWrapperDataType::FillAvailable:
        return WebCore::Length(WebCore::LengthType::FillAvailable);
    case LengthWrapperDataType::Auto:
        return WebCore::Length(WebCore::LengthType::Auto);
    case LengthWrapperDataType::Normal:
        return WebCore::Length(WebCore::LengthType::Normal);
    case LengthWrapperDataType::Content:
        return WebCore::Length(WebCore::LengthType::Content);
    case LengthWrapperDataType::Intrinsic:
        return WebCore::Length(WebCore::LengthType::Intrinsic);
    case LengthWrapperDataType::MinIntrinsic:
        return WebCore::Length(WebCore::LengthType::MinIntrinsic);
    case LengthWrapperDataType::MinContent:
        return WebCore::Length(WebCore::LengthType::MinContent);
    case LengthWrapperDataType::MaxContent:
        return WebCore::Length(WebCore::LengthType::MaxContent);
    case LengthWrapperDataType::FitContent:
        return WebCore::Length(WebCore::LengthType::FitContent);
    case LengthWrapperDataType::Undefined:
        return WebCore::Length(WebCore::LengthType::Undefined);
    }
    ASSERT_NOT_REACHED();
    return WebCore::Length();
}

LengthWrapperDataType LengthWrapperData::typeFromIndex(const IPCData& data)
{
    static_assert(WTF::VariantSizeV<IPCData> == 13);
    switch (data.index()) {
    case WTF::alternativeIndexV<AutoData, IPCData>:
        return LengthWrapperDataType::Auto;
    case WTF::alternativeIndexV<NormalData, IPCData>:
        return LengthWrapperDataType::Normal;
    case WTF::alternativeIndexV<RelativeData, IPCData>:
        return LengthWrapperDataType::Relative;
    case WTF::alternativeIndexV<PercentData, IPCData>:
        return LengthWrapperDataType::Percent;
    case WTF::alternativeIndexV<FixedData, IPCData>:
        return LengthWrapperDataType::Fixed;
    case WTF::alternativeIndexV<IntrinsicData, IPCData>:
        return LengthWrapperDataType::Intrinsic;
    case WTF::alternativeIndexV<MinIntrinsicData, IPCData>:
        return LengthWrapperDataType::MinIntrinsic;
    case WTF::alternativeIndexV<MinContentData, IPCData>:
        return LengthWrapperDataType::MinContent;
    case WTF::alternativeIndexV<MaxContentData, IPCData>:
        return LengthWrapperDataType::MaxContent;
    case WTF::alternativeIndexV<FillAvailableData, IPCData>:
        return LengthWrapperDataType::FillAvailable;
    case WTF::alternativeIndexV<FitContentData, IPCData>:
        return LengthWrapperDataType::FitContent;
    case WTF::alternativeIndexV<ContentData, IPCData>:
        return LengthWrapperDataType::Content;
    case WTF::alternativeIndexV<UndefinedData, IPCData>:
        return LengthWrapperDataType::Undefined;
    }
    RELEASE_ASSERT_NOT_REACHED();
}

LengthWrapperData::LengthWrapperData(IPCData&& data)
    : m_type(typeFromIndex(data))
{
    WTF::switchOn(data,
        [&](const FixedData& data) {
            WTF::switchOn(data.value,
                [&](float value) {
                    m_isFloat = true;
                    m_floatValue = value;
                },
                [&](int value) {
                    m_isFloat = false;
                    m_intValue = value;
                }
            );
            m_hasQuirk = data.hasQuirk;
        },
        [&](const RelativeData& data) {
            WTF::switchOn(data.value,
                [&](float value) {
                    m_isFloat = true;
                    m_floatValue = value;
                },
                [&](int value) {
                    m_isFloat = false;
                    m_intValue = value;
                }
            );
        },
        [&](const PercentData& data) {
            WTF::switchOn(data.value,
                [&](float value) {
                    m_isFloat = true;
                    m_floatValue = value;
                },
                [&](int value) {
                    m_isFloat = false;
                    m_intValue = value;
                }
            );
        },
        []<typename EmptyData>(EmptyData) requires std::is_empty_v<EmptyData> { }
    );
}

auto LengthWrapperData::ipcData() const -> IPCData
{
    switch (m_type) {
    case LengthWrapperDataType::Auto:
        return AutoData { };
    case LengthWrapperDataType::Normal:
        return NormalData { };
    case LengthWrapperDataType::Relative:
        return RelativeData { floatOrInt() };
    case LengthWrapperDataType::Percent:
        return PercentData { floatOrInt() };
    case LengthWrapperDataType::Fixed:
        return FixedData { floatOrInt(), m_hasQuirk };
    case LengthWrapperDataType::Intrinsic:
        return IntrinsicData { };
    case LengthWrapperDataType::MinIntrinsic:
        return MinIntrinsicData { };
    case LengthWrapperDataType::MinContent:
        return MinContentData { };
    case LengthWrapperDataType::MaxContent:
        return MaxContentData { };
    case LengthWrapperDataType::FillAvailable:
        return FillAvailableData { };
    case LengthWrapperDataType::FitContent:
        return FitContentData { };
    case LengthWrapperDataType::Content:
        return ContentData { };
    case LengthWrapperDataType::Undefined:
        return UndefinedData { };
    case LengthWrapperDataType::Calculated:
        ASSERT_NOT_REACHED();
        return { };
    }
    RELEASE_ASSERT_NOT_REACHED();
}

auto LengthWrapperData::floatOrInt() const -> FloatOrInt
{
    ASSERT(m_type != LengthWrapperDataType::Calculated);
    if (m_isFloat)
        return m_floatValue;
    return m_intValue;
}

float LengthWrapperData::nonNanCalculatedValue(float maxValue) const
{
    ASSERT(m_type == LengthWrapperDataType::Calculated);
    float result = protectedCalculationValue()->evaluate(maxValue);
    if (std::isnan(result))
        return 0;
    return result;
}

bool LengthWrapperData::isCalculatedEqual(const LengthWrapperData& other) const
{
    return calculationValue() == other.calculationValue();
}

static Calculation::Child lengthCalculation(const LengthWrapperData& length)
{
    if (length.type() == LengthWrapperDataType::Percent)
        return Calculation::percentage(length.value());

    if (length.type() == LengthWrapperDataType::Calculated)
        return length.calculationValue().copyRoot();

    ASSERT(length.type() == LengthWrapperDataType::Fixed);
    return Calculation::dimension(length.value());
}

static LengthWrapperData makeLengthWrapperData(Calculation::Child&& root)
{
    // FIXME: Value range should be passed in.

    // NOTE: category is always `LengthPercentage` as late resolved `LengthWrapperData` values defined by percentages is the only reason calculation value is needed by `LengthWrapperData`.
    return LengthWrapperData(CalculationValue::create(Calculation::Category::LengthPercentage, Calculation::All, Calculation::Tree { WTFMove(root) }));
}

static LengthWrapperData blendLengthWrapperDataMixedTypes(const LengthWrapperData& from, const LengthWrapperData& to, const BlendingContext& context)
{
    if (context.compositeOperation != CompositeOperation::Replace)
        return makeLengthWrapperData(Calculation::add(lengthCalculation(from), lengthCalculation(to)));

    if ((from.type() != LengthWrapperDataType::Fixed
                && from.type() != LengthWrapperDataType::Percent
                && from.type() != LengthWrapperDataType::Calculated
                && from.type() != LengthWrapperDataType::Relative)
        || (to.type() != LengthWrapperDataType::Fixed
                && to.type() != LengthWrapperDataType::Percent
                && to.type() != LengthWrapperDataType::Calculated
                && to.type() != LengthWrapperDataType::Relative)) {
        ASSERT(context.isDiscrete);
        ASSERT(!context.progress || context.progress == 1);
        return context.progress ? to : from;
    }

    if (from.type() == LengthWrapperDataType::Relative || to.type() == LengthWrapperDataType::Relative)
        return { 0, LengthWrapperDataType::Fixed };

    if (to.type() != LengthWrapperDataType::Calculated && from.type() != LengthWrapperDataType::Percent && (context.progress == 1 || from.isZero()))
        return blendLengthWrapperData(LengthWrapperData(0, to.type()), to, context);

    if (from.type() != LengthWrapperDataType::Calculated && to.type() != LengthWrapperDataType::Percent && (!context.progress || to.isZero()))
        return blendLengthWrapperData(from, LengthWrapperData(0, from.type()), context);

    return makeLengthWrapperData(Calculation::blend(lengthCalculation(from), lengthCalculation(to), context.progress));
}

LengthWrapperData blendLengthWrapperData(const LengthWrapperData& from, const LengthWrapperData& to, const BlendingContext& context)
{
    if (from.type() == LengthWrapperDataType::Auto || to.type() == LengthWrapperDataType::Auto || from.type() == LengthWrapperDataType::Undefined || to.type() == LengthWrapperDataType::Undefined || from.type() == LengthWrapperDataType::Normal || to.type() == LengthWrapperDataType::Normal)
        return context.progress < 0.5 ? from : to;

    if (from.type() == LengthWrapperDataType::Calculated || to.type() == LengthWrapperDataType::Calculated || (from.type() != to.type()))
        return blendLengthWrapperDataMixedTypes(from, to, context);

    if (!context.progress && context.isReplace())
        return from;

    if (context.progress == 1 && context.isReplace())
        return to;

    auto resultType = to.type();
    if (to.isZero())
        resultType = from.type();

    if (resultType == LengthWrapperDataType::Percent) {
        float fromPercent = from.isZero() ? 0 : from.value();
        float toPercent = to.isZero() ? 0 : to.value();
        return LengthWrapperData(WebCore::blend(fromPercent, toPercent, context), LengthWrapperDataType::Percent);
    }

    float fromValue = from.isZero() ? 0 : from.value();
    float toValue = to.isZero() ? 0 : to.value();
    return LengthWrapperData(WebCore::blend(fromValue, toValue, context), resultType);
}

LengthWrapperData blendLengthWrapperData(const LengthWrapperData& from, const LengthWrapperData& to, const BlendingContext& context, ValueRange valueRange)
{
    auto blended = blendLengthWrapperData(from, to, context);
    if (valueRange == ValueRange::NonNegative && blended.isNegative()) {
        auto type = from.isZero() ? to.type() : from.type();
        if (type != LengthWrapperDataType::Calculated)
            return { 0, type };
        return { 0, LengthWrapperDataType::Fixed };
    }
    return blended;
}

static TextStream& operator<<(TextStream& ts, LengthWrapperDataType type)
{
    switch (type) {
    case LengthWrapperDataType::Auto: ts << "auto"_s; break;
    case LengthWrapperDataType::Calculated: ts << "calc"_s; break;
    case LengthWrapperDataType::Content: ts << "content"_s; break;
    case LengthWrapperDataType::FillAvailable: ts << "fill-available"_s; break;
    case LengthWrapperDataType::FitContent: ts << "fit-content"_s; break;
    case LengthWrapperDataType::Fixed: ts << "fixed"_s; break;
    case LengthWrapperDataType::Intrinsic: ts << "intrinsic"_s; break;
    case LengthWrapperDataType::MinIntrinsic: ts << "min-intrinsic"_s; break;
    case LengthWrapperDataType::MinContent: ts << "min-content"_s; break;
    case LengthWrapperDataType::MaxContent: ts << "max-content"_s; break;
    case LengthWrapperDataType::Normal: ts << "normal"_s; break;
    case LengthWrapperDataType::Percent: ts << "percent"_s; break;
    case LengthWrapperDataType::Relative: ts << "relative"_s; break;
    case LengthWrapperDataType::Undefined: ts << "undefined"_s; break;
    }
    return ts;
}

TextStream& operator<<(TextStream& ts, const LengthWrapperData& length)
{
    switch (length.type()) {
    case LengthWrapperDataType::Auto:
    case LengthWrapperDataType::Content:
    case LengthWrapperDataType::Normal:
    case LengthWrapperDataType::Undefined:
        ts << length.type();
        break;
    case LengthWrapperDataType::Fixed:
        ts << TextStream::FormatNumberRespectingIntegers(length.value()) << "px"_s;
        break;
    case LengthWrapperDataType::Relative:
    case LengthWrapperDataType::Intrinsic:
    case LengthWrapperDataType::MinIntrinsic:
    case LengthWrapperDataType::MinContent:
    case LengthWrapperDataType::MaxContent:
    case LengthWrapperDataType::FillAvailable:
    case LengthWrapperDataType::FitContent:
        ts << length.type() << ' ' << TextStream::FormatNumberRespectingIntegers(length.value());
        break;
    case LengthWrapperDataType::Percent:
        ts << TextStream::FormatNumberRespectingIntegers(length.value()) << '%';
        break;
    case LengthWrapperDataType::Calculated:
        ts << length.protectedCalculationValue();
        break;
    }

    if (length.hasQuirk())
        ts << " has-quirk"_s;

    return ts;
}

} // namespace Style
} // namespace WebCore
