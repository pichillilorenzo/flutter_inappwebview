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

#pragma once

#include "Length.h"

namespace WebCore {
namespace Style {

// Currently this is a copy of `WebCore::Length`. It is in the process of being refactored to be more general.

enum class LengthWrapperDataType : uint8_t {
    Auto,
    Normal,
    Relative,
    Percent,
    Fixed,
    Intrinsic,
    MinIntrinsic,
    MinContent,
    MaxContent,
    FillAvailable,
    FitContent,
    Calculated,
    Content,
    Undefined
};

struct LengthWrapperData {
    LengthWrapperData(LengthWrapperDataType = LengthWrapperDataType::Auto);

    using FloatOrInt = Variant<float, int>;
    struct AutoData { };
    struct NormalData { };
    struct FixedData {
        FloatOrInt value;
        bool hasQuirk;
    };
    struct RelativeData {
        FloatOrInt value;
    };
    struct PercentData {
        FloatOrInt value;
    };
    struct IntrinsicData { };
    struct MinIntrinsicData { };
    struct MinContentData { };
    struct MaxContentData { };
    struct FillAvailableData { };
    struct FitContentData { };
    struct ContentData { };
    struct UndefinedData { };
    using IPCData = Variant<
        AutoData,
        NormalData,
        RelativeData,
        PercentData,
        FixedData,
        IntrinsicData,
        MinIntrinsicData,
        MinContentData,
        MaxContentData,
        FillAvailableData,
        FitContentData,
        ContentData,
        UndefinedData
        // LengthWrapperDataType::Calculated is intentionally not serialized.
    >;

    WEBCORE_EXPORT LengthWrapperData(IPCData&&);
    LengthWrapperData(int value, LengthWrapperDataType, bool hasQuirk = false);
    LengthWrapperData(LayoutUnit value, LengthWrapperDataType, bool hasQuirk = false);
    LengthWrapperData(float value, LengthWrapperDataType, bool hasQuirk = false);
    LengthWrapperData(double value, LengthWrapperDataType, bool hasQuirk = false);
    WEBCORE_EXPORT explicit LengthWrapperData(Ref<CalculationValue>&&);
    explicit LengthWrapperData(WTF::HashTableEmptyValueType);

    LengthWrapperData(const LengthWrapperData&);
    LengthWrapperData(LengthWrapperData&&);
    LengthWrapperData& operator=(const LengthWrapperData&);
    LengthWrapperData& operator=(LengthWrapperData&&);

    ~LengthWrapperData();

    bool operator==(const LengthWrapperData&) const;

    LengthWrapperDataType type() const;

    float value() const;
    int intValue() const;
    CalculationValue& calculationValue() const;
    Ref<CalculationValue> protectedCalculationValue() const;

    struct Fixed { float value; };
    std::optional<Fixed> tryFixed() const { return m_type == LengthWrapperDataType::Fixed ? std::make_optional(Fixed { value() }) : std::nullopt; }

    struct Percentage { float value; };
    std::optional<Percentage> tryPercentage() const { return m_type == LengthWrapperDataType::Percent ? std::make_optional(Percentage { value() }) : std::nullopt; }

    explicit LengthWrapperData(const WebCore::Length&);
    explicit LengthWrapperData(WebCore::Length&&);
    WebCore::Length toPlatform() const;

    WEBCORE_EXPORT IPCData ipcData() const;

    bool isEmptyValue() const { return m_isEmptyValue; }

    bool hasQuirk() const;

    bool isZero() const;
    bool isPositive() const;
    bool isNegative() const;

    WEBCORE_EXPORT float nonNanCalculatedValue(float maxValue) const;

private:
    static LengthWrapperData createEmptyValue()
    {
        auto result = LengthWrapperData(LengthWrapperDataType::Undefined);
        result.m_isEmptyValue = true;
        return result;
    }

    bool isCalculatedEqual(const LengthWrapperData&) const;

    void initialize(const LengthWrapperData&);
    void initialize(LengthWrapperData&&);

    WEBCORE_EXPORT void ref() const;
    WEBCORE_EXPORT void deref() const;
    FloatOrInt floatOrInt() const;
    static LengthWrapperDataType typeFromIndex(const IPCData&);

    union {
        int m_intValue { 0 };
        float m_floatValue;
        unsigned m_calculationValueHandle;
    };
    LengthWrapperDataType m_type;
    bool m_hasQuirk { false };
    bool m_isFloat { false };
    bool m_isEmptyValue { false };
};

inline LengthWrapperData::LengthWrapperData(LengthWrapperDataType type)
    : m_type(type)
{
    ASSERT(type != LengthWrapperDataType::Calculated);
}

inline LengthWrapperData::LengthWrapperData(int value, LengthWrapperDataType type, bool hasQuirk)
    : m_intValue(value)
    , m_type(type)
    , m_hasQuirk(hasQuirk)
{
    ASSERT(type != LengthWrapperDataType::Calculated);
}

inline LengthWrapperData::LengthWrapperData(LayoutUnit value, LengthWrapperDataType type, bool hasQuirk)
    : m_floatValue(value.toFloat())
    , m_type(type)
    , m_hasQuirk(hasQuirk)
    , m_isFloat(true)
{
    ASSERT(type != LengthWrapperDataType::Calculated);
}

inline LengthWrapperData::LengthWrapperData(float value, LengthWrapperDataType type, bool hasQuirk)
    : m_floatValue(value)
    , m_type(type)
    , m_hasQuirk(hasQuirk)
    , m_isFloat(true)
{
    ASSERT(type != LengthWrapperDataType::Calculated);
}

inline LengthWrapperData::LengthWrapperData(double value, LengthWrapperDataType type, bool hasQuirk)
    : m_floatValue(static_cast<float>(value))
    , m_type(type)
    , m_hasQuirk(hasQuirk)
    , m_isFloat(true)
{
    ASSERT(type != LengthWrapperDataType::Calculated);
}

inline LengthWrapperData::LengthWrapperData(WTF::HashTableEmptyValueType)
    : m_type(LengthWrapperDataType::Undefined)
    , m_isEmptyValue(true)
{
}

inline LengthWrapperData::LengthWrapperData(const LengthWrapperData& other)
{
    initialize(other);
}

inline LengthWrapperData::LengthWrapperData(LengthWrapperData&& other)
{
    initialize(WTFMove(other));
}

inline LengthWrapperData& LengthWrapperData::operator=(const LengthWrapperData& other)
{
    if (this == &other)
        return *this;

    if (m_type == LengthWrapperDataType::Calculated)
        deref();

    initialize(other);
    return *this;
}

inline LengthWrapperData& LengthWrapperData::operator=(LengthWrapperData&& other)
{
    if (this == &other)
        return *this;

    if (m_type == LengthWrapperDataType::Calculated)
        deref();

    initialize(WTFMove(other));
    return *this;
}

inline void LengthWrapperData::initialize(const LengthWrapperData& other)
{
    m_type = other.m_type;
    m_hasQuirk = other.m_hasQuirk;
    m_isEmptyValue = other.m_isEmptyValue;

    switch (m_type) {
    case LengthWrapperDataType::Auto:
    case LengthWrapperDataType::Normal:
    case LengthWrapperDataType::Content:
    case LengthWrapperDataType::Undefined:
        m_intValue = 0;
        break;
    case LengthWrapperDataType::Fixed:
    case LengthWrapperDataType::Relative:
    case LengthWrapperDataType::Intrinsic:
    case LengthWrapperDataType::MinIntrinsic:
    case LengthWrapperDataType::MinContent:
    case LengthWrapperDataType::MaxContent:
    case LengthWrapperDataType::FillAvailable:
    case LengthWrapperDataType::FitContent:
    case LengthWrapperDataType::Percent:
        m_isFloat = other.m_isFloat;
        if (m_isFloat)
            m_floatValue = other.m_floatValue;
        else
            m_intValue = other.m_intValue;
        break;
    case LengthWrapperDataType::Calculated:
        m_calculationValueHandle = other.m_calculationValueHandle;
        ref();
        break;
    }
}

inline void LengthWrapperData::initialize(LengthWrapperData&& other)
{
    m_type = other.m_type;
    m_hasQuirk = other.m_hasQuirk;
    m_isEmptyValue = other.m_isEmptyValue;

    switch (m_type) {
    case LengthWrapperDataType::Auto:
    case LengthWrapperDataType::Normal:
    case LengthWrapperDataType::Content:
    case LengthWrapperDataType::Undefined:
        m_intValue = 0;
        break;
    case LengthWrapperDataType::Fixed:
    case LengthWrapperDataType::Relative:
    case LengthWrapperDataType::Intrinsic:
    case LengthWrapperDataType::MinIntrinsic:
    case LengthWrapperDataType::MinContent:
    case LengthWrapperDataType::MaxContent:
    case LengthWrapperDataType::FillAvailable:
    case LengthWrapperDataType::FitContent:
    case LengthWrapperDataType::Percent:
        m_isFloat = other.m_isFloat;
        if (m_isFloat)
            m_floatValue = other.m_floatValue;
        else
            m_intValue = other.m_intValue;
        break;
    case LengthWrapperDataType::Calculated:
        m_calculationValueHandle = std::exchange(other.m_calculationValueHandle, 0);
        break;
    }

    other.m_type = LengthWrapperDataType::Auto;
}

inline LengthWrapperData::~LengthWrapperData()
{
    if (m_type == LengthWrapperDataType::Calculated)
        deref();
}

inline bool LengthWrapperData::operator==(const LengthWrapperData& other) const
{
    // FIXME: This might be too long to be inline.
    if (type() != other.type() || hasQuirk() != other.hasQuirk())
        return false;
    if (isEmptyValue() || other.isEmptyValue())
        return isEmptyValue() && other.isEmptyValue();
    if (m_type == LengthWrapperDataType::Undefined)
        return true;
    if (m_type == LengthWrapperDataType::Calculated)
        return isCalculatedEqual(other);
    return value() == other.value();
}

inline float LengthWrapperData::value() const
{
    ASSERT(!isEmptyValue());
    return m_isFloat ? m_floatValue : m_intValue;
}

inline int LengthWrapperData::intValue() const
{
    // FIXME: Makes no sense to return 0 here but not in the value() function above.
    if (m_type == LengthWrapperDataType::Calculated)
        return 0;
    return m_isFloat ? static_cast<int>(m_floatValue) : m_intValue;
}

inline LengthWrapperDataType LengthWrapperData::type() const
{
    return static_cast<LengthWrapperDataType>(m_type);
}

inline bool LengthWrapperData::hasQuirk() const
{
    return m_hasQuirk;
}

inline bool LengthWrapperData::isPositive() const
{
    ASSERT(!isEmptyValue());
    if (m_type == LengthWrapperDataType::Calculated)
        return true;
    return m_isFloat ? (m_floatValue > 0) : (m_intValue > 0);
}

inline bool LengthWrapperData::isNegative() const
{
    ASSERT(!isEmptyValue());
    if (m_type == LengthWrapperDataType::Calculated)
        return false;
    return m_isFloat ? (m_floatValue < 0) : (m_intValue < 0);
}

inline bool LengthWrapperData::isZero() const
{
    ASSERT(!isEmptyValue());
    if (m_type == LengthWrapperDataType::Calculated)
        return false;
    return m_isFloat ? !m_floatValue : !m_intValue;
}

LengthWrapperData blendLengthWrapperData(const LengthWrapperData& from, const LengthWrapperData& to, const BlendingContext&);
LengthWrapperData blendLengthWrapperData(const LengthWrapperData& from, const LengthWrapperData& to, const BlendingContext&, ValueRange);

WTF::TextStream& operator<<(WTF::TextStream&, const LengthWrapperData&);

template<typename ReturnType, typename MaximumType>
ReturnType minimumValueForLengthWrapperDataWithLazyMaximum(const LengthWrapperData& length, NOESCAPE const Invocable<MaximumType()> auto& lazyMaximumValueFunctor)
{
    switch (length.type()) {
    case LengthWrapperDataType::Fixed:
        return ReturnType(length.value());
    case LengthWrapperDataType::Percent:
        return ReturnType(static_cast<float>(lazyMaximumValueFunctor() * length.value() / 100.0f));
    case LengthWrapperDataType::Calculated:
        return ReturnType(length.nonNanCalculatedValue(lazyMaximumValueFunctor()));
    case LengthWrapperDataType::FillAvailable:
    case LengthWrapperDataType::Auto:
    case LengthWrapperDataType::Normal:
    case LengthWrapperDataType::Content:
        return ReturnType(0);
    case LengthWrapperDataType::Relative:
    case LengthWrapperDataType::Intrinsic:
    case LengthWrapperDataType::MinIntrinsic:
    case LengthWrapperDataType::MinContent:
    case LengthWrapperDataType::MaxContent:
    case LengthWrapperDataType::FitContent:
    case LengthWrapperDataType::Undefined:
        break;
    }
    ASSERT_NOT_REACHED();
    return ReturnType(0);
}

template<typename ReturnType, typename MaximumType>
ReturnType valueForLengthWrapperDataWithLazyMaximum(const LengthWrapperData& length, NOESCAPE const Invocable<MaximumType()> auto& lazyMaximumValueFunctor)
{
    switch (length.type()) {
    case LengthWrapperDataType::Fixed:
        return ReturnType(length.value());
    case LengthWrapperDataType::Percent:
        return ReturnType(static_cast<float>(lazyMaximumValueFunctor() * length.value() / 100.0f));
    case LengthWrapperDataType::Calculated:
        return ReturnType(length.nonNanCalculatedValue(lazyMaximumValueFunctor()));
    case LengthWrapperDataType::FillAvailable:
    case LengthWrapperDataType::Auto:
    case LengthWrapperDataType::Normal:
        return ReturnType(lazyMaximumValueFunctor());
    case LengthWrapperDataType::Content:
    case LengthWrapperDataType::Relative:
    case LengthWrapperDataType::Intrinsic:
    case LengthWrapperDataType::MinIntrinsic:
    case LengthWrapperDataType::MinContent:
    case LengthWrapperDataType::MaxContent:
    case LengthWrapperDataType::FitContent:
    case LengthWrapperDataType::Undefined:
        break;
    }
    ASSERT_NOT_REACHED();
    return ReturnType(0);
}

} // namespace Style
} // namespace WebCore
