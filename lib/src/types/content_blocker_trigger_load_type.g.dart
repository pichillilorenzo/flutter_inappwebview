// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_blocker_trigger_load_type.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the possible load type for a [ContentBlockerTrigger].
class ContentBlockerTriggerLoadType {
  final String _value;
  final String _nativeValue;
  const ContentBlockerTriggerLoadType._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory ContentBlockerTriggerLoadType._internalMultiPlatform(
          String value, Function nativeValue) =>
      ContentBlockerTriggerLoadType._internal(value, nativeValue());

  ///FIRST_PARTY is triggered only if the resource has the same scheme, domain, and port as the main page resource.
  static const FIRST_PARTY =
      ContentBlockerTriggerLoadType._internal('first-party', 'first-party');

  ///THIRD_PARTY is triggered if the resource is not from the same domain as the main page resource.
  static const THIRD_PARTY =
      ContentBlockerTriggerLoadType._internal('third-party', 'third-party');

  ///Set of all values of [ContentBlockerTriggerLoadType].
  static final Set<ContentBlockerTriggerLoadType> values = [
    ContentBlockerTriggerLoadType.FIRST_PARTY,
    ContentBlockerTriggerLoadType.THIRD_PARTY,
  ].toSet();

  ///Gets a possible [ContentBlockerTriggerLoadType] instance from [String] value.
  static ContentBlockerTriggerLoadType? fromValue(String? value) {
    if (value != null) {
      try {
        return ContentBlockerTriggerLoadType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [ContentBlockerTriggerLoadType] instance from a native value.
  static ContentBlockerTriggerLoadType? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return ContentBlockerTriggerLoadType.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value.
  String toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    return _value;
  }
}
