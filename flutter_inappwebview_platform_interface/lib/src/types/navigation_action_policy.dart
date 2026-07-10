import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import '../in_app_webview/platform_webview.dart';
part 'navigation_action_policy.g.dart';

///Class that is used by [PlatformWebViewCreationParams.shouldOverrideUrlLoading] event.
///It represents the policy to pass back to the decision handler.
@ExchangeableEnum()
class NavigationActionPolicy_ {
  // ignore: unused_field
  final int _value;
  const NavigationActionPolicy_._internal(this._value);

  ///Cancel the navigation.
  static const CANCEL = const NavigationActionPolicy_._internal(0);

  ///Allow the navigation to continue.
  static const ALLOW = const NavigationActionPolicy_._internal(1);

  ///Turn the navigation into a download.
  ///
  ///**NOTE**: available only on iOS 14.5+. It will fallback to [CANCEL].
  static const DOWNLOAD = const NavigationActionPolicy_._internal(2);

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
  @EnumSupportedPlatforms(platforms: [
    EnumIOSPlatform(value: 3),
    EnumMacOSPlatform(value: 3),
  ], defaultValue: 1)
  static const ALLOW_WITHOUT_TRYING_APP_LINK =
      const NavigationActionPolicy_._internal(3);
}
