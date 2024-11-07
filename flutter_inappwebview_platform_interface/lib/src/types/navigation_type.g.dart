// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_type.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the type of action triggering a navigation for the [PlatformWebViewCreationParams.shouldOverrideUrlLoading] event.
class NavigationType {
  final String _value;
  final int? _nativeValue;
  const NavigationType._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory NavigationType._internalMultiPlatform(
          String value, Function nativeValue) =>
      NavigationType._internal(value, nativeValue());

  ///An item from the back-forward list was requested.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKNavigationType.formSubmitted](https://developer.apple.com/documentation/webkit/wknavigationtype/formsubmitted))
  ///- MacOS ([Official API - WKNavigationType.formSubmitted](https://developer.apple.com/documentation/webkit/wknavigationtype/formsubmitted))
  ///- Windows ([Official API - COREWEBVIEW2_NAVIGATION_KIND_BACK_OR_FORWARD](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#corewebview2_navigation_kind))
  static final BACK_FORWARD =
      NavigationType._internalMultiPlatform('BACK_FORWARD', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 2;
      case TargetPlatform.macOS:
        return 2;
      case TargetPlatform.windows:
        return 1;
      default:
        break;
    }
    return null;
  });

  ///A form was resubmitted (for example by going back, going forward, or reloading).
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKNavigationType.formSubmitted](https://developer.apple.com/documentation/webkit/wknavigationtype/formresubmitted))
  ///- MacOS ([Official API - WKNavigationType.formSubmitted](https://developer.apple.com/documentation/webkit/wknavigationtype/formresubmitted))
  static final FORM_RESUBMITTED =
      NavigationType._internalMultiPlatform('FORM_RESUBMITTED', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 4;
      case TargetPlatform.macOS:
        return 4;
      default:
        break;
    }
    return null;
  });

  ///A form was submitted.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKNavigationType.formSubmitted](https://developer.apple.com/documentation/webkit/wknavigationtype/formsubmitted))
  ///- MacOS ([Official API - WKNavigationType.formSubmitted](https://developer.apple.com/documentation/webkit/wknavigationtype/formsubmitted))
  static final FORM_SUBMITTED =
      NavigationType._internalMultiPlatform('FORM_SUBMITTED', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 1;
      case TargetPlatform.macOS:
        return 1;
      default:
        break;
    }
    return null;
  });

  ///A link with an href attribute was activated by the user.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKNavigationType.linkActivated](https://developer.apple.com/documentation/webkit/wknavigationtype/linkactivated))
  ///- MacOS ([Official API - WKNavigationType.linkActivated](https://developer.apple.com/documentation/webkit/wknavigationtype/linkactivated))
  ///- Windows
  static final LINK_ACTIVATED =
      NavigationType._internalMultiPlatform('LINK_ACTIVATED', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 0;
      case TargetPlatform.macOS:
        return 0;
      case TargetPlatform.windows:
        return 0;
      default:
        break;
    }
    return null;
  });

  ///Navigation is taking place for some other reason.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKNavigationType.other](https://developer.apple.com/documentation/webkit/wknavigationtype/other))
  ///- MacOS ([Official API - WKNavigationType.other](https://developer.apple.com/documentation/webkit/wknavigationtype/other))
  ///- Windows
  static final OTHER = NavigationType._internalMultiPlatform('OTHER', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return -1;
      case TargetPlatform.macOS:
        return -1;
      case TargetPlatform.windows:
        return 3;
      default:
        break;
    }
    return null;
  });

  ///The webpage was reloaded.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKNavigationType.reload](https://developer.apple.com/documentation/webkit/wknavigationtype/reload))
  ///- MacOS ([Official API - WKNavigationType.reload](https://developer.apple.com/documentation/webkit/wknavigationtype/reload))
  ///- Windows ([Official API - COREWEBVIEW2_NAVIGATION_KIND_RELOAD](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#corewebview2_navigation_kind))
  static final RELOAD = NavigationType._internalMultiPlatform('RELOAD', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 3;
      case TargetPlatform.macOS:
        return 3;
      case TargetPlatform.windows:
        return 2;
      default:
        break;
    }
    return null;
  });

  ///Set of all values of [NavigationType].
  static final Set<NavigationType> values = [
    NavigationType.BACK_FORWARD,
    NavigationType.FORM_RESUBMITTED,
    NavigationType.FORM_SUBMITTED,
    NavigationType.LINK_ACTIVATED,
    NavigationType.OTHER,
    NavigationType.RELOAD,
  ].toSet();

  ///Gets a possible [NavigationType] instance from [String] value.
  static NavigationType? fromValue(String? value) {
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

  /// Gets a possible [NavigationType] instance value with name [name].
  ///
  /// Goes through [NavigationType.values] looking for a value with
  /// name [name], as reported by [NavigationType.name].
  /// Returns the first value with the given name, otherwise `null`.
  static NavigationType? byName(String? name) {
    if (name != null) {
      try {
        return NavigationType.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [NavigationType] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, NavigationType> asNameMap() => <String, NavigationType>{
        for (final value in NavigationType.values) value.name(): value
      };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [int?] native value.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'BACK_FORWARD':
        return 'BACK_FORWARD';
      case 'FORM_RESUBMITTED':
        return 'FORM_RESUBMITTED';
      case 'FORM_SUBMITTED':
        return 'FORM_SUBMITTED';
      case 'LINK_ACTIVATED':
        return 'LINK_ACTIVATED';
      case 'OTHER':
        return 'OTHER';
      case 'RELOAD':
        return 'RELOAD';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    return _value;
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

  /// Gets a possible [IOSWKNavigationType] instance value with name [name].
  ///
  /// Goes through [IOSWKNavigationType.values] looking for a value with
  /// name [name], as reported by [IOSWKNavigationType.name].
  /// Returns the first value with the given name, otherwise `null`.
  static IOSWKNavigationType? byName(String? name) {
    if (name != null) {
      try {
        return IOSWKNavigationType.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [IOSWKNavigationType] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, IOSWKNavigationType> asNameMap() =>
      <String, IOSWKNavigationType>{
        for (final value in IOSWKNavigationType.values) value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
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

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    return name();
  }
}
