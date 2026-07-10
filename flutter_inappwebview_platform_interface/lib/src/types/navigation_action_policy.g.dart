// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_action_policy.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that is used by [PlatformWebViewCreationParams.shouldOverrideUrlLoading] event.
///It represents the policy to pass back to the decision handler.
class NavigationActionPolicy {
  final int _value;
  final int? _nativeValue;
  const NavigationActionPolicy._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory NavigationActionPolicy._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => NavigationActionPolicy._internal(value, nativeValue());

  ///Allow the navigation to continue.
  static const ALLOW = NavigationActionPolicy._internal(1, 1);

  ///Allow the navigation to continue, without opening the URL in a native app
  ///that has registered it as a Universal Link / App Link.
  ///
  ///Useful, for example, during web login flows: it prevents a navigation to a
  ///domain associated with an installed app (e.g. `music.amazon.com`) from
  ///being handed off to that app, which would hijack the flow. Unlike
  ///returning [CANCEL] and re-loading the URL manually, this policy preserves
  ///the original request, including POST bodies (form submissions).
  ///
  ///**NOTE for iOS and macOS**: this corresponds to the private but
  ///long-stable WebKit policy `_WKNavigationActionPolicyAllowWithoutTryingAppLink`,
  ///obtained by casting the raw value `WKNavigationActionPolicy.allow.rawValue + 2`.
  ///No private symbol is referenced.
  ///
  ///On all other platforms, it behaves exactly like [ALLOW].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  static final ALLOW_WITHOUT_TRYING_APP_LINK =
      NavigationActionPolicy._internalMultiPlatform(3, () {
        switch (defaultTargetPlatform) {
          case TargetPlatform.iOS:
            return 3;
          case TargetPlatform.macOS:
            return 3;
          default:
            break;
        }
        return 1;
      });

  ///Cancel the navigation.
  static const CANCEL = NavigationActionPolicy._internal(0, 0);

  ///Turn the navigation into a download.
  ///
  ///**NOTE**: available only on iOS 14.5+. It will fallback to [CANCEL].
  static const DOWNLOAD = NavigationActionPolicy._internal(2, 2);

  ///Set of all values of [NavigationActionPolicy].
  static final Set<NavigationActionPolicy> values = [
    NavigationActionPolicy.ALLOW,
    NavigationActionPolicy.ALLOW_WITHOUT_TRYING_APP_LINK,
    NavigationActionPolicy.CANCEL,
    NavigationActionPolicy.DOWNLOAD,
  ].toSet();

  ///Gets a possible [NavigationActionPolicy] instance from [int] value.
  static NavigationActionPolicy? fromValue(int? value) {
    if (value != null) {
      try {
        return NavigationActionPolicy.values.firstWhere(
          (element) => element.toValue() == value,
        );
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
        return NavigationActionPolicy.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [NavigationActionPolicy] instance value with name [name].
  ///
  /// Goes through [NavigationActionPolicy.values] looking for a value with
  /// name [name], as reported by [NavigationActionPolicy.name].
  /// Returns the first value with the given name, otherwise `null`.
  static NavigationActionPolicy? byName(String? name) {
    if (name != null) {
      try {
        return NavigationActionPolicy.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [NavigationActionPolicy] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, NavigationActionPolicy> asNameMap() =>
      <String, NavigationActionPolicy>{
        for (final value in NavigationActionPolicy.values) value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 1:
        return 'ALLOW';
      case 3:
        return 'ALLOW_WITHOUT_TRYING_APP_LINK';
      case 0:
        return 'CANCEL';
      case 2:
        return 'DOWNLOAD';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  ///Checks if the value is supported by the [defaultTargetPlatform].
  bool isSupported() {
    return _nativeValue != null;
  }

  @override
  String toString() {
    return name();
  }
}
