// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_script_injection_time.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents contains the constants for the times at which to inject script content into a `WebView` used by an [UserScript].
class UserScriptInjectionTime {
  final int _value;
  final int _nativeValue;
  const UserScriptInjectionTime._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory UserScriptInjectionTime._internalMultiPlatform(
          int value, Function nativeValue) =>
      UserScriptInjectionTime._internal(value, nativeValue());

  ///**NOTE for iOS**: A constant to inject the script after the document finishes loading, but before loading any other subresources.
  ///
  ///**NOTE for Android**: A constant to inject the script as soon as the page finishes loading.
  static const AT_DOCUMENT_END = UserScriptInjectionTime._internal(1, 1);

  ///**NOTE for iOS**: A constant to inject the script after the creation of the webpage’s document element, but before loading any other content.
  ///
  ///**NOTE for Android**: A constant to try to inject the script as soon as the page starts loading.
  static const AT_DOCUMENT_START = UserScriptInjectionTime._internal(0, 0);

  ///Set of all values of [UserScriptInjectionTime].
  static final Set<UserScriptInjectionTime> values = [
    UserScriptInjectionTime.AT_DOCUMENT_END,
    UserScriptInjectionTime.AT_DOCUMENT_START,
  ].toSet();

  ///Gets a possible [UserScriptInjectionTime] instance from [int] value.
  static UserScriptInjectionTime? fromValue(int? value) {
    if (value != null) {
      try {
        return UserScriptInjectionTime.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [UserScriptInjectionTime] instance from a native value.
  static UserScriptInjectionTime? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return UserScriptInjectionTime.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return 'AT_DOCUMENT_END';
      case 0:
        return 'AT_DOCUMENT_START';
    }
    return _value.toString();
  }
}
