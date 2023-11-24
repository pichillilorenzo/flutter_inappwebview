// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_tabs_post_message_result_type.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Custom Tabs postMessage result type.
class CustomTabsPostMessageResultType {
  final int _value;
  final int? _nativeValue;
  const CustomTabsPostMessageResultType._internal(
      this._value, this._nativeValue);
// ignore: unused_element
  factory CustomTabsPostMessageResultType._internalMultiPlatform(
          int value, Function nativeValue) =>
      CustomTabsPostMessageResultType._internal(value, nativeValue());

  ///Indicates that the postMessage request was not allowed due to a bad argument
  ///or requesting at a disallowed time like when in background.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  static final FAILURE_DISALLOWED =
      CustomTabsPostMessageResultType._internalMultiPlatform(-1, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return -1;
      default:
        break;
    }
    return null;
  });

  ///Indicates that the postMessage request has failed due to an internal error on the browser message channel.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  static final FAILURE_MESSAGING_ERROR =
      CustomTabsPostMessageResultType._internalMultiPlatform(-3, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return -3;
      default:
        break;
    }
    return null;
  });

  ///Indicates that the postMessage request has failed due to a `RemoteException`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  static final FAILURE_REMOTE_ERROR =
      CustomTabsPostMessageResultType._internalMultiPlatform(-2, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return -2;
      default:
        break;
    }
    return null;
  });

  ///Indicates that the postMessage request was accepted.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  static final SUCCESS =
      CustomTabsPostMessageResultType._internalMultiPlatform(0, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 0;
      default:
        break;
    }
    return null;
  });

  ///Set of all values of [CustomTabsPostMessageResultType].
  static final Set<CustomTabsPostMessageResultType> values = [
    CustomTabsPostMessageResultType.FAILURE_DISALLOWED,
    CustomTabsPostMessageResultType.FAILURE_MESSAGING_ERROR,
    CustomTabsPostMessageResultType.FAILURE_REMOTE_ERROR,
    CustomTabsPostMessageResultType.SUCCESS,
  ].toSet();

  ///Gets a possible [CustomTabsPostMessageResultType] instance from [int] value.
  static CustomTabsPostMessageResultType? fromValue(int? value) {
    if (value != null) {
      try {
        return CustomTabsPostMessageResultType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [CustomTabsPostMessageResultType] instance from a native value.
  static CustomTabsPostMessageResultType? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return CustomTabsPostMessageResultType.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int?] native value.
  int? toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    switch (_value) {
      case -1:
        return 'FAILURE_DISALLOWED';
      case -3:
        return 'FAILURE_MESSAGING_ERROR';
      case -2:
        return 'FAILURE_REMOTE_ERROR';
      case 0:
        return 'SUCCESS';
    }
    return _value.toString();
  }
}
