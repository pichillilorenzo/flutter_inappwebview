// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_tabs_navigation_event_type.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///The type corresponding to the navigation event of [PlatformChromeSafariBrowserEvents.onNavigationEvent].
class CustomTabsNavigationEventType {
  final int _value;
  final int? _nativeValue;
  const CustomTabsNavigationEventType._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory CustomTabsNavigationEventType._internalMultiPlatform(
          int value, Function nativeValue) =>
      CustomTabsNavigationEventType._internal(value, nativeValue());

  ///Sent when loading was aborted by a user action before it finishes like clicking on a link or refreshing the page.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  static final ABORTED =
      CustomTabsNavigationEventType._internalMultiPlatform(4, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 4;
      default:
        break;
    }
    return null;
  });

  ///Sent when the tab couldn't finish loading due to a failure.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  static final FAILED =
      CustomTabsNavigationEventType._internalMultiPlatform(3, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 3;
      default:
        break;
    }
    return null;
  });

  ///Sent when the tab has finished loading a page.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  static final FINISHED =
      CustomTabsNavigationEventType._internalMultiPlatform(2, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 2;
      default:
        break;
    }
    return null;
  });

  ///Sent when the tab has started loading a page.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  static final STARTED =
      CustomTabsNavigationEventType._internalMultiPlatform(1, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 1;
      default:
        break;
    }
    return null;
  });

  ///Sent when the tab becomes hidden.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  static final TAB_HIDDEN =
      CustomTabsNavigationEventType._internalMultiPlatform(6, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 6;
      default:
        break;
    }
    return null;
  });

  ///Sent when the tab becomes visible.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  static final TAB_SHOWN =
      CustomTabsNavigationEventType._internalMultiPlatform(5, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 5;
      default:
        break;
    }
    return null;
  });

  ///Set of all values of [CustomTabsNavigationEventType].
  static final Set<CustomTabsNavigationEventType> values = [
    CustomTabsNavigationEventType.ABORTED,
    CustomTabsNavigationEventType.FAILED,
    CustomTabsNavigationEventType.FINISHED,
    CustomTabsNavigationEventType.STARTED,
    CustomTabsNavigationEventType.TAB_HIDDEN,
    CustomTabsNavigationEventType.TAB_SHOWN,
  ].toSet();

  ///Gets a possible [CustomTabsNavigationEventType] instance from [int] value.
  static CustomTabsNavigationEventType? fromValue(int? value) {
    if (value != null) {
      try {
        return CustomTabsNavigationEventType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [CustomTabsNavigationEventType] instance from a native value.
  static CustomTabsNavigationEventType? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return CustomTabsNavigationEventType.values
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
      case 4:
        return 'ABORTED';
      case 3:
        return 'FAILED';
      case 2:
        return 'FINISHED';
      case 1:
        return 'STARTED';
      case 6:
        return 'TAB_HIDDEN';
      case 5:
        return 'TAB_SHOWN';
    }
    return _value.toString();
  }
}
