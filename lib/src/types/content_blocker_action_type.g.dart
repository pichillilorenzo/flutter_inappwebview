// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_blocker_action_type.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the kind of action that can be used with a [ContentBlockerTrigger].
class ContentBlockerActionType {
  final String _value;
  final String _nativeValue;
  const ContentBlockerActionType._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory ContentBlockerActionType._internalMultiPlatform(
          String value, Function nativeValue) =>
      ContentBlockerActionType._internal(value, nativeValue());

  ///Stops loading of the resource. If the resource was cached, the cache is ignored.
  static const BLOCK = ContentBlockerActionType._internal('block', 'block');

  ///Hides elements of the page based on a CSS selector. A selector field contains the selector list. Any matching element has its display property set to none, which hides it.
  ///
  ///**NOTE**: on Android, JavaScript must be enabled.
  static const CSS_DISPLAY_NONE = ContentBlockerActionType._internal(
      'css-display-none', 'css-display-none');

  ///Changes a URL from http to https. URLs with a specified (nondefault) port and links using other protocols are unaffected.
  static const MAKE_HTTPS =
      ContentBlockerActionType._internal('make-https', 'make-https');

  ///Set of all values of [ContentBlockerActionType].
  static final Set<ContentBlockerActionType> values = [
    ContentBlockerActionType.BLOCK,
    ContentBlockerActionType.CSS_DISPLAY_NONE,
    ContentBlockerActionType.MAKE_HTTPS,
  ].toSet();

  ///Gets a possible [ContentBlockerActionType] instance from [String] value.
  static ContentBlockerActionType? fromValue(String? value) {
    if (value != null) {
      try {
        return ContentBlockerActionType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [ContentBlockerActionType] instance from a native value.
  static ContentBlockerActionType? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return ContentBlockerActionType.values
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
