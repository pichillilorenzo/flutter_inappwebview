// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_type.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the type of action triggering a navigation for the [PlatformWebViewCreationParams.shouldOverrideUrlLoading] event.
class NavigationType {
  final int _value;
  final int _nativeValue;
  const NavigationType._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory NavigationType._internalMultiPlatform(
          int value, Function nativeValue) =>
      NavigationType._internal(value, nativeValue());

  ///An item from the back-forward list was requested.
  static const BACK_FORWARD = NavigationType._internal(2, 2);

  ///A form was resubmitted (for example by going back, going forward, or reloading).
  static const FORM_RESUBMITTED = NavigationType._internal(4, 4);

  ///A form was submitted.
  static const FORM_SUBMITTED = NavigationType._internal(1, 1);

  ///A link with an href attribute was activated by the user.
  static const LINK_ACTIVATED = NavigationType._internal(0, 0);

  ///Navigation is taking place for some other reason.
  static const OTHER = NavigationType._internal(-1, -1);

  ///The webpage was reloaded.
  static const RELOAD = NavigationType._internal(3, 3);

  ///Set of all values of [NavigationType].
  static final Set<NavigationType> values = [
    NavigationType.BACK_FORWARD,
    NavigationType.FORM_RESUBMITTED,
    NavigationType.FORM_SUBMITTED,
    NavigationType.LINK_ACTIVATED,
    NavigationType.OTHER,
    NavigationType.RELOAD,
  ].toSet();

  ///Gets a possible [NavigationType] instance from [int] value.
  static NavigationType? fromValue(int? value) {
    if (value != null) {
      try {
        return NavigationType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [NavigationType] instance from a native value.
  static NavigationType? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return NavigationType.values
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
      case 2:
        return 'BACK_FORWARD';
      case 4:
        return 'FORM_RESUBMITTED';
      case 1:
        return 'FORM_SUBMITTED';
      case 0:
        return 'LINK_ACTIVATED';
      case -1:
        return 'OTHER';
      case 3:
        return 'RELOAD';
    }
    return _value.toString();
  }
}

///Class that represents the type of action triggering a navigation on iOS for the [PlatformWebViewCreationParams.shouldOverrideUrlLoading] event.
///Use [NavigationType] instead.
@Deprecated('Use NavigationType instead')
class IOSWKNavigationType {
  final int _value;
  final int _nativeValue;
  const IOSWKNavigationType._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory IOSWKNavigationType._internalMultiPlatform(
          int value, Function nativeValue) =>
      IOSWKNavigationType._internal(value, nativeValue());

  ///An item from the back-forward list was requested.
  static const BACK_FORWARD = IOSWKNavigationType._internal(2, 2);

  ///A form was resubmitted (for example by going back, going forward, or reloading).
  static const FORM_RESUBMITTED = IOSWKNavigationType._internal(4, 4);

  ///A form was submitted.
  static const FORM_SUBMITTED = IOSWKNavigationType._internal(1, 1);

  ///A link with an href attribute was activated by the user.
  static const LINK_ACTIVATED = IOSWKNavigationType._internal(0, 0);

  ///Navigation is taking place for some other reason.
  static const OTHER = IOSWKNavigationType._internal(-1, -1);

  ///The webpage was reloaded.
  static const RELOAD = IOSWKNavigationType._internal(3, 3);

  ///Set of all values of [IOSWKNavigationType].
  static final Set<IOSWKNavigationType> values = [
    IOSWKNavigationType.BACK_FORWARD,
    IOSWKNavigationType.FORM_RESUBMITTED,
    IOSWKNavigationType.FORM_SUBMITTED,
    IOSWKNavigationType.LINK_ACTIVATED,
    IOSWKNavigationType.OTHER,
    IOSWKNavigationType.RELOAD,
  ].toSet();

  ///Gets a possible [IOSWKNavigationType] instance from [int] value.
  static IOSWKNavigationType? fromValue(int? value) {
    if (value != null) {
      try {
        return IOSWKNavigationType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [IOSWKNavigationType] instance from a native value.
  static IOSWKNavigationType? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return IOSWKNavigationType.values
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
      case 2:
        return 'BACK_FORWARD';
      case 4:
        return 'FORM_RESUBMITTED';
      case 1:
        return 'FORM_SUBMITTED';
      case 0:
        return 'LINK_ACTIVATED';
      case -1:
        return 'OTHER';
      case 3:
        return 'RELOAD';
    }
    return _value.toString();
  }
}
