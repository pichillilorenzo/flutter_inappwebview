// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_blocker_trigger_load_context.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the kind of load context that can be used with a [ContentBlockerTrigger].
class ContentBlockerTriggerLoadContext {
  final String _value;
  final String _nativeValue;
  const ContentBlockerTriggerLoadContext._internal(
      this._value, this._nativeValue);
// ignore: unused_element
  factory ContentBlockerTriggerLoadContext._internalMultiPlatform(
          String value, Function nativeValue) =>
      ContentBlockerTriggerLoadContext._internal(value, nativeValue());

  ///Child frame load context
  static const CHILD_FRAME =
      ContentBlockerTriggerLoadContext._internal('child-frame', 'child-frame');

  ///Top frame load context
  static const TOP_FRAME =
      ContentBlockerTriggerLoadContext._internal('top-frame', 'top-frame');

  ///Set of all values of [ContentBlockerTriggerLoadContext].
  static final Set<ContentBlockerTriggerLoadContext> values = [
    ContentBlockerTriggerLoadContext.CHILD_FRAME,
    ContentBlockerTriggerLoadContext.TOP_FRAME,
  ].toSet();

  ///Gets a possible [ContentBlockerTriggerLoadContext] instance from [String] value.
  static ContentBlockerTriggerLoadContext? fromValue(String? value) {
    if (value != null) {
      try {
        return ContentBlockerTriggerLoadContext.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [ContentBlockerTriggerLoadContext] instance from a native value.
  static ContentBlockerTriggerLoadContext? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return ContentBlockerTriggerLoadContext.values
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
