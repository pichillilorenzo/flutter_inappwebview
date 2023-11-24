// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_action_policy.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that is used by [PlatformWebViewCreationParams.shouldOverrideUrlLoading] event.
///It represents the policy to pass back to the decision handler.
class NavigationActionPolicy {
  final int _value;
  final int _nativeValue;
  const NavigationActionPolicy._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory NavigationActionPolicy._internalMultiPlatform(
          int value, Function nativeValue) =>
      NavigationActionPolicy._internal(value, nativeValue());

  ///Allow the navigation to continue.
  static const ALLOW = NavigationActionPolicy._internal(1, 1);

  ///Cancel the navigation.
  static const CANCEL = NavigationActionPolicy._internal(0, 0);

  ///Turn the navigation into a download.
  ///
  ///**NOTE**: available only on iOS 14.5+. It will fallback to [CANCEL].
  static const DOWNLOAD = NavigationActionPolicy._internal(2, 2);

  ///Set of all values of [NavigationActionPolicy].
  static final Set<NavigationActionPolicy> values = [
    NavigationActionPolicy.ALLOW,
    NavigationActionPolicy.CANCEL,
    NavigationActionPolicy.DOWNLOAD,
  ].toSet();

  ///Gets a possible [NavigationActionPolicy] instance from [int] value.
  static NavigationActionPolicy? fromValue(int? value) {
    if (value != null) {
      try {
        return NavigationActionPolicy.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [NavigationActionPolicy] instance from a native value.
  static NavigationActionPolicy? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return NavigationActionPolicy.values
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
        return 'ALLOW';
      case 0:
        return 'CANCEL';
      case 2:
        return 'DOWNLOAD';
    }
    return _value.toString();
  }
}
